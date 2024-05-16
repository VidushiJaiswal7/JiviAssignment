//
//  Extensions.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 16/05/24.
//

import Foundation
import UIKit


extension UICollectionView {
    public func dequeue<T: UICollectionViewCell>(cellForItemAt indexPath: IndexPath) -> T {
        return self.dequeueReusableCell(withReuseIdentifier: "\(T.self)", for: indexPath) as! T
    }
}
