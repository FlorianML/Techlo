//
//  ForgotPasswordController.swift
//  VC
//
//  Created by Florian on 1/17/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import ValidationComponents
import Firebase
import NotificationBannerSwift

class ForgotPasswordController : UIViewController {
    
    let logoView : UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "techlo-logo-smaller"))
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let emailTextField: UITextFieldX = {
        let textField = UITextFieldX()
        textField.backgroundColor = ColorModel.returnGray()
        textField.borderStyle = .roundedRect
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(handleTextChange), for: .editingChanged)
        
        textField.attributedPlaceholder = NSAttributedString(string: "Enter email to reset password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let sendResetEmailButton: UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setTitle("Send Reset Email", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.setTitleColor(ColorModel.returnGray(), for: .normal)
        button.isEnabled = false
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(sendResetPasswordEmail), for: .touchUpInside)
        
        button.borderWidth = 1
        button.borderColor = .darkGray
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
        
        navigationItem.titleView = logoView
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, sendResetEmailButton])
        
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        stackView.spacing = 12
        
        view.addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            stackView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 110)
        } else {
            // Fallback on earlier versions
            stackView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 80, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: 110)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func handleTextChange() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0
        
        if isFormValid {
            sendResetEmailButton.isEnabled = true
            sendResetEmailButton.backgroundColor = ColorModel.returnNavyDark()
            sendResetEmailButton.setTitleColor(ColorModel.returnWhite(), for: .normal)
        } else {
            sendResetEmailButton.isEnabled = false
            sendResetEmailButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
            sendResetEmailButton.setTitleColor(ColorModel.returnGray(), for: .normal)
        }
    }
    
    @objc func sendResetPasswordEmail(){
        print("sent reset email")
        guard let email = emailTextField.text, email.count > 0 else { return }
        
        let predicate = EmailValidationPredicate()
        let isEmailValid = predicate.evaluate(with: email)
    
        
        
        if isEmailValid {
            
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                
                guard let err = error else { return }
                if let errCode = AuthErrorCode(rawValue: err._code) {
                    if errCode == AuthErrorCode.invalidEmail {
                        self.revealErrorAlert(title: "Invalid Email", subtitle: "The email entered is not valid")
                        self.emailTextField.text?.removeAll()
                    } else if errCode == AuthErrorCode.userNotFound {
                        self.revealErrorAlert(title: "Invalid Email", subtitle: "The email entered does not exist")
                        self.emailTextField.text?.removeAll()
                    }
                } else {
                    self.revealErrorAlert(title: "Unsuccessful", subtitle: "cannot send reset password email at this time")
                    self.emailTextField.text?.removeAll()
                }
                return
            })
            
            self.revealEmailSentAlert()
            
        } else {
            self.revealErrorAlert(title: "Invalid Email", subtitle: "Please use a valid email form")
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
              self.goBackToLoginScreen()
        }
    }
    
    @objc func goBackToLoginScreen() {
          navigationController?.popViewController(animated: true)
    }
    
    func revealEmailSentAlert(){
        let banner = NotificationBanner(title: "Email Sent", subtitle: "an email to allow you to reset your password has been sent", style: .success)
        banner.duration = 3.0
        banner.show()
        
        emailTextField.text?.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissView()
        }
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
        
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
