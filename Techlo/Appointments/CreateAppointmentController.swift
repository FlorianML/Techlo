//
//  CreateAppointmentController.swift
//  Techlo
//
//  Created by Florian on 1/9/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import FSCalendar
import GooglePlaces
import Firebase

class CreateAppointmentController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    var appointments = [Appointment]()
    
    lazy var calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.allowsMultipleSelection = false
        cal.dataSource = self
        cal.delegate = self
        cal.allowsSelection = true
        cal.appearance.headerTitleColor = UIColor.flatRedColorDark()
        cal.appearance.weekdayTextColor = UIColor.flatRedColorDark()
        cal.appearance.eventDefaultColor = UIColor.flatRedColorDark()
        cal.appearance.titleWeekendColor = ColorModel.returnNavyDark()
        cal.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .light)
        cal.today = nil
        cal.appearance.selectionColor = ColorModel.returnNavyDark()
        return cal
    }()
    
    lazy var timeTextField : DateTimeTextField = {
        let textField = DateTimeTextField(pickerType: .time)
        textField.backgroundColor = ColorModel.returnGray()
        textField.addTarget(self, action: #selector(enableNextButton), for: .editingChanged)
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
        textField.addTarget(self, action: #selector(enableNextButton), for: .editingChanged)
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let nextButton: UIButton = {
       let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.setTitleColor(ColorModel.returnGray(), for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchAppointments()

    }

    func setupViews() {
        view.backgroundColor = ColorModel.returnWhite()
        view.addSubview(calendar)
        view.addSubview(timeTextField)
        view.addSubview(locationTextField)
        view.addSubview(nextButton)
    
        navigationItem.title = "Setup Appointment"
        
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        if #available(iOS 11.0, *) {
            calendar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.size.height * 0.45)
        } else {
            calendar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10 , leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.size.height * 0.45)
        }
        
        timeTextField.anchor(calendar.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 48)
        
        locationTextField.anchor(timeTextField.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 48)
        
        nextButton.anchor(locationTextField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 50, rightConstant: 0, widthConstant: 200, heightConstant: 60)
        nextButton.anchorCenterXToSuperview()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        let date = Date().addingTimeInterval((86400 * 1))
        return date
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        let date = Date().addingTimeInterval((86400 * 30))
        return date
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let cell = calendar.cell(for: date, at: monthPosition)
        if let events = cell?.numberOfEvents {
            if events > 0 {
                self.alertForPreviousAppointment()
                return false
            } else if cell?.monthPosition != .current {
                return false
            }
        }
        return true
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        enableNextButton()
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        var events = 0
        appointments.forEach { (appointment) in
            if Calendar.current.isDate(date, inSameDayAs: appointment.date) && appointment.date.timeIntervalSince1970 > Date().timeIntervalSince1970 && appointment.response!.rawValue != 7 && appointment.response!.rawValue != 5 {
                events = 1
            }
        }
        return events
    }
    
    @objc func enableNextButton(){
        let isValid = ( calendar.selectedDate != nil && timeTextField.text?.count ?? 0 > 0 && locationTextField.text?.count ?? 0 > 0)
        
        if isValid {
            nextButton.isEnabled = true
            nextButton.backgroundColor = ColorModel.returnNavyDark()
            nextButton.setTitleColor(ColorModel.returnWhite(), for: .normal)
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
            nextButton.setTitleColor(ColorModel.returnGray(), for: .normal)
        }
    }
    
    @objc func nextButtonAction() {
        let completeAppointmentController = CompleteAppointmentController()
        passOnValues { (values) in
            completeAppointmentController.previousValues = values
        }
        
        self.navigationController?.pushViewController(completeAppointmentController, animated: true)
    }
    
    func passOnValues(completion: @escaping ([String: Any]) -> ()){
        guard let locationText = locationTextField.text else { return }
        guard let date = calendar.selectedDate else { return }
        guard let timeInt = timeTextField.selectedDateOrTime else { return }
        guard let completeDate = date.combineDateWithTime(time: timeInt) else { return }
                
        let values = ["location": locationText, "date": completeDate.timeIntervalSince1970, "status": 0, "statusTitle": AppointmentResponseTitle.pending.rawValue] as [String: Any]
        
        completion(values)
    }
    
    func fetchAppointments(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in

            guard let dictionaries = snapshot.value as? [String: Any] else { return }
            dictionaries.forEach({ (key, value) in
                guard let dictionary = value as? [String: Any] else { return }
                let appointment = Appointment(dictionary: dictionary)
                self.appointments.append(appointment)

            })
            self.calendar.reloadData()
            
        }) { (err) in
            print("Failed to fetch appointments: ", err)
        }
    }
    
    func alertForPreviousAppointment(){
        let alert = UIAlertController.alertWithIncludedDismissAction(title: "Cannot Select Date", message: "You already have an appointment\n that day. Please pick another date.")
        self.present(alert, animated: true, completion: nil)
    }
}

extension CreateAppointmentController : UITextFieldDelegate, GMSAutocompleteViewControllerDelegate {
    
    func viewController(_ viewController: GMSAutocompleteViewController, didAutocompleteWith place: GMSPlace) {
        let address = "\(place.formattedAddress?.dropLast().dropLast().dropLast().dropLast().dropLast() ?? "")"
        self.locationTextField.text = address
        enableNextButton()
        self.navigationController?.navigationBar.isHidden = false
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func viewController(_ viewController: GMSAutocompleteViewController, didFailAutocompleteWithError error: Error) {
        print("Could not complete location search:", error)
    }
    
    func wasCancelled(_ viewController: GMSAutocompleteViewController) {
        self.navigationController?.navigationBar.isHidden = false
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
            autocompleteController.edgesForExtendedLayout = .all
            self.navigationController?.navigationBar.isHidden = true
            self.present(autocompleteController, animated: true, completion: nil)
        }
    }
}
