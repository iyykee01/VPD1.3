//
//  TakePhotoViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 13/05/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import AVFoundation

/******Protocol to Handle image from Camera******/
protocol CameraImageDelegate {
    func imageTakenFromCamera(image: UIImage, expectedPhoto: String)
}

class TakePhotoViewController: UIViewController {
    
    
    /***********Delegate property for Protocol*************/
    var delegate: CameraImageDelegate?
    
    var snapLable: String!
    
    var expectedSnapShot = ""
    
    @IBOutlet weak var cameraViewInterphase: UIView!
    
    
    var captureSession =  AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    ///ADDED NEWLY
    var backCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    
    var imageOutput = AVCaptureStillImageOutput()
    
    
    ///ADDED NEWLY
    var image: UIImage?
    
 
    
    override func viewDidLoad() {
        
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let devices = AVCaptureDevice.devices(for: AVMediaType.video) as [AVCaptureDevice]
        
        for device in devices {
            if device.position == .back {
                backCamera = device
            }
        }
        
        currentDevice = backCamera
        

        imageOutput = AVCaptureStillImageOutput()
        if #available(iOS 11.0, *) {
            imageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecType.jpeg]
        } else {
            // Fallback on earlier versions
        }
        
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: currentDevice!)
            
            captureSession.addInput(captureDeviceInput)
            captureSession.addOutput(imageOutput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            cameraViewInterphase.layer.addSublayer(videoPreviewLayer!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            
            captureSession.startRunning()
        }
        catch  {
            print("ERRROR")
        }
    }
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        captureSession.stopRunning()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func skipButtonPressed(_ sender: Any) {
        captureSession.stopRunning()
        dismiss(animated: true, completion: nil) 
    }
    
    
    @IBAction func snapButtonPressed(_ sender: Any) {
        
        
        
        let videoConnection = imageOutput.connection(with: AVMediaType.video)!
        imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageBuffer, error) in if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer!) {
            
            
                self.image = UIImage(data: imageData)
            
            
            //let compressData = UIImage.jpegData(self.image!) //max value is 1.0 and minimum is 0.0
            //let compressedImage = UIImage(data: compressData!)
                
                self.videoPreviewLayer?.connection!.isEnabled = false
                
                //*******check if delegate is not nil*********
                self.delegate?.imageTakenFromCamera(image: self.image!, expectedPhoto: self.expectedSnapShot)
                //*****Dimiss ViewController*********//
                self.dismiss(animated: true, completion: nil)
                self.captureSession.stopRunning()
 

            }
        })
    }
    
}

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}

