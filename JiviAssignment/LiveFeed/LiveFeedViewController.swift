//
//  LiveFeedViewController.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 15/05/24.
//

import Foundation
import UIKit

class LiveFeedViewControllerFactory: NSObject {
    class func produce() -> LiveFeedViewController {
        let liveFeedVC = LiveFeedViewController(nibName: "LiveFeedViewController",
                                                     bundle: nil)
        return liveFeedVC
    }
}

class LiveFeedViewController: UIViewController {
    
}
