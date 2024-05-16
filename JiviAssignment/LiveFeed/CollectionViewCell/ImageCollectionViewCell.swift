//
//  ImageCollectionViewCell.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 16/05/24.
//

import Foundation
import UIKit

class ImageCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
    }
    
    func render(withImage image: UIImage) {
        reset()
        self.imageView.image = image
    }
    
    func reset() {
        self.imageView.image = nil
    }
}
