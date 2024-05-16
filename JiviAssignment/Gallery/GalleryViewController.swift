//
//  GalleryViewController.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 15/05/24.
//

import Foundation
import PhotosUI
import UIKit

class GalleryViewControllerFactory: NSObject {
    class func produce() -> GalleryViewController {
        let galleryVC = GalleryViewController(nibName: "GalleryViewController",
                                              bundle: nil)
        return galleryVC
    }
}

class GalleryViewController: UIViewController {
    
    private var viewModel: GalleryViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        
        openGallery()
    }
    
    private func setupViewModel() {
        viewModel = GalleryViewModel()
    }
    
    private func openGallery() {
        viewModel?.isGalleryPermissionGiven { isPermissionGranted in
            if isPermissionGranted {
                DispatchQueue.main.async {
                    var configuration = PHPickerConfiguration()
                    configuration.filter = .any(of: [.images])
                    configuration.selectionLimit = 10
                    let picker = PHPickerViewController(configuration: configuration)
                    picker.delegate = self
                    self.present(picker, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    self.showPermissionAlert()
                }
            }
        }
    }
    
    private func showPermissionAlert() {
        var subtitleString = "Looks like you’ve denied Gallery access. Please allow access from iPhone ⚙️ Settings"
        let subtitle = NSMutableAttributedString(string: subtitleString)
        // TODO: add alert here
    }
    
    private func openResults(forImages images: [UIImage]) {
        DispatchQueue.main.async {
            let resultsVC = ResultsViewControllerFactory.produce(withImages: images,
                                                                 isFromGallery: true)
            resultsVC.delegate = self
            self.navigationController?.pushViewController(resultsVC, animated: true)
        }
    }
    
    
}

extension GalleryViewController: ResultsViewControllerDelegate {
    func dismissVC() {
        self.dismiss(animated: true)
    }
}

extension GalleryViewController: PHPickerViewControllerDelegate {
    public func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true, completion: nil)
        var images: [UIImage] = []
        for result: PHPickerResult in results {
            let itemProvider = result.itemProvider
            if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                    guard let self = self else { return }
                    if let image = image as? UIImage {
                        images.append(image)
                        
                        if images.count == results.count {
                            self.openResults(forImages: images)
                        }
                    }
                }
            }
        }
    }
}
