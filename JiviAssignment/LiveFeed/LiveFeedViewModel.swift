//
//  LiveFeedViewModel.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 16/05/24.
//

import Foundation
import AVFoundation

class LiveFeedViewModel {
    
    var captureSession = AVCaptureSession()
    var captureDevice: AVCaptureDevice?
    var takePhoto: Bool = false
    
    var showDoneButton: (() -> Void)?
    var hideDoneButton: (() -> Void)?
    var goBack: (() -> Void)?
    var showPermissionAlert: (() -> Void)?
    var reload: (() -> Void)?
    
    func checkForCameraPermission() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            // Request
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                guard granted else {
                    DispatchQueue.main.async {
                        self?.showPermissionAlert?()
                    }
                    return
                }
            }
        case .restricted:
            self.goBack?()
        case .denied:
            self.showPermissionAlert?()
        case .authorized:
            print("Camera ready")
        @unknown default:
            break
        }
    }

    func checkIfCanAppend(withCount count: Int) -> Bool {
        if count >= 10 {
            return false
        } else {
            return true
        }
    }
    
}
