//
//  ResultModel.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 17/05/24.
//

import Foundation
import RealmSwift

class ResultModel: Object {
    @Persisted(primaryKey: true) dynamic var id: String
    @Persisted dynamic var imagePath: String?
    @Persisted dynamic var abnormalities: String?
    @Persisted dynamic var state: String?
}

class FaceResultModel {
    var id: String?
    var imagePath: String?
    var abnormalities: String?
    var state: String?
    
    init(id: String?, imagePath: String? = nil, abnormalities: String? = nil, state: String? = nil) {
        self.id = id
        self.imagePath = imagePath
        self.abnormalities = abnormalities
        self.state = state
    }
}
