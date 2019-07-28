//
//  User.swift
//  Techlo
//
//  Created by Florian on 11/8/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

enum AccountProperty: String {
    case name = "name"
    case email = "email"
    case password = "password"
    case phone = "phone"
    case aptAmount = "aptAmount"
    case last4 = "last4"
    case fcmToken = "fcmToken"
    case accountType = "accountType"
    case paymentSourceId = "paymentSource"
}

struct AppUser {
    
    var accountType: AccountType?
    
    var name: String
    let uid: String
    var email: String
    var password: String?
    var phone: String?
    var aptAmount: Int
    var last4: String?
    var fcmToken: String
    
    init(uid: String, dictionary: [String: Any]) {
        self.uid = uid
        self.name = dictionary[AccountProperty.name.rawValue] as? String ?? ""
        self.email = dictionary[AccountProperty.email.rawValue] as? String ?? ""
        self.password = dictionary[AccountProperty.password.rawValue] as? String ?? ""
        self.phone = dictionary[AccountProperty.phone.rawValue] as? String
        self.aptAmount = dictionary[AccountProperty.aptAmount.rawValue] as? Int ?? 0
        self.last4 = dictionary[AccountProperty.last4.rawValue] as? String
        self.fcmToken = dictionary[AccountProperty.fcmToken.rawValue] as? String ?? ""
        
        let accountTypeString = dictionary[AccountProperty.accountType.rawValue] as? String ?? ""
        if let type = AccountType(rawValue: accountTypeString) {
            self.accountType = type
        }
    }
}

