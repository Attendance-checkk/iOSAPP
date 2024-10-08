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
    
    @Environment(\.openURL) private var openURL
    
    @StateObject private var outputDelegate = ScannerDelegate()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 8) {
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
                
                Button {
                    if !session.isRunning && cameraPermission == .approved {
                        reactiveCamera()
                    }
                } label: {
                    Label("QR코드 인식 시작", systemImage: "qrcode")
                }
                
                Spacer(minLength: 150)
            }
            .padding(.horizontal, 45)
            
            .onAppear(perform: checkingCameraPermission)
            
            .alert(errorMessage, isPresented: $showError) {
                if cameraPermission == .denied {
                    Button("Settings") {
                        let settingString = UIApplication.openSettingsURLString
                        if let settingsURL = URL(string: settingString) {
                            openURL(settingsURL)
                        }
                    }
                    
                    Button("Cancel", role: .cancel) { }
                }
            }
            
            .alert(isPresented: $showCode) {
                Alert(
                    title: Text("인식된 QR"),
                    message: Text(scannedCode),
                    dismissButton: .default(Text("확인"))
                )
            }
            
            .onChange(of: outputDelegate.scannedCode) { oldValue, newValue in
                if let code = newValue {
                    scannedCode = code
                    showCode = true
                    session.stopRunning()
                    outputDelegate.scannedCode = nil
                }
            }
            .navigationTitle("QR코드 인식")
            .navigationBarTitleDisplayMode(.inline)
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
        showError.toggle()
    }
}

#Preview {
    QRView()
}
