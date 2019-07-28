//
//  StartupController.swift
//  Techlo
//
//  Created by Florian on 1/9/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import BouncyLayout
import Firebase
import SimpleAnimation
import SwiftyOnboard

var navigatedToStartup = false
var leaving = false

class StartupController: UIViewController, SwiftyOnboardDelegate, SwiftyOnboardDataSource {

    var user: AppUser?
    var swiftyOnboard: SwiftyOnboard?
    
    let logoView : UIImageViewX = {
        let imageView = UIImageViewX(image: UIImage(named: "techlo-logo-smaller"))
        imageView.shadowRadius = 4
        imageView.shadowOffsetY = 2
        imageView.cornerRadius = 5
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let setButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        button.popIn()
        button.setTitle("Set Up Appointment", for: .normal)
        button.setImage(UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(ColorModel.returnWhite(), for: .normal)
        button.addTarget(self, action: #selector(goToCreate), for: .touchUpInside)
        button.backgroundColor = UIColor.flatRed()
        button.tintColor = ColorModel.returnWhite()
        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.cornerRadius = 10
        button.alpha = 0.8
        return button
    }()
    
    let appointmentsButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            button.popIn()
            button.setTitle("Appointments", for: .normal)
            button.setImage(UIImage(named: "appointment-book")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(ColorModel.returnWhite(), for: .normal)
            button.addTarget(self, action: #selector(goToAppointments), for: .touchUpInside)
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
    
    let libraryButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            button.popIn()
            button.setTitle("Appointment Notes", for: .normal)
            button.setImage(UIImage(named: "study")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(ColorModel.returnWhite(), for: .normal)
            button.addTarget(self, action: #selector(goToLibrary), for: .touchUpInside)
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
        
    let accountButton: FlexButton = {
        let button = FlexButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            button.popIn()
            button.setTitle("Account", for: .normal)
            button.setImage(UIImage(named: "user3")?.withRenderingMode(.alwaysTemplate), for: .normal)
            button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            button.setTitleColor(.flatWhite(), for: .normal)
            button.addTarget(self, action: #selector(goToAccount), for: .touchUpInside)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkForUserData(uid: Auth.auth().currentUser?.uid) { (result) in
            if result == false {
                self.callWelcomeController()
            } else {
                self.setupViews()
                return
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if user == nil {
            guard let uid = Auth.auth().currentUser?.uid else { return }
            Database.fetchUserWithUID(uid: uid, completion: { (user) in
                self.user = user
            })
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let blankView = UIView()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: blankView)
    }
    
    func checkForOnboarding(){
        if UserDefaults.standard.bool(forKey: "onboard") == true {
            return
        }
        
//        swiftyOnboard = SwiftyOnboard(frame: view.frame, style: .light)
//        if let swiftOnboard = swiftyOnboard {
//            view.addSubview(swiftOnboard)
//            swiftOnboard.dataSource = self
//            swiftOnboard.delegate = self
//        }
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        navigationItem.titleView = logoView
        
       // navigationItem.titleView.
        
        let navBar = navigationController?.navigationBar
        navBar?.isTranslucent = false
        navBar?.barTintColor = ColorModel.returnWhite()
        navBar?.tintColor = ColorModel.returnNavyDark()
        navBar?.setBackgroundImage(UIImage(), for: .default)
        navBar?.shadowImage = UIImage()

        
        let stackView = UIStackView(arrangedSubviews: [setButton, appointmentsButton, libraryButton, accountButton])
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
        
        checkForOnboarding()
    }
    
    @objc func goToLibrary(){
        let layout = BouncyLayout()
        let noteController = NoteController(collectionViewLayout: layout)
        navigationController?.pushViewController(noteController, animated: true)
    }
    
    @objc func goToAccount(){
        let accountController = AccountTableController()
        accountController.user = user
        self.navigationController?.pushViewController(accountController, animated: true)
    }
    
    @objc func goToAppointments(){
        let appointmentsController = CalendarController()
        navigationController?.pushViewController(appointmentsController, animated: true)
    }
    
    @objc func goToCreate(){
        let createController = CreateAppointmentController()
        navigationController?.pushViewController(createController, animated: true)
    }
    
    func checkForUserData(uid: String?, completion: @escaping (Bool) -> ()) {
        guard let uid = uid else {
            self.callWelcomeController()
            return }
        let ref = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.exists()) {
                completion(true)
                return
            } else {
                completion(false)
                return
            }
        }
    }
    
    func callWelcomeController(){
        let welcomeController = WelcomeController()
        let navController = UINavigationController(rootViewController: welcomeController)
        navigationController?.view.backgroundColor = ColorModel.returnWhite()
        
        let navBar = navController.navigationBar
        navBar.isTranslucent = false
        navBar.barTintColor = ColorModel.returnWhite()
        navBar.tintColor = ColorModel.returnNavyDark()
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        
        DispatchQueue.main.async {
            self.present(navController, animated: true, completion: nil)
        }
    }
    
    func swiftyOnboardNumberOfPages(_ swiftyOnboard: SwiftyOnboard) -> Int {
        return 6
    }
    
    func swiftyOnboardPageForIndex(_ swiftyOnboard: SwiftyOnboard, index: Int) -> SwiftyOnboardPage? {
        return nil
    }
    
    func swiftyOnboardViewForBackground(_ swiftyOnboard: SwiftyOnboard) -> UIView? {
        return nil
    }
    
    func swiftyOnboardViewForOverlay(_ swiftyOnboard: SwiftyOnboard) -> SwiftyOnboardOverlay? {
        return nil
    }
    
    func swiftyOnboardOverlayForPosition(_ swiftyOnboard: SwiftyOnboard, overlay: SwiftyOnboardOverlay, for position: Double) {
        
    }
}
