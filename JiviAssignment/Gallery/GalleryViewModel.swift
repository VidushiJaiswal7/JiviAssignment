//
//  GalleryViewModel.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 16/05/24.
//

import Foundation
import Photos

class GalleryViewModel {
    
    func isGalleryPermissionGiven(completion: @escaping (Bool) -> Void) {
        // Get the current authorization state.
        let status = PHPhotoLibrary.authorizationStatus()

        if status == PHAuthorizationStatus.authorized {
            // Access has been granted.
            completion(true)
        } else if status == PHAuthorizationStatus.denied {
            // Access has been denied.
            completion(false)
        } else if status == PHAuthorizationStatus.notDetermined {
            PHPhotoLibrary.requestAuthorization({ (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            })
        } else if status == PHAuthorizationStatus.restricted {
            // Restricted access - normally won't happen.
            completion(false)
        }
    }
}
