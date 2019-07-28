//
//  PhoneChangeController.swift
//  Techlo
//
//  Created by Florian on 11/13/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class PhoneChangeController: UIViewController, UITextFieldDelegate {
    
    var user: AppUser? {
        didSet {
            guard let user = user else { return }
            
            if  user.phone != "" {
                guard let phone = user.phone else { return }
                
                let attributedString = NSMutableAttributedString(string: "Current Number: \n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .light)])
                
                let areaCode = phone.prefix(3)
                let nextThree = phone.prefix(6).suffix(3)
                
                let addonString = NSAttributedString(string: "(\(areaCode)) \(nextThree) - \(phone.suffix(4))", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light)])
                
                let paragraphStyle = NSMutableParagraphStyle()
                paragraphStyle.alignment = .center
                paragraphStyle.lineSpacing = 4
                
                let range = NSMakeRange(0, attributedString.string.count)
                attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
                
                attributedString.append(addonString)
                
                phoneNumberLabel.attributedText = attributedString
            }
        }
    }
    
    var navigatedTo = false
    
    let phoneNumberLabel: UILabel = {
       let label = UILabel()
        label.text = "No linked phone number"
        label.textColor = ColorModel.returnNavyDark()
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    let phoneNumberTextField : UITextFieldX = {
        let textField = UITextFieldX()
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = ColorModel.returnGray()
        textField.becomeFirstResponder()
        textField.keyboardType = .phonePad
        textField.placeholder = "Enter new phone number"
        textField.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let submitButton : UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(changePhone), for: .touchUpInside)
        
        button.borderWidth = 1
        button.borderColor = UIColor(white: 1, alpha: 0.5)
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.cornerRadius = 10
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }

    func setupViews(){
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        view.backgroundColor = ColorModel.returnWhite()
        navigationItem.title = "Update Phone Number"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]

        view.hideKeyboardWhenTappedAround()
        
        let stackView = UIStackView(arrangedSubviews: [phoneNumberLabel, phoneNumberTextField, submitButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 14
        
        view.addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            stackView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 175)
        } else {
            // Fallback on earlier versions
            stackView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 175)
        }
        
        
    }
    
    @objc func changePhone(){
        
        guard let phone = phoneNumberTextField.text else {
            self.revealErrorAlert(title: "Sorry", subtitle: "Cannot change phone number at this time. Please try again later")
            return
        }
        guard let uid = Auth.auth().currentUser?.uid else {
            self.revealErrorAlert(title: "Sorry", subtitle: "Cannot change phone number at this time. Please try again later")
            return
        }
        
        let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
        
        ref.updateChildValues(["phone": phone])
        
        let areaCode = phone.prefix(3)
        let nextThree = phone.prefix(6).suffix(3)
        phoneNumberLabel.text = "(\(areaCode) \(nextThree) - \(phone.suffix(4))"
        
        revealPhoneUpdateAlert()
    }
    
    func revealPhoneUpdateAlert(){
        let banner = NotificationBanner(title: "Phone Updated", subtitle: "Phone number has been successfully saved", style: .success)
        banner.duration = 3.0
        banner.show()
        
        phoneNumberTextField.text?.removeAll()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissView()
        }
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
        
        phoneNumberTextField.text?.removeAll()
    }
    
    @objc func handleInputChange() {
        let isFormValid = phoneNumberTextField.text?.count ?? 0 > 9
        if isFormValid {
            submitButton.isEnabled = true
            submitButton.setTitleColor(.flatWhite(), for: .normal)
            submitButton.backgroundColor = ColorModel.returnNavyDark()
        } else {
            submitButton.isEnabled = false
            submitButton.setTitleColor(.lightGray, for: .normal)
            submitButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
