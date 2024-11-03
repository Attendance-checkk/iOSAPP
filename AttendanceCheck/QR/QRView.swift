//
//  QRView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI
import AVKit

struct QRView: View {
    @EnvironmentObject private var userInformation: UserInformation
    @EnvironmentObject private var eventManager: EventManager
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.openURL) private var openURL
    
    @State private var showAccountAlert: Bool = false
    @State private var accountAlertStatusCode: Int = 0
    @State private var accountAlertMessage: String = ""
    
    @State private var session: AVCaptureSession = .init()
    @State private var output: AVCaptureMetadataOutput = .init()
    @State private var errorMessage: String = ""
    @State private var cameraPermission: Permission = .idle
    @State private var scannedCode: String = ""
    @State private var showCode: Bool = false
    @State private var qrAlertType: QRAlertType? = nil
    @State private var showProcessingView: Bool = false
    
    @Binding var selectedIndex: Int
    
    @StateObject private var outputDelegate = ScannerDelegate()
    
    enum EventState {
        case inProgress
        case upComing
        case ended
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                GeometryReader {
                    let size = $0.size
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill((colorScheme == .light) ? Color.white : Color.black)
                        
                        CameraView(frameSize: CGSize(width: size.width, height: size.width), session: $session)
                            .scaleEffect(0.97)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        
                        ForEach(0...4, id: \.self) { index in
                            let rotation = Double(index) * 90
                            
                            RoundedRectangle(cornerRadius: 5, style: .circular)
                                .trim(from: 0.61, to: 0.64)
                                .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
                                .rotationEffect(.init(degrees: rotation))
                        }
                    }
                    .frame(width: size.width, height: size.width)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .frame(width: UIScreen.main.bounds.width * 0.8, height: UIScreen.main.bounds.width * 0.8, alignment: .center)
                .padding(20)
                
                Button {
                    if !session.isRunning && cameraPermission == .approved {
                        reactiveCamera()
                    }
                    checkingCameraPermission()
                } label: {
                    Label("QR코드 인식 시작", systemImage: "qrcode")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.4), radius: 5, x: 0, y: 2)
                }
            }
            .padding(.horizontal, 45)
            
            // MARK: - Alert
            .alert(isPresented: Binding<Bool>(
                get: { qrAlertType != nil },  // Alert가 나타날 조건
                set: { if !$0 { qrAlertType = nil } } // Alert가 닫힐 때 qrAlertType을 nil로 설정
            )) {
                if let qrAlertType = qrAlertType {
                    return Alert(
                        title: Text(qrAlertType.title),
                        message: Text(qrAlertType.message),
                        dismissButton: .default(Text("확인"), action: {
                            handleAlertDismiss(qrAlertType) // Alert 닫힐 때 처리
                        })
                    )
                } else {
                    return Alert(title: Text("AlertError"), message: Text("Please notice to developer"), dismissButton: .default(Text("OK")))
                }
            }
            .fullScreenCover(isPresented: $showAccountAlert) {
                AccountAlertView(
                    statusCode: accountAlertStatusCode,
                    message: accountAlertMessage
                )
                .environmentObject(userInformation)
            }
            
            .navigationTitle("QR코드")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            checkingCameraPermission()
        }
        .onChange(of: outputDelegate.scannedCode) { newValue in
            if let code = newValue {
                scannedCode = code
                session.stopRunning()
                showProcessingView = true
                checkIfScanned(code: code)
                outputDelegate.scannedCode = nil
            }
        }
    }
    
    private func checkIfScanned(code: String) {
        DispatchQueue.main.async {
            showProcessingView = false
            
            let eventState = returnEventState(code)
            
            switch eventState {
            case .inProgress:
                eventManager.completeEventByQRCode(code) { success, statusCode, message in
                    switch statusCode {
                    case 200:
                        print("New code scanned, stmaping successed")
                        qrAlertType = .success
                    case 401:
                        print("Already scanned")
                        qrAlertType = .alreadyScanned
                    case 402:
                        qrAlertType = .unknownCode
                        print("Unknown code")
                    case 409:
                        accountAlertMessage = "서버에서 사용자 정보가 삭제되었습니다.\n다시 로그인하거나, 관리자에게 문의하여 주세요."
                        accountAlertStatusCode = 409
                        DispatchQueue.main.async {
                            showAccountAlert = true
                        }
                    case 412:
                        accountAlertMessage = "새로운 기기에서 로그인되었습니다.\n이전 기기에서 로그인된 정보는 삭제됩니다."
                        accountAlertStatusCode = 412
                        DispatchQueue.main.async {
                            showAccountAlert = true
                        }
                    default:
                        qrAlertType = .unknownError
                        print("Unknown error")
                    }
                    showCode = true
                }
                
            case .upComing:
                qrAlertType = .notYet
                showCode = true
            case .ended:
                qrAlertType = .closedEvent
                showCode = true
            }
        }
        showCode = true
    }
    
    private func returnEventState(_ code: String) -> EventState {
        let programs = eventManager.returnProgramsForChecklist()
        
        guard let event = programs.first(where: { ($0.event_code) == code }) else {
            return .ended
        }
        
        guard let startTimeString = event.event_start_time,
              let endTimeString = event.event_end_time,
              let startTime = dateStringToDate(from: startTimeString),
              let endTime = dateStringToDate(from: endTimeString) else {
            return .ended
        }
        
        // MARK: - 보통 QR코드는 이벤트 이후에 찍는데, 그 때 사람이 몰리거나, 문제가 발생하는 것을 고려
        let extendedEndTime = endTime.addingTimeInterval(20 * 60)
        
        let currentDate = Date()
        
        if currentDate < startTime {
            return .upComing
        } else if currentDate > extendedEndTime {
            return .ended
        } else {
            return .inProgress
        }
    }
    
    private func dateStringToDate(from formattedString: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        
        let currentYear = 2024
        let yearAddedString = "\(currentYear)년 \(formattedString)"
        
        dateFormatter.dateFormat = "yyyy년 MM월 d일(E) a h:mm"
        if let date = dateFormatter.date(from: yearAddedString) {
            return date
        }
        
        dateFormatter.dateFormat = "yyyy년 MM월 d일(E) HH:mm"
        return dateFormatter.date(from: yearAddedString)
    }
    
    private func getSecurityCode(_ request: String) -> String {
        if let code = Bundle.main.object(forInfoDictionaryKey: request) as? String {
            return code
        } else {
            return ""
        }
    }
    
    private func reactiveCamera() {
        DispatchQueue.global(qos: .background).async {
            session.startRunning()
        }
    }
    
    private func cameraSetting() {
        do {
            guard let device = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera, .builtInDualCamera, .builtInDualCamera], mediaType: .video, position: .back).devices.first else {
                presentErrorMessage("UNKNOWN DEVICE ERROR")
                return
            }
            
            let input = try AVCaptureDeviceInput(device: device)
            guard session.canAddInput(input), session.canAddOutput(output) else {
                presentErrorMessage("UNKNONW I/O ERROR")
                return
            }
            
            session.beginConfiguration()
            session.addInput(input)
            session.addOutput(output)
            output.metadataObjectTypes = [.qr]
            
            output.setMetadataObjectsDelegate(outputDelegate, queue: .main)
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .background).async {
                session.startRunning()
            }
        } catch {
            presentErrorMessage(error.localizedDescription)
        }
    }
    
    private func checkingCameraPermission() {
        Task {
            switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized:
                cameraPermission = .approved
                if session.inputs.isEmpty {
                    cameraSetting()
                } else {
                    reactiveCamera()
                }
            case .notDetermined:
                if await AVCaptureDevice.requestAccess(for: .video) {
                    cameraPermission = .approved
                    cameraSetting()
                } else {
                    cameraPermission = .denied
                    presentErrorMessage("NO PERMISSION")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentErrorMessage("NO PERMISSION")
            default:
                break
            }
        }
    }
    
    private func presentErrorMessage(_ message: String) {
        print("presentErrorMessage")
        
        if message == "NO PERMISSION" {
            qrAlertType = .permission
            showCode = true
        }
    }
    
    private func handleAlertDismiss(_ qrAlertType: QRAlertType) {
        switch qrAlertType {
        case .success:
            DispatchQueue.main.async {
                selectedIndex = 2
            }
            
        case .permission:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
            
        case .noUser, .newDevice:
            userInformation.loginState = false
            userInformation.storedLoginState = false
            print("userInformation.loginState = \(userInformation.loginState)")
        default:
            break
        }
    }
}
