//
//  EditAppointmentController.swift
//  Techlo
//
//  Created by Florian on 1/12/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import GooglePlaces
import Firebase
import NotificationBannerSwift

class EditAppointmentController: ViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    var appointment: Appointment? {
        didSet {
            guard let appointment = appointment else { return }
            
            let date = appointment.date
            
//            let dateFormatter = DateFormatter()
//            dateFormatter.dateStyle = .long
            
            let timeFormatter = DateFormatter()
            timeFormatter.amSymbol = "am"
            timeFormatter.pmSymbol = "pm"
            timeFormatter.timeStyle = .short
            
            let timeString = timeFormatter.string(from: date)
            
            timeTextField.placeholder = "Appointment Time: \(timeString)"
            locationTextField.placeholder = "Location: \(appointment.location)"
            
           // calendar.select(date)
            calendar.select(date, scrollToDate: true)
            calendar.deselect(date)
            calendar.today = date
            
        }
    }

    lazy var calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.allowsMultipleSelection = false
        cal.dataSource = self
        cal.delegate = self
        cal.allowsSelection = true
        cal.appearance.headerTitleColor = UIColor.flatRedColorDark()
        cal.appearance.weekdayTextColor = UIColor.flatRedColorDark()
        cal.appearance.titleWeekendColor = ColorModel.returnNavyDark()
        cal.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .light)
        cal.appearance.todaySelectionColor = UIColor.flatRedColorDark()
        cal.today = nil
        cal.appearance.selectionColor = ColorModel.returnNavyDark()
        return cal
    }()
    
    lazy var timeTextField : DateTimeTextField = {
        let textField = DateTimeTextField(pickerType: .time)
        textField.backgroundColor = ColorModel.returnGray()
        textField.addTarget(self, action: #selector(enableEditButton), for: .editingChanged)
        textField.leftPadding = 5
        textField.attributedPlaceholder = NSAttributedString(string: " Enter Time", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    lazy var locationTextField: UITextFieldX = {
        let textField = UITextFieldX()
        textField.backgroundColor = ColorModel.returnGray()
        textField.tag = 100
        textField.textColor = .black
        textField.attributedPlaceholder = NSAttributedString(string: " Select an appointment location", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.leftPadding = 5
        textField.delegate = self
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.addTarget(self, action: #selector(enableEditButton), for: .editingChanged)
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Edit", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.setTitleColor(ColorModel.returnGray(), for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(editButtonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    
    override func setupViews() {
        super.setupViews()

        view.addSubview(calendar)
        view.addSubview(timeTextField)
        view.addSubview(locationTextField)
        view.addSubview(editButton)
        
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationItem.title = "Edit Appointment"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        if #available(iOS 11.0, *) {
            calendar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.size.height * 0.5)
        } else {
            calendar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0 , leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.size.height * 0.5)
        }
        
        timeTextField.anchor(calendar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 48)
        
        locationTextField.anchor(timeTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 48)
        
        editButton.anchor(locationTextField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 40, rightConstant: 0, widthConstant: 200, heightConstant: 60)
        editButton.anchorCenterXToSuperview()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        let date = Date().addingTimeInterval((86400 * 1))
        return date
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        let date = Date().addingTimeInterval((86400 * 30))
        return date
    }
    
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        print("did select date: ", date)
        
    }
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        print("page changed")
    }
    
    var changedDate = false
    var changedTime = false
    var changedLocation = false
    
    @objc func enableEditButton(){
        let isValid = ( calendar.selectedDate != nil || timeTextField.text?.count ?? 0 > 0 || locationTextField.text?.count ?? 0 > 0)
        
        if isValid {
            editButton.isEnabled = true
            editButton.backgroundColor = ColorModel.returnNavyDark()
            editButton.setTitleColor(ColorModel.returnWhite(), for: .normal)
            
            changedDate = calendar.selectedDate != nil
            changedTime = timeTextField.text?.count ?? 0 > 0
            changedLocation = locationTextField.text?.count ?? 0 > 0
            
        } else {
            editButton.isEnabled = false
            editButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
            editButton.setTitleColor(ColorModel.returnGray(), for: .normal)
        }
    }
    
    @objc func editButtonAction() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let id = appointment?.identifier else { return }
        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(id)
        let masterRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(id)
        
        showLoading(state: true)
        if changedDate && changedTime || changedTime || changedDate {
            guard let date = calendar.selectedDate else { return }
            guard let timeInt = timeTextField.selectedDateOrTime else { return }
            guard let completeDate = date.combineDateWithTime(time: timeInt) else { return }
            
            ref.updateChildValues(["date": completeDate.timeIntervalSince1970])
            masterRef.updateChildValues(["date": completeDate.timeIntervalSince1970])
        }

        if changedLocation {
            guard let locationText = locationTextField.text else { return }
            ref.updateChildValues(["location": locationText])
            masterRef.updateChildValues(["location": locationText])
        }
        
        ref.updateChildValues(["status": 0, "statusTitle": AppointmentResponseTitle.pending.rawValue])
        masterRef.updateChildValues(["status": 0, "statusTitle": AppointmentResponseTitle.pending.rawValue])
        
        self.showLoading(state: false)
        self.revealAppointmentUpdateAlert()
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    func revealAppointmentUpdateAlert(){
        let banner = NotificationBanner(title: "Appointment Changed", subtitle: "Appointment changes will now be reviewed", style: .success)
        banner.subtitleLabel?.textAlignment = .center
        banner.titleLabel?.textAlignment = .center
        banner.titleLabel?.numberOfLines = 0
        banner.duration = 3.0
        banner.show()
        self.dismiss(animated: true, completion: nil)
    }

}

extension EditAppointmentController : UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let address = "\(place.formattedAddress?.dropLast().dropLast().dropLast().dropLast().dropLast() ?? "")"
        self.locationTextField.text = address
        enableEditButton()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Could not complete location search:", error)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func didRequestAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
    }
    
    func didUpdateAutocompletePredictions(_ viewController: GMSAutocompleteViewController) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
    }
    
    func presentController(controller: UIViewController){
        if controller.isKind(of: GMSAutocompleteViewController.self){
            guard let gmsController = controller as? GMSAutocompleteViewController else { return }
            gmsController.delegate = self
        }
        self.present(controller, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.tag == 100 {
            let autocompleteController = GMSAutocompleteViewController()
            autocompleteController.delegate = self
            self.present(autocompleteController, animated: true, completion: nil)
        }
        
    }
}
