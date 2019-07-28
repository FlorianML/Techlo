//
//  UiNavigationControllerExtension.swift
//  VC
//
//  Created by Florian on 1/16/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

extension UIAlertController {
    
    class func alertWithIncludedDismissAction(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(okAction)
        return alert
    }
    
    class func alertWithAddedAction(title: String, message: String, action: UIAlertAction) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "No", style: .cancel) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        alert.addAction(action)
        return alert
    }
}



