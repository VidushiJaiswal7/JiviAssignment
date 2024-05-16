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
    class func produce(withImage image: UIImage) -> ResultsViewController {
        let resultsVC = ResultsViewController(nibName: "ResultsViewController",
                                               bundle: nil)
        resultsVC.image = image
        return resultsVC
    }
}

class ResultsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    var image: UIImage?
    private var faceLayers: [CAShapeLayer] = []
    var scaledImageRect: CGRect?
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let image = image {
            imageView.image = image
            
            guard let cgImage = image.cgImage else {
                return
            }
    
            calculateScaledImageRect()
            performVisionRequest(image: cgImage)
        }
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
            
            self.imageView.layer.sublayers = nil
            if let results = request?.results as? [VNFaceObservation] {
                
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
                        if let leftEyebrow = landmarks.leftEyebrow {
                            self.handleLandmark(leftEyebrow, faceBoundingBox: scaledObservationRect)
                        }
                        if let rightEye = landmarks.rightEye {
                            self.handleLandmark(rightEye, faceBoundingBox: scaledObservationRect)
                        }
                        if let rightEyebrow = landmarks.rightEyebrow {
                            self.handleLandmark(rightEyebrow, faceBoundingBox: scaledObservationRect)
                        }

                        if let nose = landmarks.nose {
                            self.handleLandmark(nose, faceBoundingBox: scaledObservationRect)
                        }

                        if let outerLips = landmarks.outerLips {
                            self.handleLandmark(outerLips, faceBoundingBox: scaledObservationRect)
                        }
                        if let innerLips = landmarks.innerLips {
                            self.handleLandmark(innerLips, faceBoundingBox: scaledObservationRect)
                        }
                    }
                }
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
//        landmarkPath.addLines(between: landmarkPathPoints)
//        landmarkPath.closeSubpath()
//        let landmarkLayer = CAShapeLayer()
//        landmarkLayer.path = landmarkPath
//        landmarkLayer.fillColor = UIColor.clear.cgColor
//        landmarkLayer.strokeColor = UIColor.green.cgColor
        
        // Draw the point
        let circlePath = UIBezierPath(arcCenter: landmarkPathPoints.first ?? CGPoint(x: 0, y: 0), radius: 3.0, startAngle: 0.0, endAngle: CGFloat(Double.pi * 2), clockwise: true)
         
         let shapeLayer = CAShapeLayer()
         shapeLayer.path = circlePath.cgPath
         shapeLayer.fillColor = UIColor.red.cgColor
         shapeLayer.strokeColor = UIColor.red.cgColor
         shapeLayer.lineWidth = 1.0
         
         view.layer.addSublayer(shapeLayer)

//        self.faceLayers.append(landmarkLayer)
//        self.view.layer.addSublayer(landmarkLayer)
        
        if let firstPoint = landmarkPathPoints.first {
              let convertedPoint = firstPoint
              let labelLayer = CATextLayer()
              labelLayer.string = "TEST"
              labelLayer.foregroundColor = UIColor.blue.cgColor
              labelLayer.fontSize = 12
              labelLayer.frame = CGRect(x: convertedPoint.x, y: convertedPoint.y, width: 50, height: 20)
              view.layer.addSublayer(labelLayer)
          }
    }
}

