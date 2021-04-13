//
//  ASSFScreen4ViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 26/06/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import  AVFoundation
import AVKit

class ASSFScreen4ViewController: UIViewController, AVCaptureVideoDataOutputSampleBufferDelegate {
    
    
    @IBOutlet weak var imageViewOutlet: UIImageView!
    @IBOutlet weak var cameraView: DesignableView!
    @IBOutlet weak var cameraButtonOutlet: DesignableButton!
    
    var name = ""
    var dob = ""
    var phonenumber = ""
    var email = ""
    var address = ""
    var lga_id = ""
    
    let captureSession = AVCaptureSession()
    var previewLayer:CALayer!
    var captureDevice:AVCaptureDevice!
    var imageBase64String = ""
    
    
    var takePhoto = false;
    var cameraStart = false;
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        print(name, dob, phonenumber, email, address, lga_id)
    }
    
    func prepareCamera() {
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        
        let availableDevices = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .back).devices
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
        previewLayer.cornerRadius = 18
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
                    //self.imageViewOutlet.image = image
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
            print("i opened the camera")
            return
        }
        if !cameraStart {
            takePhoto = true
            print("i took the picture hear")
            return
        }
    }
    
    @IBAction func nextButtonPressed(_ sender: Any) {
        if imageBase64String == ""  {
            //Show alert here
            let alertService = AlertService()
            let alertVC = alertService.alert(alertMessage: "Please take a photo")
            self.present(alertVC, animated: true)
            return
        }
        else {
            performSegue(withIdentifier: "goNext", sender: self)
        }
        
    }
    
    @IBAction func backButtonPressed(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goNext" {
            let destination = segue.destination as! ASSFScreen5ViewController
            destination.address = address
            destination.dob = dob
            destination.name = name
            destination.phonenumber = phonenumber
            destination.lga_id = lga_id
            destination.from_segue_imageBase64String = imageBase64String
        }
    }
}
