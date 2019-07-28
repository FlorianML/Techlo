//
//  Note.swift
//  Techlo
//
//  Created by Florian on 11/8/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import Foundation

struct Note {
    
    var identifier: String?
    
    var uid: String
    let title: String
    let description: String
    let date: Date
    let videoUrl: String?
    let thumbnailUrl: String?
    
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.title = dictionary["title"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.thumbnailUrl = dictionary["imageURL"] as? String 
        self.videoUrl = dictionary["videoURL"] as? String
        self.identifier = dictionary["identifier"] as? String
        
        let timeSince1970 =  dictionary["date"] as? TimeInterval ?? 0
        self.date = Date(timeIntervalSince1970: timeSince1970)
    }
}

