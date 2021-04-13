//
//  ASSFScreen5ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import  AVFoundation
import AVKit
import SwiftyJSON

var agent_user_id = ""

class ASSFScreen5ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    @IBOutlet weak var cameraView: DesignableView!
    @IBOutlet weak var buttonUI: DesignableButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    var imageBase64String = ""
    
    var takePhoto = false;
    var cameraStart = false;
    
    var message = ""
    
    var name = ""
    var dob = ""
    var phonenumber = ""
    var email = ""
    var address = ""
    var lga_id = ""
    var from_segue_imageBase64String = ""
    var rotateCamera = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
        
    }
    
    
    //MARK: Make network to create user wallet
    func NetworkCallCreateUserWallet() {
        
        activityIndicator.startAnimating()
        buttonUI.isHidden = true
        
        let utililty = UtilClass()
        let device = utililty.getPhoneId()
        
        let timeInSeconds: TimeInterval = Date().timeIntervalSince1970
        let timeInSecondsToString = String(timeInSeconds)
        
        let session = UserDefaults.standard.string(forKey: "SessionID")!
        let customer_id = UserDefaults.standard.string(forKey: "CustomerID")!
        

        //******getting parameter from string
        let params = [
            "AppID":device.sha512,
            "language":"en",
            "RequestID": timeInSecondsToString,
            "SessionID": session,
            "CustomerID": customer_id,
            "AgentID": agentIDFromReg,
            "bvn": "",
            "name": name,
            "phone": phonenumber,
            "dob": dob,
            "address": address,
            "lga_id": lga_id,
            "email": email,
            "id_card": from_segue_imageBase64String,
            "photo": imageBase64String
        ]

        utililty.delayToNextPage(params: params, path: "register_agent_user") { result in
            switch result {
            case .failure(let error):
                self.activityIndicator.stopAnimating()
                
                print(error)
                print("Please check that you have internet connection")
                break
                
            case .success:
                
                let data: JSON = JSON(result.value!)
                
                //****Decode json hear****/
                let hexKey = data["reqResponse"].stringValue
                //******Import  and initialize Util Class*****////
                
                //********decripting Hex key**********//
                let decriptor = utililty.convertHexStringToString(text: hexKey)
                
                //**********Changing Data back to Json format***///
                let jsonData = decriptor.data(using: .utf8)!
                
                
                let decriptorJson: JSON = JSON(jsonData)
                print(decriptorJson)
                
                let status = decriptorJson["status"].boolValue
                let message = decriptorJson["message"][0].stringValue
                
                if(status) {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = false
                    agent_user_id = decriptorJson["response"]["account_number"].stringValue
                    let alertSV = SuccessAlertTransaction()
                    let alert = alertSV.alert(success_message: message) {
                        self.navigationController?.popToViewController(ofClass: ASSFScreen2ViewController.self)
                    }
                    self.present(alert, animated: true)
                  
                }
                else if (message == "Session has expired") {
                    self.buttonUI.isHidden = false
                    self.navigationController?.popToViewController(ofClass: LoginViewController.self)
                }
                
                else {
                    self.activityIndicator.stopAnimating()
                    self.buttonUI.isHidden = false
                    ////From the alert Service
                    let alertService = AlertService()
                    let alertVC = alertService.alert(alertMessage: message)
                    self.present(alertVC, animated: true)
                }
                break
            }
        }
    }
    
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        var availableDevices: Array<AVCaptureDevice>
        if rotateCamera {
            availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .front).devices
        }
        else {
            availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
        }
        
        captureDevice = availableDevices.first
        beginSession()
    }
    
    func beginSession () {
        do {
            let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
            
            captureSession.addInput(captureDeviceInput)
            
        }catch {
            print(error.localizedDescription)
        }
        
        
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer = previewLayer
        self.captureSession.sessionPreset = AVCaptureSession.Preset.photo
        self.view.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.view.layer.frame
        previewLayer.videoGravity = .resizeAspectFill
        self.previewLayer.frame = self.cameraView.layer.bounds
        previewLayer.cornerRadius = 125
        cameraView.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
        let dataOutput = AVCaptureVideoDataOutput()
        dataOutput.videoSettings = [((kCVPixelBufferPixelFormatTypeKey as NSString) as String):NSNumber(value:kCVPixelFormatType_32BGRA)]
        
        dataOutput.alwaysDiscardsLateVideoFrames = true
        
        if captureSession.canAddOutput(dataOutput) {
            captureSession.addOutput(dataOutput)
        }
        
        captureSession.commitConfiguration()
        
        let queue = DispatchQueue(label: "com.brianadvent.captureQueue")
        dataOutput.setSampleBufferDelegate(self as AVCaptureVideoDataOutputSampleBufferDelegate, queue: queue);
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // dispose system shutter sound
        AudioServicesPlaySystemSound(1108)
    }
    
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        if takePhoto {
            
            takePhoto = false
            
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                print(image, ".... image")
                let imageData: Data? = image.jpegData(compressionQuality: 0.4)
                let imageStr = imageData?.base64EncodedString(options: .lineLength64Characters) ?? ""
                
                imageBase64String = imageStr
                
                
                DispatchQueue.main.async {
                    self.stopCaptureSession()
                }
            }
        }
    }
    
    
    
    
    func getImageFromSampleBuffer (buffer:CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvPixelBuffer: pixelBuffer)
            let context = CIContext()
            
            let imageRect = CGRect(x: 0, y: 0, width: CVPixelBufferGetWidth(pixelBuffer), height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = context.createCGImage(ciImage, from: imageRect) {
                return UIImage(cgImage: image, scale: UIScreen.main.scale, orientation: .right)
            }
            
        }
        
        return nil
    }
    
    func stopCaptureSession () {
        self.captureSession.stopRunning()
        
        if let inputs = captureSession.inputs as? [AVCaptureDeviceInput] {
            for input in inputs {
                self.captureSession.removeInput(input)
            }
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        cameraStart.toggle()
        
        if cameraStart {
            prepareCamera()
            return
        }
        if !cameraStart {
            takePhoto = true
            return
        }
        
    }
    
    
    @IBAction func rotateCameraButtonPressed(_ sender: Any) {
        if cameraStart {
            stopCaptureSession()
            rotateCamera.toggle()
            prepareCamera()
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        
        if imageBase64String == "" {
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please take a photo")
            self.present(alertVC, animated: true)
        }
        
        else {
            NetworkCallCreateUserWallet()
        }
        
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}

