//
//  NewAppointmentController.swift
//  Techlo
//
//  Created by Florian on 1/9/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//


import UIKit
import FSCalendar
import Firebase

class CalendarController: UIViewController, FSCalendarDelegate, FSCalendarDataSource {
    
    var appointments = [Appointment]()
    
    var passableAppointment: Appointment?
    
    lazy var calendar: FSCalendar = {
        let cal = FSCalendar()
        cal.allowsMultipleSelection = false
        cal.dataSource = self
        cal.delegate = self
        cal.allowsSelection = true
        cal.backgroundColor = ColorModel.returnWhite()
        cal.appearance.headerTitleColor = UIColor.flatRedColorDark()
        cal.appearance.weekdayTextColor = UIColor.flatRedColorDark()
        cal.appearance.eventDefaultColor = UIColor.flatRedColorDark()
        cal.today = nil
        cal.appearance.headerTitleFont = UIFont.systemFont(ofSize: 16, weight: .light)
        cal.appearance.selectionColor = ColorModel.returnNavyDark()
        return cal
    }()
    
    let menuContainerView: UIView = {
     let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 10
        view.backgroundColor = ColorModel.returnNavyDark()

        let apptInfoButton = UIButton(type: .system)
        apptInfoButton.setTitle("Appointment Details", for: .normal)
        apptInfoButton.backgroundColor = ColorModel.returnWhite()
        apptInfoButton.layer.cornerRadius = 10
        apptInfoButton.clipsToBounds = true
        apptInfoButton.addTarget(self, action: #selector(apptDetailsAction), for: .touchUpInside)
        apptInfoButton.setTitleColor(ColorModel.returnNavyDark(), for: .normal)

        let editApptButton = UIButton(type: .system)
        editApptButton.setTitle("Change Date & Location", for: .normal)
        editApptButton.backgroundColor = ColorModel.returnWhite()
        editApptButton.layer.cornerRadius = 10
        editApptButton.clipsToBounds = true
        editApptButton.addTarget(self, action: #selector(editApptAction), for: .touchUpInside)
        editApptButton.setTitleColor(ColorModel.returnNavyDark(), for: .normal)
        
        view.addSubview(apptInfoButton)
        view.addSubview(editApptButton)
        
        let height = (view.frame.height - 20)/2
        editApptButton.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: height)
        
        apptInfoButton.anchor(nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 10, rightConstant: 10, widthConstant: 0, heightConstant: height)
        
        return view
    }()
    
    var backupContainer = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        fetchAppointments()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func setupViews() {
        view.backgroundColor = ColorModel.returnWhite()
    
        navigationItem.title = "Appointments"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        view.addSubview(calendar)
        
        if #available(iOS 11.0, *) {
            calendar.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.size.height * 0.80)
        } else {
            calendar.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10 , leftConstant: 10, bottomConstant: 0, rightConstant: 10, widthConstant: 0, heightConstant: view.frame.size.height * 0.8)
        }

    }
    
    @objc func apptDetailsAction(){
        let appointmentDetailsController = AppointmentDetailsController()
        appointmentDetailsController.appointment = passableAppointment
        self.navigationController?.pushViewController(appointmentDetailsController, animated: true)
    }
    
    @objc func editApptAction(){
        let editAppointmentController = EditAppointmentController()
        editAppointmentController.appointment = passableAppointment
        self.navigationController?.pushViewController(editAppointmentController, animated: true)
        
    }
    
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let cell = calendar.cell(for: date, at: monthPosition)
        if cell?.numberOfEvents ?? 0 > 0 && cell?.monthPosition == .current {
            return true
        }
        return false
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let cell = calendar.cell(for: date, at: monthPosition)
        
        if cell?.numberOfEvents ?? 0 > 0 {
            passableAppointment = appointments.first(where: { (appointment) -> Bool in
                if Calendar.current.isDate(date, inSameDayAs: appointment.date) && appointment.date.timeIntervalSince1970 > Date().timeIntervalSince1970 {
                    closeOptionMenu(date: date)
                    return true
                }
                return false
            })
        }
    }
    
    func calendar(_ calendar: FSCalendar, didDeselect date: Date, at monthPosition: FSCalendarMonthPosition) {
        passableAppointment = nil
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
    
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        closeOptionMenu()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date().startOfMonth()

    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
       return Date().getNextMonth()
    }
    
    func alertForNoAppointments(){
        if appointments.count == 0 {
            let alert = UIAlertController(title: "No Appointments", message: "You have not set up an appointment\n yet. Would you like to set up an \nappointment?", preferredStyle: .alert)
            
            let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
                self.navigationController?.popViewController(animated: true)
            }
            
            let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
                self.navigationController?.popToRootViewController(animated: true)
            }
            
            alert.addAction(noAction)
            alert.addAction(yesAction)
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    var optionsOpened = false
    
     func openOptionsMenu(date: Date, month: FSCalendarMonthPosition) {
        guard let cell = calendar.cell(for: date, at: month) else { return }
    
            view.addSubview(menuContainerView)
            menuContainerView.alpha = 0
            let calendarWidth = calendar.frame.size.width
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "dd"
            
            if let day = Int(dateFormatter.string(from: date)), day < 15 {
                menuContainerView.anchor(cell.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: calendarWidth * 0.7, heightConstant: 90)
            } else  {
                menuContainerView.anchor(nil, left: nil, bottom: cell.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: calendarWidth * 0.7, heightConstant: 90)
            }
            menuContainerView.anchorCenterXToSuperview()
            
            UIView.animate(withDuration: 0.3) {
                self.menuContainerView.alpha = 1
                self.optionsOpened = true
        }
    }
    
    func closeOptionMenu(){
        UIView.animate(withDuration: 0.3, animations: {
            self.menuContainerView.alpha = 0
        }) { _ in
            self.menuContainerView.removeFromSuperview()
            self.optionsOpened = false
        }
    }

    func closeOptionMenu(date: Date){
        if optionsOpened == true && menuContainerView.superview == nil {
            UIView.animate(withDuration: 0.3, animations: {
                self.backupContainer.alpha = 0
            }) { _ in
                self.backupContainer.removeFromSuperview()
                self.optionsOpened = false
                self.openOptionsMenu(date: date, month: .current)
            }
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.menuContainerView.alpha = 0
            }) { _ in
                self.menuContainerView.removeFromSuperview()
                self.optionsOpened = false
                self.openOptionsMenu(date: date, month: .current)
            }
        }
    }
    
    func fetchAppointments(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid)
        
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            
            if !snapshot.exists() {
                self.alertForNoAppointments()
            }
            
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
}

