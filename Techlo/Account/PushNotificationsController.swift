//
//  PushNotificationsController.swift
//  Techlo
//
//  Created by Florian on 4/2/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

class PushNotificationsController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        view.hideKeyboardWhenTappedAround()
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationItem.title = "Push Notifications"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        let pushSwitch = UISwitch()
        pushSwitch.isUserInteractionEnabled = true
        pushSwitch.onTintColor = ColorModel.returnNavyDark()
        pushSwitch.addTarget(self, action: #selector(toggleNotifications), for: .valueChanged)
        
        let switchLabel = UILabel()
        switchLabel.textColor = ColorModel.returnNavyDark()
        switchLabel.font = UIFont.systemFont(ofSize: 16, weight: .light)
        switchLabel.text = "Push Notifications"

        view.addSubview(pushSwitch)
        view.addSubview(switchLabel)
        
        switchLabel.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: pushSwitch.leftAnchor, topConstant: 25, leftConstant: 25, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        
        pushSwitch.anchor(view.topAnchor, left: switchLabel.rightAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 10, bottomConstant: 0, rightConstant: 25, widthConstant: 0, heightConstant: 0)

        view.bringSubviewToFront(pushSwitch)

    }
    
    @objc func toggleNotifications() {
        let defaults = UserDefaults.standard
        
        if defaults.bool(forKey: "notif") == false {
            defaults.set(true, forKey: "notif")
            UIApplication.shared.unregisterForRemoteNotifications()

        } else {
            defaults.set(false, forKey: "notif")
            UIApplication.shared.registerForRemoteNotifications()
        }
    }

}
