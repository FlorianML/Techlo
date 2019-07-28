//
//  EmailChangeController.swift
//  LemonadeStand
//
//  Created by Florian on 4/2/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import ValidationComponents
import ValidationToolkit
import Firebase
import NotificationBannerSwift


class EmailChangeController: UIViewController, UITextFieldDelegate {
    
    var user: AppUser? {
        didSet {
            guard let user = user else { return }
            let attributedString = NSMutableAttributedString(string: "Current Email: \n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .light)])
            let addOnString = NSAttributedString(string: user.email, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light)])
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 4
            
            let range = NSMakeRange(0, attributedString.string.count)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
            attributedString.append(addOnString)
            
            currentEmailLabel.attributedText = attributedString
        }
    }
    
    let currentEmailLabel: UILabel = {
        let label = UILabel()
        label.text = "Current Email: \nflorian.laplanche@gmail.com"
        label.numberOfLines = 0
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.textColor = .black
        return label
    }()
    
    let newEmailTextField: UITextFieldX = {
        let field = UITextFieldX()
        field.borderStyle = .roundedRect
        field.backgroundColor = ColorModel.returnGray()
        field.textColor = .black
        field.returnKeyType = .done
        field.font = UIFont.systemFont(ofSize: 15, weight: .light)
        field.placeholder = "Enter new email"
        field.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        field.becomeFirstResponder()
        
        field.shadowColor = .darkGray
        field.shadowRadius = 4
        field.shadowOffsetY = 2
        field.alpha = 0.8
        field.cornerRadius = 10
        return field
    }()
    
    let passwordTextField: UITextFieldX = {
        let field = UITextFieldX()
        field.borderStyle = .roundedRect
        field.backgroundColor = ColorModel.returnGray()
        field.font = UIFont.systemFont(ofSize: 15, weight: .light)
        field.returnKeyType = .done
        field.placeholder = "Confirm password"
        field.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        
        field.shadowColor = .darkGray
        field.shadowRadius = 4
        field.shadowOffsetY = 2
        field.alpha = 0.8
        field.cornerRadius = 10
        return field
    }()
    
    let submitButton : UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setTitle("Change Email", for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(changeEmail), for: .touchUpInside)
        
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
        view.backgroundColor = ColorModel.returnWhite()
        view.hideKeyboardWhenTappedAround()
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        navigationItem.title = "Change Email"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        let stackView = UIStackView(arrangedSubviews: [currentEmailLabel, newEmailTextField, passwordTextField, submitButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 14
        
        view.addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            stackView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 235)
        } else {
            // Fallback on earlier versions
            stackView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 235)
        }
    }
    
    @objc func changeEmail(){
        
        guard let oldEmail = Auth.auth().currentUser?.email else { return }
        guard let newEmail = newEmailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let firebaseUserRegisteredEmail = Auth.auth().currentUser?.email else { return }
        
        let predicate = EmailValidationPredicate()
        let isEmailValid = predicate.evaluate(with: newEmail)
        let oldEmailsMatch = firebaseUserRegisteredEmail == oldEmail
        
        if isEmailValid  && oldEmailsMatch {
            Auth.auth().signIn(withEmail: oldEmail, password: password, completion: { (user, err) in
                if let error = err {
                   LoginController().checkToSeeIfEmailOrPasswordIsIncorrect(error: error)
                    return
                }
                
    
                user?.user.updateEmail(to: newEmail, completion: { (err) in
                    if let error = err {
                        print("Failed to change email:", error)
                        self.revealErrorAlert(title: "Cannot Change Email", subtitle: "email cannot be changed at this time")
                    }
                        self.revealEmailUpdateAlert()
                })
            })
            
            
        } else if isEmailValid  && !oldEmailsMatch {
            self.revealErrorAlert(title: "Wrong Email", subtitle: "enter your current email")
        } else {
            self.revealErrorAlert(title: "Invalid Email", subtitle: "enter a valid email form")
        }
    }
    
    
    @objc func handleInputChange() {
        let isFormValid = newEmailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 > 0
        
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
    
    func revealEmailUpdateAlert(){
        let banner = NotificationBanner(title: "Email Updated", subtitle: "Email has been successfully updated", style: .success)
        banner.duration = 3.0
        banner.show()
        
        newEmailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissView()
        }
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
        
        newEmailTextField.text?.removeAll()
        passwordTextField.text?.removeAll()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
