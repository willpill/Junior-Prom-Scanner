//
//  CameraController.swift
//  JPromScanner
//
//  Created by Yinwei Z on 10/28/23.
//

import SwiftUI
import AVFoundation

class CameraController: NSObject, ObservableObject, AVCaptureMetadataOutputObjectsDelegate {
    @Published var barcodeString: String?
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    func startCamera(_ view: UIView) {
        
        captureSession = AVCaptureSession()
        captureSession.sessionPreset = .photo
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              captureSession.canAddInput(videoInput) else {
            return
        }
        
        captureSession.addInput(videoInput)
        
        let metadataOutput = AVCaptureMetadataOutput()
        if captureSession.canAddOutput(metadataOutput) {
            captureSession.addOutput(metadataOutput)
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.qr, .ean13, .ean8, .code128]
        }
        
        DispatchQueue.main.async {
            self.previewLayer.frame = view.layer.bounds
            self.previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(self.previewLayer)
        }
        
        captureSession.startRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        for metadata in metadataObjects {
            if let readableObject = metadata as? AVMetadataMachineReadableCodeObject,
               let value = readableObject.stringValue {
                if value.count != 16 {
                    barcodeString = "Invalid Ticket"
                } else {
                    barcodeString = value
                }
                break
            }
        }
    }
    
    func resetBarcode() {
        barcodeString = "Place Barcode in View to Scan"
    }
}
