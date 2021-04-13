//
//  ForeignSignUpViewControllerPage2.swift
//  VPD
//
//  Created by Ikenna Udokporo on 08/05/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit
import AVFoundation


class ForeignSignUpViewControllerPage2: UIViewController {

    
    /***********Delegate property for Protocol*************/
    var delegate: CameraImageDelegate?
    
    var snapLable: String!
    
    var expectedSnapShot = ""
    
    @IBOutlet weak var cameraViewInterphase: UIView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var captureSession =  AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?

    ///ADDED NEWLY
    var backCamera: AVCaptureDevice?
    var currentDevice: AVCaptureDevice?
    
    
    var imageOutput = AVCaptureStillImageOutput()
    
    
    ///ADDED NEWLY
    var image: UIImage?
    
//    //**********Segue Parameter**********//
    var mobile: String!
    var country: String!
    var longitude: String!
    var latitude: String!
    var accountType: String!
    var choosenParameter: String!
    var IDcard = ""


    @IBOutlet weak var buttonView: UIButton!
    
    @IBOutlet weak var scanParameter: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        
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
        makeCircular(buttonView, width: 70)
        
        
        //****************Key for Auto blinking scanner************//
   
        scanParameter.text = "Scan \(String(choosenParameter))"
    }
    
    
    @IBAction func backButton(_ sender: Any) {
        captureSession.stopRunning()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func scanButtonPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        let videoConnection = imageOutput.connection(with: AVMediaType.video)!
        imageOutput.captureStillImageAsynchronously(from: videoConnection, completionHandler: { (imageBuffer, error) in if let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageBuffer!) {
            
            
            self.image = UIImage(data: imageData)
            
            
            self.videoPreviewLayer?.connection!.isEnabled = false
            
            //*******check if delegate is not nil*********
            self.delegate?.imageTakenFromCamera(image: self.image!, expectedPhoto: self.expectedSnapShot)
            //*****Dimiss ViewController*********//
            //self.dismiss(animated: true, completion: nil)
            
            self.captureSession.stopRunning()
            
            self.IDcard =  self.makeBase64Image(imageToConvert: self.image!)
            
            self.performSegue(withIdentifier: "goToPersonalInfo", sender: self)
            
            }
        })
        
    }
    
    
    //MARK: Conver UIImage to Base64 String//
    func makeBase64Image(imageToConvert: UIImage) -> String {
        
        
        //Made changes from 0.4 to 0.2
        let imageData: Data? = imageToConvert.jpegData(compressionQuality: 0.2)
        let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
        activityIndicator.stopAnimating()
        return imageStr
    }
    
    func makeCircular(_ button: UIButton, width: Int) {
        button.layer.cornerRadius = CGFloat(width / 2)
    }
    
    func addCornerRadius(image imageview: UIImageView) {
        imageview.layer.cornerRadius = 10.0
        imageview.layer.masksToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToPersonalInfo" {
            let destination = segue.destination as! SignUpViewControllerPage5
            
            destination.scanId = IDcard
        
        }
    }

}
    


