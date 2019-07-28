//
//  DateTimeTextField.swift
//  VC
//
//  Created by Florian on 1/27/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

class DateTimeTextField: UITextFieldX {
    
    var controller: CreateAppointmentController?
    
    let picker : UIDatePicker = {
        let pk = UIDatePicker()
        pk.addTarget(self, action: #selector(datePickerChanged), for: .valueChanged)
        return pk
    }()
    
    var selectedDateOrTime: Date?
    
    enum PickerSelection: String {
        case date = "Date"
        case time = "Time"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(pickerType: PickerSelection) {
        self.init()
        self.placeholder = pickerType.rawValue
        self.backgroundColor = ColorModel.returnGray()
        self.textAlignment = .left
        self.translatesAutoresizingMaskIntoConstraints = false
     //   self.borderStyle = .roundedRect
        self.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        self.setupPicker(pickerType: pickerType)
        self.createToolbarForPicker(pickerType: pickerType)
        
    }
        
    fileprivate func setupPicker(pickerType: PickerSelection) {
        self.inputView = picker
        switch pickerType {
        case .date:
            picker.datePickerMode = .date
        case .time:
            picker.datePickerMode = .time
        }
    }
    @objc func datePickerChanged() {
        let formatter = DateFormatter()
        
        if picker.datePickerMode == UIDatePicker.Mode.date {
            formatter.dateStyle = .long
            formatter.timeStyle = .none
        } else {
            formatter.dateStyle = .none
            formatter.timeStyle = .short
        }
        
        self.selectedDateOrTime = picker.date
        self.text = formatter.string(from: picker.date)
        controller?.enableNextButton()
    }
    
    @objc func donePressed() {
        self.resignFirstResponder()
        datePickerChanged()
    }
    
    fileprivate func createToolbarForPicker(pickerType: PickerSelection){
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 40))
        toolbar.barStyle = UIBarStyle.default
        toolbar.tintColor = UIColor.black
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.done, target: self, action: #selector(donePressed))
        
        let flexButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: self, action: nil)
        
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width/3, height: 40))
        label.font = UIFont.systemFont(ofSize: 17, weight: .light)
        label.padding = UIEdgeInsets(top: -6, left: 0, bottom: 0, right: 0)
        label.textColor = .black
        label.textAlignment = NSTextAlignment.center
        label.text = "Select a \(pickerType.rawValue)"
        
        let labelButton = UIBarButtonItem(customView: label)
        
        toolbar.setItems([flexButton , flexButton, labelButton, flexButton, doneButton], animated: true)
        
        self.inputAccessoryView = toolbar
    }
}

