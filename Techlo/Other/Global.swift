//
//  Global.swift
//  Techlo
//
//  Created by Florian on 11/9/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

enum AppointmentResponse: Int {
    case pendingSpecialistApproval = 0
    case pendingForCustomerApproval = 1
    case specialistApproved = 2
    case customerApproved = 3
    case specialistDenied = 4
    case customerDenied = 5
    case specialistCancelled = 6
    case customerCancelled = 7
    case appointmentCompleted = 8
    case contactRequested = 9
    case appointmentChanged = 10
}

enum AppointmentResponseTitle: String {
    case pending = "Pending Review"
    case pendingForCustomerApproval = "Needing Customer Approval"
    case approved = "Appointment Approved"
    case denied = "Appointment Denied"
    case customerDenied = "Customer Denied"
    case cancelled = "Appointment Cancelled"
    case completed = "Appointment Completed"
    case contactRequested = "Contact Requested"
    case appointmentChanged = "Appointment Request Pending"
}

enum DropDownCellTitle: String {
    case approve = "Approve Appointment"
    case denied = "Deny Appointment"
    case cancelled = "Cancel Appointment"
    case request = "Change Appointment Information"
    case contact = "Contact Specialist"
}

enum AccountType: String {
    case email = "email"
    case google = "google"
    case facebook = "facebook"
    case null = "null"
}

enum TabName: String {
    case appointment = "Appointments"
    case library = "Library"
}

enum FirebaseKey: String {
    case appointment = "appointments"
    case user = "users"
    case note = "notes"
    case attachment = "attachments"
    case master = "master-list"
    case customer = "stripe_customers"
    case source = "sources"
    case charge = "charges"
}



