//
//  RealmManager.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 17/05/24.
//

import Foundation
import RealmSwift

public class RealmManager: NSObject {
        
    let realm = try! Realm()
    
    func saveResults(withImage image: UIImage?,
                     withAbnormalities abnormalities: String?,
                     withState state: String?) {
        
        let imageName = UUID().uuidString
        if let image = image {
            JiviFileManager.shared.saveImage(image: image, imageFileName: imageName)
        }
        
        let result = ResultModel()
        result.id = UUID().uuidString
        result.imagePath = imageName
        result.abnormalities = abnormalities
        result.state = state
        
        try! self.realm.write {
            self.realm.add(result)
        }
        
    }
}
