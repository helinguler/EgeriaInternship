//
//  BarcodeScannerView.swift
//  EgeriaInternshipApp
//
//  Created by Helin Güler on 13.05.2025.
//

/// SwiftUI ortamında barkod ve QR kod taraması yapılmasını sağlayan UIViewControllerRepresentable yapısıdır.
/// Kamera görüntüsü AVCaptureSession ile alınır ve AVCaptureMetadataOutputObjectsDelegate aracılığıyla barkod verisi yakalanır.
///
import SwiftUI
import AVFoundation

struct BarcodeScannerView: UIViewControllerRepresentable {
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        var parent: BarcodeScannerView

        init(parent: BarcodeScannerView) {
            self.parent = parent
        }

        // Barkod okunduğunda tetiklenir
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadata = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
               let code = metadata.stringValue {
                parent.completion(code)
            }
        }
    }

    var completion: (String) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        let session = AVCaptureSession()

        // Kamera erişimini al ve input olarak ekle
        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video),
              let videoInput = try? AVCaptureDeviceInput(device: videoCaptureDevice),
              session.canAddInput(videoInput) else {
            return controller
        }

        session.addInput(videoInput)

        // Metadata çıkışı ekleniyor (barkod verisini yakalamak için)
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(context.coordinator, queue: .main)
            output.metadataObjectTypes = [.ean8, .ean13, .qr]
        }

        // Kamera görüntüsünü katmana yerleştir
        let previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = UIScreen.main.bounds
        previewLayer.videoGravity = .resizeAspectFill
        
        controller.view.layer.addSublayer(previewLayer)
        
        // startRunning ana thread yerine arka thread'de çalıştırılır hang olmaması için.
        DispatchQueue.global(qos: .userInitiated).async {
            session.startRunning()
        }
        

        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}
