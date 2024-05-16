//
//  ViewController.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 15/05/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    @IBAction func cameraPressed(_ sender: Any) {
        let galleryVC = LiveFeedViewControllerFactory.produce()
        let navigation = UINavigationController(rootViewController: galleryVC)
        navigation.isNavigationBarHidden = true
        navigation.isModalInPresentation = true
        navigation.interactivePopGestureRecognizer?.isEnabled = true
        navigation.interactivePopGestureRecognizer?.delegate = nil
        navigation.modalPresentationStyle = .fullScreen
        navigation.modalTransitionStyle = .crossDissolve
        self.present(navigation, animated: true)
    }
    
    @IBAction func galleryPressed(_ sender: Any) {
        let galleryVC = GalleryViewControllerFactory.produce()
        let navigation = UINavigationController(rootViewController: galleryVC)
        navigation.isNavigationBarHidden = true
        navigation.isModalInPresentation = true
        navigation.interactivePopGestureRecognizer?.isEnabled = true
        navigation.interactivePopGestureRecognizer?.delegate = nil
        navigation.modalPresentationStyle = .fullScreen
        navigation.modalTransitionStyle = .crossDissolve
        self.present(navigation, animated: true)
    }
}

