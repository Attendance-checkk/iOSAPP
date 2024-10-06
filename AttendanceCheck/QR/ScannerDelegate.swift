//
//  ScannerDelegate.swift
//  AttendanceCheck
//
//  Created by ROLF J. on 10/6/24.
//

import SwiftUI
import AVKit

class ScannerDelegate: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var scannedCode: String?
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metaObject = metadataObjects.first {
            guard let readbleObject = metaObject as? AVMetadataMachineReadableCodeObject else { return }
            guard let code = readbleObject.stringValue else { return }
            
            print(code)
            
            scannedCode = code
        }
    }
}
