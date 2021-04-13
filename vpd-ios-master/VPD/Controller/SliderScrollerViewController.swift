//
//  SliderScrollerViewController.swift
//  VPD
//
//  Created by Ikenna Udokporo on 29/04/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class SliderScrollerViewController: UIViewController, UIScrollViewDelegate {


    
    @IBOutlet weak var scroller: UIScrollView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var nextButton: UIButton!
    
    var imageArr =  ["SCREEN1", "SCREEN2", "SCREEN3", "SCREEN4"]
    var contentWidth: CGFloat = 0.0
    var frame = CGRect(x:0, y:0, width:0, height: 0)
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        view.bringSubviewToFront(scroller)
        
        pageControl.numberOfPages = imageArr.count
        
        for i in 0..<imageArr.count {
            frame.origin.x = scroller.frame.size.width * CGFloat(i)
            frame.size = scroller.frame.size
            
            
            let imageView = UIImageView(frame: frame)
            imageView.image = UIImage(named: imageArr[i])
            self.scroller.addSubview(imageView)
        }
        
        scroller.contentSize = CGSize(width: (scroller.frame.size.width * CGFloat(imageArr.count)), height: scroller.frame.size.height)
        
        scroller.delegate = self
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView){
        let pageNumber = scroller.contentOffset.x / scroller.frame.size.width
        pageControl.currentPage = Int(pageNumber)
    }
    
//    @IBAction func nextSlide(_ sender: UIButton) {
//        print(scroller.contentOffset.x)
//        //print(self.sli)
//        if(scroller.contentOffset.x > 0) {
//            self.scroller.contentOffset.x -= self.view.bounds.width
//
//        }
//    }
    
}

