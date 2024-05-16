//
//  LiveFeedViewController.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 15/05/24.
//

import AVFoundation
import Foundation
import UIKit
import Vision

class LiveFeedViewControllerFactory: NSObject {
    class func produce() -> LiveFeedViewController {
        let liveFeedVC = LiveFeedViewController(nibName: "LiveFeedViewController",
                                                     bundle: nil)
        return liveFeedVC
    }
}

class LiveFeedViewController: UIViewController {
    @IBOutlet weak var videoLayer: UIView!
    
    @IBOutlet weak var proceedButton: UIButton!
    @IBOutlet weak var captureButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    private let captureSession = AVCaptureSession()
    private lazy var previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
    private let videoDataOutput = AVCaptureVideoDataOutput()
    private var faceLayers: [CAShapeLayer] = []
    
    private var viewModel = LiveFeedViewModel()
    
    var images: [UIImage] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCells()
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
        
        setupViewModel()
        viewModel.checkForCameraPermission()
        
        setupCamera()
        captureSession.startRunning()
    }
    
    private func registerCells() {
        collectionView.register(UINib(nibName: "ImageCollectionViewCell", bundle: nil),
                                forCellWithReuseIdentifier: "ImageCollectionViewCell")
    }

    private func setupViewModel() {
        viewModel = LiveFeedViewModel()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.previewLayer.frame = self.videoLayer.bounds
    }
    
    @IBAction func proceedPressed(_ sender: Any) {
        if images.count > 0 {
            // show results
            let resultsVC = ResultsViewControllerFactory.produce(withImages: images)
            self.navigationController?.pushViewController(resultsVC, animated: true)
        } else {
            // show alert 
        }
    }
    
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func capturePressed(_ sender: Any) {
        viewModel.takePhoto = true
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func setupCamera() {
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: .video, position: .front)
        if let device = deviceDiscoverySession.devices.first {
            if let deviceInput = try? AVCaptureDeviceInput(device: device) {
                if captureSession.canAddInput(deviceInput) {
                    captureSession.addInput(deviceInput)
                    
                    setupPreview()
                }
            }
        }
    }
    
    private func setupPreview() {
        self.previewLayer.videoGravity = .resizeAspectFill
        self.videoLayer.layer.addSublayer(self.previewLayer)
        self.previewLayer.frame = self.videoLayer.frame
        
        self.videoDataOutput.videoSettings = [(kCVPixelBufferPixelFormatTypeKey as NSString) : NSNumber(value: kCVPixelFormatType_32BGRA)] as [String : Any]

        self.videoDataOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "camera queue"))
        self.captureSession.addOutput(self.videoDataOutput)
        
        let videoConnection = self.videoDataOutput.connection(with: .video)
        videoConnection?.videoOrientation = .portrait
    }
    
    private func showPermissionAlert(isForGallery: Bool) {
        var subtitleString = "Looks like you’ve denied Camera access. Please allow access from iPhone ⚙️ Settings"
        if isForGallery {
            subtitleString = "Looks like you’ve denied Gallery access. Please allow access from iPhone ⚙️ Settings"
        }
        let subtitle = NSMutableAttributedString(string: subtitleString)
    }
}

extension LiveFeedViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
        guard let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
          return
        }

        let faceDetectionRequest = VNDetectFaceLandmarksRequest(completionHandler: { (request: VNRequest, error: Error?) in
            DispatchQueue.main.async {
                self.faceLayers.forEach({ drawing in drawing.removeFromSuperlayer() })

                if let observations = request.results as? [VNFaceObservation] {
                    self.handleFaceDetectionObservations(observations: observations)
                }
            }
        })

        let imageRequestHandler = VNImageRequestHandler(cvPixelBuffer: imageBuffer, orientation: .leftMirrored, options: [:])

        do {
            try imageRequestHandler.perform([faceDetectionRequest])
        } catch {
          print(error.localizedDescription)
        }
        
        if viewModel.takePhoto {
            viewModel.takePhoto = false
            if let image = self.getImageFromSampleBuffer(buffer: sampleBuffer) {
                if self.viewModel.checkIfCanAppend(withCount: images.count) {
                    self.images.append(image)
                }
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    self.collectionView.scrollToItem(at: IndexPath(row: self.collectionView
                        .numberOfItems(inSection: 0) - 1, section: 0),
                                                     at: .right,
                                                     animated: true)
                }
            }
        }
    }
    
    private func handleFaceDetectionObservations(observations: [VNFaceObservation]) {
        if observations.count > 0 {
            captureButton.isEnabled = true
        } else {
            captureButton.isEnabled = false 
        }
        for observation in observations {
            let faceRectConverted = self.previewLayer.layerRectConverted(fromMetadataOutputRect: observation.boundingBox)
            let faceRectanglePath = CGPath(rect: faceRectConverted, transform: nil)
            
            let faceLayer = CAShapeLayer()
            faceLayer.path = faceRectanglePath
            faceLayer.fillColor = UIColor.clear.cgColor
            faceLayer.strokeColor = UIColor.yellow.cgColor
            
            self.faceLayers.append(faceLayer)
            self.videoLayer.layer.addSublayer(faceLayer)
            
            //FACE LANDMARKS
            if let landmarks = observation.landmarks {
                if let leftEye = landmarks.leftEye {
                    self.handleLandmark(leftEye, faceBoundingBox: faceRectConverted)
                }
                if let leftEyebrow = landmarks.leftEyebrow {
                    self.handleLandmark(leftEyebrow, faceBoundingBox: faceRectConverted)
                }
                if let rightEye = landmarks.rightEye {
                    self.handleLandmark(rightEye, faceBoundingBox: faceRectConverted)
                }
                if let rightEyebrow = landmarks.rightEyebrow {
                    self.handleLandmark(rightEyebrow, faceBoundingBox: faceRectConverted)
                }

                if let nose = landmarks.nose {
                    self.handleLandmark(nose, faceBoundingBox: faceRectConverted)
                }

                if let outerLips = landmarks.outerLips {
                    self.handleLandmark(outerLips, faceBoundingBox: faceRectConverted)
                }
                if let innerLips = landmarks.innerLips {
                    self.handleLandmark(innerLips, faceBoundingBox: faceRectConverted)
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
        landmarkPath.addLines(between: landmarkPathPoints)
        landmarkPath.closeSubpath()
        let landmarkLayer = CAShapeLayer()
        landmarkLayer.path = landmarkPath
        landmarkLayer.fillColor = UIColor.clear.cgColor
        landmarkLayer.strokeColor = UIColor.green.cgColor

        self.faceLayers.append(landmarkLayer)
        self.videoLayer.layer.addSublayer(landmarkLayer)
    }
    
    private func getImageFromSampleBuffer(buffer: CMSampleBuffer) -> UIImage? {
        if let pixelBuffer = CMSampleBufferGetImageBuffer(buffer) {
            let ciImage = CIImage(cvImageBuffer: pixelBuffer)
            
            let imageContext = CIContext()
            let imageRect = CGRect(x: 0,
                                   y: 0,
                                   width: CVPixelBufferGetWidth(pixelBuffer),
                                   height: CVPixelBufferGetHeight(pixelBuffer))
            
            if let image = imageContext.createCGImage(ciImage,
                                                      from: imageRect) {
                return UIImage(cgImage: image,
                               scale: UIScreen.main.scale,
                               orientation: .up)
                
            }
        }
        return nil
    }
}


extension LiveFeedViewController: UICollectionViewDelegate,
                                UICollectionViewDataSource,
                                UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView,
                               numberOfItemsInSection section: Int) -> Int {
        return self.images.count
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeue(cellForItemAt: indexPath)
        
        if images.count > indexPath.item {
            let image = images[indexPath.item]
            cell.render(withImage: image)
        }
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 106, height: 120)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

