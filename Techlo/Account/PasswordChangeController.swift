//
//  PasswordChangeController.swift
//  LemonadeStand
//
//  Created by Florian on 4/2/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift

class PasswordChangeController: UIViewController, UITextFieldDelegate {
    
    
    let oldPasswordTextField: UITextFieldX = {
        let field = UITextFieldX()
        field.borderStyle = .roundedRect
        field.backgroundColor = ColorModel.returnGray()
        field.becomeFirstResponder()
        field.font = UIFont.systemFont(ofSize: 15, weight: .light)
        field.returnKeyType = .done
        field.placeholder = "Enter old password"
        field.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        
        field.shadowColor = .darkGray
        field.shadowRadius = 4
        field.shadowOffsetY = 2
        field.alpha = 0.8
        field.cornerRadius = 10
        return field
    }()
    
    let newPasswordTextField: UITextFieldX = {
        let field = UITextFieldX()
        field.borderStyle = .roundedRect
        field.backgroundColor = ColorModel.returnGray()
        field.font = UIFont.systemFont(ofSize: 15, weight: .light)
        field.returnKeyType = .done
        field.placeholder = "Enter new password"
        field.addTarget(self, action: #selector(handleInputChange), for: .editingChanged)
        
        field.shadowColor = .darkGray
        field.shadowRadius = 4
        field.shadowOffsetY = 2
        field.alpha = 0.8
        field.cornerRadius = 10
        return field
    }()
    
    let confirmNewPasswordTextField: UITextFieldX = {
        let field = UITextFieldX()
        field.borderStyle = .roundedRect
        field.font = UIFont.systemFont(ofSize: 15, weight: .light)
        field.backgroundColor = ColorModel.returnGray()
        field.returnKeyType = .done
        field.placeholder = "Enter new password"
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
        button.setTitle("Submit", for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.setTitleColor(UIColor.lightGray, for: .normal)
        button.layer.cornerRadius = 5
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(changePassword), for: .touchUpInside)
        
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
        navigationItem.title = "Change Password"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]

        let stackView = UIStackView(arrangedSubviews: [oldPasswordTextField, newPasswordTextField, confirmNewPasswordTextField, submitButton])
        
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
    
    @objc func changePassword(){
        guard let oldPassword = oldPasswordTextField.text else { return }
        guard let newPassword = newPasswordTextField.text else { return }
        
        let passwordsMatch = oldPassword == newPassword
        
        if newPassword.count >= 6 && !passwordsMatch {
            
            guard let userEmail = Auth.auth().currentUser?.email else { return }
            
            Auth.auth().signIn(withEmail: userEmail, password: oldPassword, completion: { (user, error) in
                
                if let error = error {
                    print("Failed to change password:", error)
                    self.revealErrorAlert(title: "Cannot Change Password", subtitle: "your password cannot be changed at this time")
                }
                
                user?.user.updatePassword(to: newPassword, completion: { (error) in
                    if let error = error {
                        print("Failed to change password:", error)
                        self.revealErrorAlert(title: "Cannot Change Password", subtitle:  "your password cannot be changed at this time")
                    }
            
                    self.revealPasswordUpdateAlert()
                })
                
            })
            
        } else if newPassword.count < 6 {
            self.revealErrorAlert(title: "Short Password", subtitle: "please enter a longer password")
            
        } else {
            self.revealErrorAlert(title: "Invalid Password", subtitle: "old password cannot be new password")
        }
    }
    
    @objc func handleInputChange() {
        let isFormValid = oldPasswordTextField.text?.count ?? 0 > 0 && newPasswordTextField.text?.count ?? 0 > 0
        
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
    
    func revealPasswordUpdateAlert(){
        let banner = NotificationBanner(title: "Password Updated", subtitle: "Password has been successfully updated", style: .success)
        banner.duration = 3.0
        banner.show()
        
        oldPasswordTextField.text?.removeAll()
        newPasswordTextField.text?.removeAll()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissView()
        }
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
        
        oldPasswordTextField.text?.removeAll()
        newPasswordTextField.text?.removeAll()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
