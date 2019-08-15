//
//  CameraViewController.swift
//  QRCodeScanner
//
//  Created by Hank Cheng on 10/3/18.
//  Copyright © 2018 Hank Cheng. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var previewView: UIView!
    
    var captureSession: AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var delegate: QRCodeScanDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        if AVCaptureDevice.authorizationStatus(for: AVMediaType.video) ==  AVAuthorizationStatus.authorized {
            self.initCamera()
        }
        else {
            AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
                if response {
                    self.initCamera()
                }
                else {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let frame = view.safeAreaLayoutGuide.layoutFrame
        let backButton = UIButton(frame: CGRect(x: frame.minX, y: frame.minY, width: 44, height: 44))
        var backImg = UIImage(named: "close_white_36pt.png")
        backImg = backImg!.withRenderingMode(.alwaysOriginal)
        backButton.setImage(backImg!, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        view.addSubview(backButton)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc func backButtonAction(sender: UIButton!) {
        dismiss(animated: true, completion: nil)
    }
    
    private func initCamera() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession?.addOutput(captureMetadataOutput)
            
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            /*
            for type in captureMetadataOutput.availableMetadataObjectTypes {
                print(type.rawValue)
            }
            */
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            print(error)
        }
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        previewView.layer.addSublayer(videoPreviewLayer!)
        captureSession?.startRunning()
    }
    
}

extension CameraViewController : AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if metadataObjects.count == 0 {
            print("No QRCode Found")
            return
        }
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            if metadataObj.stringValue != nil {
                debugPrint(metadataObj.stringValue!)
                self.dismiss(animated: true, completion: nil)
                delegate?.onScanSuccess(text: metadataObj.stringValue!)
            }
        }
    }
}
