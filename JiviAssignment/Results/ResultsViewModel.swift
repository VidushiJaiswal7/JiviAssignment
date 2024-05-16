//
//  ResultsViewModel.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 16/05/24.
//

import Foundation
import UIKit

class ResultsViewModel {
    
    // MARK: Properties
    var selectedAbnormalities: [String] = []
    var state: String?
    
    // MARK: Init
    var abmornmalities: [String] = ["Firmness", "Wrinkles", "Spots", "Pigmentation", "Acne", "Pores", "Redness", "Patches", "Dullness"]
    
    func saveImage(image: UIImage) {
        RealmManager().saveResults(withImage: image,
                                   withAbnormalities: selectedAbnormalities.joined(separator: ","),
                                   withState: state)
        
    }
    
    func reset() {
        state = nil
        selectedAbnormalities = []
    }
}
    
