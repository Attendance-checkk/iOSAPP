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
    @State private var qrAlertType: QRAlretType? = nil
    @State private var showProcessingView: Bool = false
    
    @Binding var selectedIndex: Int
    
    @Environment(\.openURL) private var openURL
    
    @EnvironmentObject private var eventManager: EventManager
    
    @StateObject private var outputDelegate = ScannerDelegate()
    
    var body: some View {
        if showProcessingView {
            ProcessingView(messageString: "통신 중입니다..")
                .transition(.opacity)
                .ignoresSafeArea(.all)
        } else {
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
                    if let qrAlertType = qrAlertType {
                        return Alert(
                            title: Text(qrAlertType.title),
                            message: Text(qrAlertType.message),
                            dismissButton: .default(Text("확인"), action: {
                                if qrAlertType == .success {
                                    DispatchQueue.main.async {
                                        selectedIndex = 2
                                    }
                                }
                            })
                        )
                    } else {
                        return Alert(title: Text("AlertError"), message: Text("Notice to developer plz"), dismissButton: .default(Text("OK")))
                    }
                }
                
                .navigationTitle("QR코드 인식")
                .navigationBarTitleDisplayMode(.inline)
            }
            .onAppear(perform: checkingCameraPermission)
            .onChange(of: outputDelegate.scannedCode) { oldValue, newValue in
                if let code = newValue {
                    scannedCode = code
                    session.stopRunning()
                    showProcessingView = true
                    checkIfScanned(code: code)
                    outputDelegate.scannedCode = nil
                }
            }
        }
    }
    
    // MARK: - Check if scanned QR code is not stamped.
    private func checkIfScanned(code: String) {
            
        DispatchQueue.main.async {
            showProcessingView = false
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
                default:
                    qrAlertType = .unknownError
                    print("Unknown error")
                }
                showCode = true
            }
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
