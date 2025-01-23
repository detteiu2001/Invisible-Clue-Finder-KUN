//
//  CameraViewController.swift
//  GraduationProject
//
//  Created by cmStudent on 2024/12/25.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    var session: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        session = AVCaptureSession()
        session.beginConfiguration()
        
        guard let videoDevice = AVCaptureDevice.default(for: .video) else {
            print("カメラデバイスが見つかりません")
            return
        }
        
        do{
            let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            
            if session.canAddInput(videoDeviceInput){
                session.addInput(videoDeviceInput)
            } else {
                print("カメラ入力のセッション追加に失敗")
                return
            }
            
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = self.view.bounds
            previewLayer.videoGravity = .resizeAspectFill
            self.view.layer.addSublayer(previewLayer)
            
            session.commitConfiguration()
            
            DispatchQueue.global(qos: .userInitiated).async {
                self.session.startRunning()
            }
        } catch {
            print("カメラデバイスの設定の失敗: \(error)")
        }
    }
    
    deinit {
        session.stopRunning()
    }
}
