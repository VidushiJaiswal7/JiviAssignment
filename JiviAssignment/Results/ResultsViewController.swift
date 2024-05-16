//
//  ResultsViewController.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 15/05/24.
//

import Foundation
import UIKit
import Vision

class ResultsViewControllerFactory: NSObject {
    class func produce(withImages images: [UIImage],
                       isFromGallery: Bool = false) -> ResultsViewController {
        let resultsVC = ResultsViewController(nibName: "ResultsViewController",
                                               bundle: nil)
        resultsVC.images = images
        resultsVC.isFromGallery = isFromGallery
        return resultsVC
    }
}

protocol ResultsViewControllerDelegate {
    func dismissVC()
}

class ResultsViewController: UIViewController {
    @IBOutlet weak var stateButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    var delegate: ResultsViewControllerDelegate?
    
    fileprivate var isFromGallery: Bool = false
    fileprivate var images: [UIImage] = []
    
    private var image: UIImage?
    private  var selectedIndex = 0  { didSet {
        self.handleImage()
    }}
    private var faceLayers: [CAShapeLayer] = []
    private var scaledImageRect: CGRect?
    
    private var viewModel = ResultsViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    @IBAction func dismissPressed(_ sender: Any) {
        self.dismiss(animated: true)
        delegate?.dismissVC()
    }
    
    @IBAction func saveResultsPressed(_ sender: Any) {
        
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        if (selectedIndex + 1) > (images.count - 1) {
            selectedIndex = images.count - 1
        } else {
            selectedIndex += 1
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        if (selectedIndex - 1) > 0 {
            selectedIndex -= 1
        } else {
            selectedIndex = 0
        }
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        handleImage()
    }

    private func handleImage() {
        let image = images[selectedIndex]
        imageView.image = image
        
        guard let cgImage = image.cgImage else {
            return
        }
        
        calculateScaledImageRect()
        performVisionRequest(image: cgImage)
    }
    
    private func calculateScaledImageRect() {
        guard let image = imageView.image else {
            return
        }

        guard let cgImage = image.cgImage else {
            return
        }

        let originalWidth = CGFloat(cgImage.width)
        let originalHeight = CGFloat(cgImage.height)

        let imageFrame = imageView.frame
        let widthRatio = originalWidth / imageFrame.width
        let heightRatio = originalHeight / imageFrame.height

        // ScaleAspectFit
        let scaleRatio = max(widthRatio, heightRatio)

        let scaledImageWidth = originalWidth / scaleRatio
        let scaledImageHeight = originalHeight / scaleRatio

        let scaledImageX = (imageFrame.width - scaledImageWidth) / 2
        let scaledImageY = (imageFrame.height - scaledImageHeight) / 2
        
        self.scaledImageRect = CGRect(x: scaledImageX, y: scaledImageY, width: scaledImageWidth, height: scaledImageHeight)
    }
    
    private func performVisionRequest(image: CGImage) {
        self.stateButton.setTitle("Processing", for: .normal)
         let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: self.handleFaceDetectionRequest)

         let requests = [faceDetectionRequest]
         let imageRequestHandler = VNImageRequestHandler(cgImage: image,
                                                         orientation: .up,
                                                         options: [:])
         
         DispatchQueue.global(qos: .userInitiated).async {
             do {
                 try imageRequestHandler.perform(requests)
             } catch let error as NSError {
                 print(error)
                 return
             }
         }
     }
    
    private func handleFaceDetectionRequest(request: VNRequest?, error: Error?) {
        if let requestError = error as NSError? {
            print(requestError)
            return
        }
        
        guard let imageRect = self.scaledImageRect else {
            return
        }
            
        let imageWidth = imageRect.size.width
        let imageHeight = imageRect.size.height
        
        DispatchQueue.main.async {
            self.deleteDrawing()
            self.imageView.layer.sublayers = nil
            
            if let results = request?.results as? [VNFaceObservation],
               results.count > 0 {
                self.stateButton.setTitle("Processed", for: .normal)
                for observation in results {
                    
                    print(observation.boundingBox)
                    
                    var scaledObservationRect = observation.boundingBox
                    scaledObservationRect.origin.x = imageRect.origin.x + (observation.boundingBox.origin.x * imageWidth)
                    scaledObservationRect.origin.y = imageRect.origin.y + (1 - observation.boundingBox.origin.y - observation.boundingBox.height) * imageHeight
                    scaledObservationRect.size.width *= imageWidth
                    scaledObservationRect.size.height *= imageHeight
                    
                    let faceRectanglePath = CGPath(rect: scaledObservationRect, transform: nil)
                    
                    let faceLayer = CAShapeLayer()
                    faceLayer.path = faceRectanglePath
                    faceLayer.fillColor = UIColor.clear.cgColor
                    faceLayer.strokeColor = UIColor.yellow.cgColor
                    self.imageView.layer.addSublayer(faceLayer)
                    
                    //FACE LANDMARKS
                    if let landmarks = observation.landmarks {
                        if let leftEye = landmarks.leftEye {
                            self.handleLandmark(leftEye, faceBoundingBox: scaledObservationRect)
                        }
                        
                        if let rightEye = landmarks.rightEye {
                            self.handleLandmark(rightEye, faceBoundingBox: scaledObservationRect)
                        }
                        
                        if let nose = landmarks.nose {
                            self.handleLandmark(nose, faceBoundingBox: scaledObservationRect)
                        }

                        if let outerLips = landmarks.outerLips {
                            self.handleLandmark(outerLips, faceBoundingBox: scaledObservationRect)
                        }
                    }
                }
            } else {
                self.stateButton.setTitle("Invalid", for: .normal)
            }
        }
    }
    
    
    private func handleLandmark(_ eye: VNFaceLandmarkRegion2D, faceBoundingBox: CGRect) {
        let landmarkPath = CGMutablePath()
        let landmarkPathPoints = eye.normalizedPoints
            .map({ eyePoint in
                CGPoint(
                    x: eyePoint.y * faceBoundingBox.height + faceBoundingBox.origin.x,
                    y: eyePoint.x * faceBoundingBox.width + faceBoundingBox.origin.y)
            })
        
        // Draw the point
        let circlePath = UIBezierPath(arcCenter: landmarkPathPoints.first ?? CGPoint(x: 0, y: 0), radius: 3.0, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
         
         let shapeLayer = CAShapeLayer()
         shapeLayer.path = circlePath.cgPath
         shapeLayer.fillColor = UIColor.red.cgColor
         shapeLayer.strokeColor = UIColor.red.cgColor
         shapeLayer.lineWidth = 1.0
        shapeLayer.name = "shape"
         
         view.layer.addSublayer(shapeLayer)
        
        if let firstPoint = landmarkPathPoints.first {
              let convertedPoint = firstPoint
              let labelLayer = CATextLayer()
            labelLayer.string = viewModel.abmornmalities.randomElement()
              labelLayer.foregroundColor = UIColor.blue.cgColor
              labelLayer.fontSize = 10
              labelLayer.frame = CGRect(x: convertedPoint.x, y: convertedPoint.y, width: 80, height: 20)
            labelLayer.name = "label"
              view.layer.addSublayer(labelLayer)
          }
    }
    
    private func deleteDrawing() {
        view.layer.sublayers?.forEach { layer in
            if layer.name == "label" || layer.name == "shape" {
                   layer.removeFromSuperlayer()
               }
           }
    }
}
