//
//  WelcomeController.swift
//  Techlo
//
//  Created by Florian on 1/13/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
import GoogleSignIn
import FBSDKCoreKit
import FBSDKLoginKit
import SimpleAnimation

class WelcomeController: ViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    let logoView : UIImageViewX = {
        let imageView = UIImageViewX(image: UIImage(named: "techlo-logo-smaller"))
     //   imageView.frame = CGRect(x: 0, y: 0, width: 60, height: 45)
        imageView.shadowRadius = 4
        imageView.shadowOffsetY = 2
        imageView.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let loginButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        button.popIn()
        button.setTitle("Login", for: .normal)
        button.setImage(UIImage(named: "log-in")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(ColorModel.returnWhite(), for: .normal)
        button.addTarget(self, action: #selector(goToLogin), for: .touchUpInside)
        button.backgroundColor = UIColor.flatRed()
        button.tintColor = ColorModel.returnWhite()
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.cornerRadius = 10
        button.alpha = 0.8
        return button
    }()
    
    let createAccountButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45, execute: {
            button.popIn()
            button.setTitle("Create Account", for: .normal)
            button.setImage(UIImage(named: "user3")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(ColorModel.returnWhite(), for: .normal)
            button.addTarget(self, action: #selector(goToAcountCreation), for: .touchUpInside)
            button.backgroundColor = UIColor.flatOrange()
            button.tintColor = ColorModel.returnWhite()
            button.shadowColor = .darkGray
            button.shadowRadius = 4
            button.shadowOffsetY = 2
            button.cornerRadius = 10
            button.alpha = 0.8
        })
        return button
    }()
    
    let googleButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15, execute: {
            button.popIn()
            button.setTitle("Login with Google", for: .normal)
            button.setImage(UIImage(named: "google")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(ColorModel.returnWhite(), for: .normal)
            button.addTarget(self, action: #selector(handleGoogleSignIn), for: .touchUpInside)
            button.backgroundColor = UIColor.flatGreen()
            button.tintColor = ColorModel.returnWhite()
            button.shadowColor = .darkGray
            button.shadowRadius = 4
            button.shadowOffsetY = 2
            button.cornerRadius = 10
            button.alpha = 0.8
        })
        return button
    }()
    
    let facebookButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            button.popIn()
            button.setTitle("Login with Facebook", for: .normal)
            button.setImage(UIImage(named: "facebook")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(.flatWhite(), for: .normal)
            button.addTarget(self, action: #selector(handleFacebookSignIn), for: .touchUpInside)
            button.backgroundColor = UIColor.flatSkyBlue()
            button.tintColor = ColorModel.returnWhite()
            button.shadowColor = .darkGray
            button.shadowRadius = 4
            button.shadowOffsetY = 2
            button.cornerRadius = 10
            button.alpha = 0.8
        })
        return button
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().delegate = self
    }
    
    override func setupViews(){
        super.setupViews()
        view.backgroundColor = ColorModel.returnWhite()
        view.tintColor = ColorModel.returnWhite()
        navigationItem.titleView = logoView
        
        let navBar = navigationController?.navigationBar
        navBar?.isTranslucent = false
        navBar?.barTintColor = ColorModel.returnWhite()
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()
        
        let stackView = UIStackView(arrangedSubviews: [loginButton, googleButton, facebookButton, createAccountButton])
        stackView.spacing = 10
        stackView.alignment = .fill
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        
        view.addSubview(stackView)
        
        if #available(iOS 11.0, *) {
            stackView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 20, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        } else {
            // Fallback on earlier versions
            stackView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 10, leftConstant: 10, bottomConstant: 20, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        }
        
        view.addSubview(darkView)
        view.addSubview(spinner)
        
        darkView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        spinner.anchorCenterSuperview()

    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        showLoading(state: true)
        
        if error != nil {
            if let error = error as? GIDSignInErrorCode, error.rawValue == -5 {
                self.showLoading(state: false)
                return
            } else if let error = error as? GIDSignInErrorCode {
                self.revealErrorAlert(title: "Sorry", subtitle: "Cannot sign into  Google account at this time")
                print("Failed to sign in for google user:", error.rawValue)
                self.showLoading(state: false)
                return
            }
            self.showLoading(state: false)
            return
        }
        
        guard let authentication = user.authentication else { print("user authentification line"); return }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            
            if error != nil {
                if let error = error as? GIDSignInErrorCode, error.rawValue != -5  {
                    self.revealErrorAlert(title: "Sorry", subtitle: "Cannot sign into  Google account at this time")
                    print("Failed to sign in for google user 2:", error.rawValue)
                    self.showLoading(state: false)
                    return
                    
                } else if let error = error as? GIDSignInErrorCode, error.rawValue == -5 {
                    self.showLoading(state: false)
                    return
                }
                self.showLoading(state: false)
                return
            }
            guard let uid = user?.user.uid else { return }
            let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
            ref.observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    guard let email = user?.user.email else { return }
                    guard let name = user?.user.displayName else { return }
                    guard let fcmToken = Messaging.messaging().fcmToken else { return }
                    
                    
                    var values: [String: Any] = [:]
                    if let phone = user?.user.phoneNumber {
                        values = ["email": email, "name": name, "phone" : phone, "aptAmount": 0, "accountType": AccountType.facebook.rawValue, "fcmToken": fcmToken] as [String: Any]
                    } else {
                        values = ["email": email, "name": name, "aptAmount": 0, "accountType": AccountType.facebook.rawValue, "fcmToken": fcmToken] as [String: Any]
                    }
                    
                    let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
                    ref.updateChildValues(values)
                }
            })
            
            self.checkFCMToken()
            if let startupNavController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                self.showLoading(state: false)
                self.dismiss(animated: true, completion: nil)
                guard let startupController = startupNavController.topViewController as? StartupController else { return }
                startupController.viewDidLoad()
            }
        }
    }
    
    
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        let banner = NotificationBanner(title: "Sorry", subtitle: "You have been disconnected. Please sign in again", style: .danger)
        banner.duration = 4.0
        banner.show()
        
        if let _ = UIApplication.topViewController() as? WelcomeController {
            do {
                try Auth.auth().signOut()
            } catch let signOutErr {
                print("Failed to sign out:", signOutErr)
            }
            print("already on startup page")
            
        } else {
            if let startupController = UIApplication.shared.keyWindow?.rootViewController as? StartupController {
                self.showLoading(state: false)
                self.dismiss(animated: true, completion: nil)
                startupController.viewDidLoad()
            }
        }
    }
    
    @objc func handleGoogleSignIn(){
        GIDSignIn.sharedInstance()?.signIn()
        showLoading(state: true)
    }
    
    
    @objc func handleFacebookSignIn(){
        self.showLoading(state: true)
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (_, error) in
            
            if error != nil {
                if let error = error {
                    self.revealErrorAlert(title: "Sorry", subtitle: "Cannot login using Facebook at this time")
                    print("Failed to sign in using FB:", error)
                    self.showLoading(state: false)
                    return
                }
            }
            self.facebookStartupHelper()
        }
    }
    
    func facebookStartupHelper(){
        self.showLoading(state: true)
        FBSDKGraphRequest(graphPath: "/me", parameters: ["fields": "id, name, email"]).start(completionHandler: { (_, _, error) in
            
            if error != nil {
                if let error = error as? FBSDKError {
                    print("Cannot graph  FB request:", error)
                    self.showLoading(state: false)
                    return
                }
                self.showLoading(state: false)
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current()?.tokenString else { return }
            let credentials = FacebookAuthProvider.credential(withAccessToken: accessToken)
            Auth.auth().signInAndRetrieveData(with: credentials) { (user, error) in
                
                if error != nil {
                    if let error = error as? FBSDKError {
                        self.revealErrorAlert(title: "Sorry", subtitle: "Cannot login using Facebook at this time")
                        print("Failed to sign in using FB Helper:", error)
                        self.showLoading(state: false)
                        return
                    }
                    self.showLoading(state: false)
                    return
                }
                
                guard let uid = user?.user.uid else { return }
                let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
                ref.observe(.value, with: { (snapshot) in
                    if snapshot.exists() {
                        guard let email = user?.user.email else { return }
                        guard let name = user?.user.displayName else { return }
                        guard let fcmToken = Messaging.messaging().fcmToken else { return }
                        
                        
                        var values: [String: Any] = [:]
                        if let phone = user?.user.phoneNumber {
                            values = ["email": email, "name": name, "phone" : phone, "aptAmount": 0, "accountType": AccountType.facebook.rawValue, "fcmToken": fcmToken] as [String: Any]
                        } else {
                            values = ["email": email, "name": name, "aptAmount": 0, "accountType": AccountType.facebook.rawValue, "fcmToken": fcmToken] as [String: Any]
                        }
                        
                        let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
                        ref.updateChildValues(values)
                    }
                })

                self.checkFCMToken()
                if let startupController = UIApplication.shared.keyWindow?.rootViewController as? StartupController {
                    print("startup is still key ")
                    self.showLoading(state: false)
                    self.dismiss(animated: true, completion: nil)
                    startupController.viewDidLoad()
                }
            }
            
        })
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
    
    @objc func goToLogin(){
        let loginController = LoginController()
        navigationController?.pushViewController(loginController, animated: true)
    }
    
    @objc func goToAcountCreation(){
        let signupController = SignupController()
        navigationController?.pushViewController(signupController, animated: true)
    }
}
