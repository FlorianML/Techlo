//
//  Appointment.swift
//  Techlo
//
//  Created by Florian on 11/8/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import Foundation

struct Appointment {
    
    var identifier: String?

    let uid: String
    let description: String
    let date: Date
    let videoUrl: String?
    let imageUrl: String?
    let location: String
    let quote: Int
    let response: AppointmentResponse?
    let responseTitle: String
    
    
    init(dictionary: [String: Any]) {
        self.uid = dictionary["uid"] as? String ?? ""
        self.description = dictionary["description"] as? String ?? ""
        self.imageUrl = dictionary["imageURL"] as? String
        self.quote = dictionary["quote"] as? Int ?? 0
        self.videoUrl = dictionary["videoURL"] as? String
        self.location = dictionary["location"] as? String ?? ""
        self.identifier = dictionary["identifier"] as? String
        let apptId = dictionary["status"] as? Int ?? 0
        self.response = AppointmentResponse(rawValue: apptId)
        self.responseTitle = dictionary["statusTitle"] as? String ?? ""
        
        let timeSince1970 =  dictionary["date"] as? TimeInterval ?? 0
        self.date = Date(timeIntervalSince1970: timeSince1970)
    }
}
