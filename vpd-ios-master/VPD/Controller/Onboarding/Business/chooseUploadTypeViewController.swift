//
//  chooseUploadTypeViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 17/09/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

/******Protocol to Handle image from Camera******/
protocol goBackDelegate {
    func imageCamera(image: UIImage)
}

class chooseUploadTypeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, CameraImageDelegate {
    

    var delegate: goBackDelegate?
    
    @IBOutlet var viewWrapper: UIView!
    
    var imagePicker = UIImagePickerController()
    
    var expectedPhoto  = ""
    
    var image: UIImage?
    
    /***********Delegate property for Protocol*************/
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        viewWrapper.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPickerView)))
        
        if image != nil {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    @objc func dismissPickerView(_ sender: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: UIButton) {
        switch sender.tag {
        case 1:
            print("Take a pictue")
            
        default:
            chooseFromFile()
        }
    }
    @IBAction func cameraButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "goToSnapPhoto", sender: self)
    }
    
    
    func imageTakenFromCamera(image: UIImage, expectedPhoto: String) {
        
        //*******check if delegate is not nil*********
        self.delegate?.imageCamera(image: image)
        
        self.image = image
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let CamVC = segue.destination as! TakePhotoViewController  
        
        CamVC.delegate = self
    }
    
    
    func chooseFromFile() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(picker: UIImagePickerController!, didFinishPickingImage image: UIImage!, editingInfo: NSDictionary!){
        print(type(of: image), image as Any)
        
        self.dismiss(animated: true, completion: { () -> Void in
            
        })
        
    }
}
