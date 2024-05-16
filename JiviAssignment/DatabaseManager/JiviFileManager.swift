//
//  JiviFileManager.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 17/05/24.
//

import Foundation
import UIKit

public class JiviFileManager: NSObject {
    
    @objc static public let shared = JiviFileManager()
    
    let fileManager = FileManager.default
    
    
    func saveImage(image: UIImage, imageFileName: String) {
        guard let data = image.jpegData(compressionQuality: 1.0) ?? image.pngData() else {
            return
        }
        
        let documentDirURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let modUrl = documentDirURL!.appendingPathComponent(imageFileName)
            .appendingPathExtension("png")
        
        do {
            try data.write(to: modUrl)
        } catch {
           print("error saving original")
        }
    }
}
