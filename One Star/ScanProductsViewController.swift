//
//  ScanProductsViewController.swift
//  One Star
//
//  Created by sid patel on 8/4/16.
//  Copyright © 2016 coretwist. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation


class ScanProductViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    
    @IBOutlet weak var videoLayerView: UIView!
     @IBOutlet weak var cancleScaningProduct: UIButton!
    @IBOutlet weak var productImageView: UIImageView!
   
    
    
    @IBAction func cancleScaningProducts(_ sender: AnyObject) {
        
       print("cancle button clicked")
        self.captureSession.stopRunning()
        self.previewLayer?.removeFromSuperlayer()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        cancleScaningProduct.backgroundColor = UIColor.clear()
        cancleScaningProduct.layer.cornerRadius = 5
        cancleScaningProduct.layer.borderWidth = 4
        cancleScaningProduct.layer.borderColor = UIColor.red().cgColor
        
        startScanning()
        
        
        
       
        
    }
    
    func startScanning(){
        print("open camera")
        view.backgroundColor = UIColor.white()
        captureSession = AVCaptureSession()
        
        let videoCaptureDevice = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
        let videoInput: AVCaptureDeviceInput
        
        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }
        
        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }
        
        let metadataOutput = AVCaptureMetadataOutput()
        
        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)
            
            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode]
        } else {
            failed()
            return
        }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = videoLayerView.layer.bounds //view.layer..bounds
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        //view.layer.addSublayer(previewLayer)
        videoLayerView.layer.addSublayer(previewLayer)
        
        
        
        captureSession.startRunning()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning();
        }
    }
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, from connection: AVCaptureConnection!) {
        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            let readableObject = metadataObject as! AVMetadataMachineReadableCodeObject;
            
            print(readableObject.type)
            
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            foundCode(code: readableObject.stringValue);
        }
        
        //self.dismiss(animated: true, completion: nil)
    }

    func foundCode(code: String) {
        print(code)
        self.captureSession.stopRunning()
        self.previewLayer?.removeFromSuperlayer()
        // barcodeLabel.text = "Barcode: \(code)"
        
        
    }

    func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(ac, animated: true, completion: nil)
        captureSession = nil
    }
    
    
    
}
