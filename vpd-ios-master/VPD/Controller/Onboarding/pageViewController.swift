//
//  pageViewController.swift
//  testClass
//
//  Created by Ikenna Udokporo on 11/10/2019.
//  Copyright © 2019 voguepay. All rights reserved.
//

import UIKit

class pageViewController: UIPageViewController {
    
    var pageControl = UIPageControl()
    var nextButton = UIButton()
    
    lazy var orderedViewController: [UIViewController] = {
        
        return [
            self.newVC(viewController: "screenOne"),
            self.newVC(viewController: "screenTwo"),
            self.newVC(viewController: "screenThree"),
        ]
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.dataSource = self
        self.delegate = self
        
        
        if let firstViewController = orderedViewController.first {
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        configurePageController()
        nextButton.addTarget(self, action: #selector(buttonClicked), for: .touchUpInside)
    }
    
    
    override func didReceiveMemoryWarning() {
        print("I go memetoy issures")
        
    }
    
    

    func configurePageController() {
        pageControl = UIPageControl(frame: CGRect(x: 0, y: UIScreen.main.bounds.maxY - 80 , width: UIScreen.main.bounds.width, height: 50))
        
        pageControl.numberOfPages = orderedViewController.count
        pageControl.currentPage = 0
        pageControl.tintColor = .black
        pageControl.currentPageIndicatorTintColor = .black
        pageControl.pageIndicatorTintColor = .lightGray
        
        
        nextButton = UIButton(frame: CGRect(x: UIScreen.main.bounds.maxX - 80, y: UIScreen.main.bounds.maxY - 95, width: 65, height: 65))
        
        let image = UIImage(named: "NORMAL") as UIImage?
        
        nextButton.cornerRadius = 25
        nextButton.setImage(image, for: .normal)
        //nextButton.backgroundColor = .blue
        
        
        
        self.view.addSubview(pageControl)
        self.view.addSubview(nextButton)
    }
    
    
    func newVC(viewController: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: viewController)
    }
    
    
    @objc func buttonClicked() {

        guard let currentViewController = self.viewControllers?.first else { return }
        
        guard let nextViewController = dataSource?.pageViewController( self, viewControllerAfter: currentViewController ) else { return }
        
        // Has to be set like this, since else the delgates for the buttons won't work
        setViewControllers([nextViewController], direction: .forward, animated: true, completion: { completed in self.delegate?.pageViewController?(self, didFinishAnimating: true, previousViewControllers: [], transitionCompleted: completed) })
    }

}


extension pageViewController:  UIPageViewControllerDelegate, UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        
        
        nextButton.isHidden = false
        pageControl.isHidden = false
 
        
        guard let VCIndex = orderedViewController.firstIndex(of: viewController) else {
            return nil
        }
        
        let previousIndex = VCIndex - 1
        
        guard previousIndex >= 0 else {
            return nil
        }
        
        guard orderedViewController.count > previousIndex else {
            return nil
        }
        
        return orderedViewController[previousIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        
        guard let VCIndex = orderedViewController.firstIndex(of: viewController) else {
            return nil
        }
        
        let nextIndex = VCIndex + 1
        
        guard orderedViewController.count  > nextIndex else {
            return nil
        }
        
        guard orderedViewController.count  > nextIndex else {
            return nil
        }
        
        return orderedViewController[nextIndex]
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let pageContentViewController = pageViewController.viewControllers![0]
        self.pageControl.currentPage = orderedViewController.firstIndex(of: pageContentViewController)!
        
        
        let lastPage = orderedViewController.count - 1
        
        if pageControl.currentPage == lastPage {
            nextButton.isHidden = true
            pageControl.isHidden = true
        }
    }
    
}
