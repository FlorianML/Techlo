//
//  UIViewController+Helper.swift
//  Techlo
//
//  Created by Florian on 11/20/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import NotificationBannerSwift


extension UIViewController {
    
    @objc func dismissView(){
        self.navigationController?.popViewController(animated: true)
    }
    
    func setStatusBarStyle(_ style: UIStatusBarStyle) {
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = style == .lightContent ? UIColor.clear : ColorModel.returnWhite()
            statusBar.setValue(style == .lightContent ? ColorModel.returnWhite(): .black, forKey: "foregroundColor")
        }
    }
}
