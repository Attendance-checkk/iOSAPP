//
//  QRView.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI
import AVKit

struct QRView: View {
    @State private var session: AVCaptureSession = .init()
    @State private var output: AVCaptureMetadataOutput = .init()
    @State private var errorMessage: String = ""
    @State private var showError: Bool = false
    @State private var cameraPermission: Permission = .idle
    @State private var scannedCode: String = ""
    @State private var showCode: Bool = false
    @State private var alreadyScanned: Bool = false
    @State private var showProcessingView: Bool = false
    
    @Binding var selectedIndex: Int
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var eventManager: EventManager
    
    @StateObject private var outputDelegate = ScannerDelegate()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                GeometryReader {
                    let size = $0.size
                    
                    ZStack {
                        CameraView(frameSize: CGSize(width: size.width, height: size.width), session: $session)
                            .scaleEffect(0.97)
                        
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
                } label: {
                    Label("QR코드 인식 시작", systemImage: "qrcode")
                }
            }
            .padding(.horizontal, 45)
            
            // MARK: - Alert
            .alert(isPresented: $showError) {
                Alert(
                    title: Text("오류"),
                    message: Text(errorMessage),
                    primaryButton: .default(Text("확인")) {
                        if cameraPermission == .denied {
                            let settingString = UIApplication.openSettingsURLString
                            if let settingsURL = URL(string: settingString) {
                                openURL(settingsURL)
                            }
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
            .alert(isPresented: $showCode) {
                Alert(
                    title: Text(alreadyScanned ? "이미 인식된 코드입니다" : "인식이 완료되었습니다!"),
                    message: Text(alreadyScanned ? "이미 완료한 활동의 스탬프는 다시 찍을 수 없어요.." : "스탬프를 찍었어요!"),
                    dismissButton: .default(Text("확인"), action: {
                        if !alreadyScanned {
                            DispatchQueue.main.async {
                                selectedIndex = 2
                            }
                        }
                    })
                )
            }
            
            .navigationTitle("QR코드 인식")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear(perform: checkingCameraPermission)
        .onChange(of: outputDelegate.scannedCode) { oldValue, newValue in
            if let code = newValue {
                scannedCode = code
                checkIfScanned(code: code)
                session.stopRunning()
                outputDelegate.scannedCode = nil
            }
        }

    }
    
    // MARK: - Check if scanned QR code is not stamped.
    private func checkIfScanned(code: String) {
        guard let programs = eventManager.programs else {
            alreadyScanned = false
            print("------------------------------------------------")
            print("Check if scanned test: \(alreadyScanned)")
            print("------------------------------------------------")
            return
        }
        
        if programs.firstIndex(where: { $0.event_code == code }) != nil {
            alreadyScanned = eventManager.isEventCompleted(code: code)
            print("------------------------------------------------")
            print("alreadyScanned = eventManager.isEventCompleted test: \(code), \(alreadyScanned)")
            print("------------------------------------------------")
            
            showProcessingView = true
            
            DispatchQueue.main.async {
                eventManager.completeEventByQRCode(code) { success, statusCode, message in
                    showProcessingView = false
                    
                    if success {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            print("showCode = true")
                            showCode = true
                        }
                    } else {
                        if let message = message {
                            presentErrorMessage(message)
                        } else {
                            presentErrorMessage("이벤트 처리에 실패하였습니다.")
                        }
                    }
                }
            }
        } else {
            alreadyScanned = false
        }
    }
    
    private func reactiveCamera() {
        showCode = false
        
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
                    presentErrorMessage("카메라 권한을 허용하지 않으면 QR코드를 인식할 수 없습니다")
                }
            case .denied, .restricted:
                cameraPermission = .denied
                presentErrorMessage("카메라 권한을 허용하지 않으면 QR코드를 인식할 수 없습니다")
            default:
                break
            }
        }
    }
    
    private func presentErrorMessage(_ message: String) {
        errorMessage = message
        showError = true
    }
}

#Preview {
    @Previewable @State var selectedIndex: Int = 2
    QRView(selectedIndex: $selectedIndex)
}
