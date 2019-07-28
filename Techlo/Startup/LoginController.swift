//
//  SignInController.swift
//  VC
//
//  Created by Florian on 1/12/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import ValidationComponents
import NotificationBannerSwift

class LoginController: ViewController, UITextFieldDelegate {

    let logoView : UIImageViewX = {
        let imageView = UIImageViewX(image: UIImage(named: "techlo-logo-smaller"))
        imageView.shadowRadius = 4
        imageView.shadowOffsetY = 2
        imageView.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let emailTextField: UITextFieldX = {
        let textField = UITextFieldX()
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = ColorModel.returnGray()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.returnKeyType = .done
        textField.addTarget(self, action: #selector(enableLoginButton), for: .editingChanged)
        textField.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let passwordTextField: UITextFieldX = {
        let textField = UITextFieldX()
        textField.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textField.backgroundColor = ColorModel.returnGray()
        textField.borderStyle = .roundedRect
        textField.textColor = .black
        textField.isSecureTextEntry = true
        textField.returnKeyType = .done
        textField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        textField.addTarget(self, action: #selector(enableLoginButton), for: .editingChanged)
        textField.shadowColor = .darkGray
        textField.shadowRadius = 4
        textField.shadowOffsetY = 2
        textField.alpha = 0.8
        textField.cornerRadius = 10
        return textField
    }()
    
    let loginButton: UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setTitle("Login", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.setTitleColor(.flatWhite(), for: .normal)
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        button.borderWidth = 1
        button.borderColor = UIColor(white: 1, alpha: 0.5)
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.cornerRadius = 10
        return button
    }()
    
    let forgotPasswordButton: UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setTitle("Forgot Password?", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .light)
        button.setTitleColor(ColorModel.returnNavyDark(), for: .normal)
        button.addTarget(self, action: #selector(goToForgotPassword), for: .touchUpInside)
        
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.cornerRadius = 10
        return button
    }()

    
    func checkForUserData(uid: String) -> Bool {
        var result = false
        let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)

        ref.observeSingleEvent(of: .value) { (snapshot) in
            if !(snapshot.exists()) {
                result = true
            }
            result =  false
        }
        return result
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
    }
        
    override func setupViews() {
        super.setupViews()
        navigationItem.titleView = logoView
        
        view.addSubview(logoView)
        view.addSubview(emailTextField)
        view.addSubview(passwordTextField)
        view.addSubview(loginButton)
        view.addSubview(forgotPasswordButton)
        
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
        
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        stackView.spacing = 12
        view.addSubview(stackView)
        
        let height = view.frame.size.height * 0.25
        
        if #available(iOS 11.0, *) {
            stackView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: height)
        } else {
            // Fallback on earlier versions
            stackView.anchor(logoView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 80, leftConstant: 40, bottomConstant: 0, rightConstant: 40, widthConstant: 0, heightConstant: height)
        }
        
        forgotPasswordButton.anchor(loginButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 45, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        forgotPasswordButton.anchorCenterXToSuperview()
        
        view.addSubview(darkView)
        view.addSubview(spinner)
        
        darkView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        spinner.anchorCenterSuperview()
    }
    
    
    @objc func enableLoginButton() {
        let isFormValid = emailTextField.text?.count ?? 0 > 0 && passwordTextField.text?.count ?? 0 >= 5
        
        if isFormValid {
            loginButton.isEnabled = true
            loginButton.backgroundColor = ColorModel.returnNavyDark()
            loginButton.setTitleColor(ColorModel.returnWhite(), for: .normal)
        } else {
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
            loginButton.setTitleColor(ColorModel.returnGray(), for: .normal)
        }
    }
    


    @objc func handleLogin() {
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }

        let predicate = EmailValidationPredicate()
        let isEmailValid = predicate.evaluate(with: email)

        if isEmailValid == false {
            self.revealErrorAlert(title: "Invalid Email", subtitle: "enter a valid email form")

        } else {

            self.showLoading(state: true)
            Auth.auth().signIn(withEmail: email, password: password, completion: { (_, err) in

                if let err = err {
                    self.checkToSeeIfEmailOrPasswordIsIncorrect(error: err)
                    return
                }
                
                self.checkFCMToken()
                self.showLoading(state: false)
                self.goToStartup()
        })
        }
    }
    
    func checkToSeeIfEmailOrPasswordIsIncorrect(error: Error) {

        if let errCode = AuthErrorCode(rawValue: error._code) {

            switch errCode {
            case .wrongPassword:
                self.revealErrorAlert(title: "Wrong Password", subtitle: "The password entered is incorrect")
            case .invalidEmail:
                self.revealErrorAlert(title: "Invalid Email", subtitle: "The email entered is not valid")
                self.emailTextField.text?.removeAll()
            case .userNotFound:
                self.revealErrorAlert(title: "Invalid Email", subtitle: "The email entered does not exist")
                self.emailTextField.text?.removeAll()
            default:
                print("Failed to login user:", error)
                self.revealErrorAlert(title: "Unsuccessful", subtitle: "cannot login at this time")
            }
            self.passwordTextField.text?.removeAll()
        } else {
            self.revealErrorAlert(title: "Unsuccessful", subtitle: "cannot login at this time")
        }
        self.showLoading(state: false)

    }
    
    @objc func goToStartup() {
        if let startupNavController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
            self.showLoading(state: false)
            self.dismiss(animated: true, completion: nil)
            guard let startupController = startupNavController.topViewController as? StartupController else { return }
            startupController.viewDidLoad()
        }
    }
    
    @objc func goToForgotPassword(){
        let forgotPasswordController = ForgotPasswordController()
        navigationController?.pushViewController(forgotPasswordController, animated: true)
    }
    
    func checkFCMToken(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            guard let userDictionary = snapshot.value as? [String: Any] else { return }
            guard let fcmToken = userDictionary[AccountProperty.fcmToken.rawValue] as? String else { return }
            guard let newToken = Messaging.messaging().fcmToken else { return }
            if fcmToken != newToken {
                ref.updateChildValues([AccountProperty.fcmToken.rawValue: newToken])
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
