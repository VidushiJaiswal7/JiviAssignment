//
//  ResultsViewController.swift
//  JiviAssignment
//
//  Created by Vidushi Jaiswal on 15/05/24.
//

import Foundation
import UIKit

class ResultsViewControllerFactory: NSObject {
    class func produce() -> ResultsViewController {
        let resultsVC = ResultsViewController(nibName: "ResultsViewController",
                                               bundle: nil)
        return resultsVC
    }
}

class ResultsViewController: UIViewController {
    
}
