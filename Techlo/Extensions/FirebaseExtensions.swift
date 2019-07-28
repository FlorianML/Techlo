//
//  FirebaseExtensions.swift
//  Techlo
//
//  Created by Florian on 12/3/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import Firebase

extension Database {
    
    static func fetchUserWithUID(uid: String, completion: @escaping (AppUser) -> ()) {
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value, with: { (snapshot) in
            
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            let user = AppUser(uid: uid, dictionary: userDictionary)
            completion(user)
            
        }) { (err) in
            print("Failed to fetch user for posts:", err)
        }
    }
    
    static func checkToSeeIfDataExists(ref: DatabaseReference) -> Bool {
        var result = false
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.exists()) {
                result = true
            }
            result =  false
        }
        return result
    }
}
