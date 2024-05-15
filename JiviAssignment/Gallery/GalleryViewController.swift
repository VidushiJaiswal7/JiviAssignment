//
//  GalleryViewController.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 15/05/24.
//

import Foundation
import UIKit

class GalleryViewControllerFactory: NSObject {
    class func produce() -> GalleryViewController {
        let galleryVC = GalleryViewController(nibName: "GalleryViewController",
                                              bundle: nil)
        return galleryVC
    }
}

class GalleryViewController: UIViewController {
    
}
