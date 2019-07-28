//
//  AccountTableController.swift
//  Techlo
//
//  Created by Florian on 12/4/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import GoogleSignIn
import FBSDKLoginKit

class AccountTableController: UITableViewController, VibrantCellDelegate {
    
    let cellId = "cellId"
    
    var user: AppUser? {
        didSet {
            guard let user = user else { return }
            let attributedString = NSMutableAttributedString(string: "\(user.name)\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .bold)])
            let addOnString1 = NSAttributedString(string: "\(user.email)\n", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16, weight: .light)])
            let addonString2 = NSAttributedString(string: "Completed Appointments: \(user.aptAmount)", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 13, weight: .light)])
            
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.alignment = .center
            paragraphStyle.lineSpacing = 6
        
            var range = NSMakeRange(0, attributedString.string.count)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
            attributedString.append(addOnString1)
            
            paragraphStyle.lineSpacing = 1
            range = NSMakeRange(0, attributedString.string.count)
            attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
            
            attributedString.append(addonString2)
            
            nameLabel.attributedText = attributedString
        }
    }

    lazy var nameLabel : UILabel = {
        let label = UILabel()
        label.text = "User's name here"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .light)
        label.textColor = ColorModel.returnCollectionViewColor()
        label.numberOfLines = 0
        return label
    }()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTableView()
    }
    
//    override func viewWillAppear(_ animated: Bool) {
//        super.viewWillAppear(animated)
//        self.navigationItem.title = "Account"
//    }
//
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.navigationItem.title = nil
//    }
    
    func setupTableView(){
        tableView.register(VibrantCell.self, forCellReuseIdentifier: cellId)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = true
        tableView.backgroundView?.backgroundColor = ColorModel.returnWhite()
        tableView.backgroundColor = ColorModel.returnWhite()
        self.view.backgroundColor = ColorModel.returnWhite()
        self.navigationItem.title = "Account"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
    }


    let iconImageView : UIImageView = {
        let icon = UIImageView()
        icon.clipsToBounds = true
        icon.image = UIImage(named: "user2")?.withRenderingMode(.alwaysTemplate)
        icon.tintColor = ColorModel.returnCollectionViewColor()
        icon.layer.cornerRadius = 5
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    func setupHeaderView() -> UIViewX {
        let headerView = UIViewX()
        headerView.shadowColor = .darkGray
        headerView.shadowRadius = 4
        headerView.shadowOffsetY = 2
      //  headerView.alpha = 0.8
        
        headerView.cornerRadius = 0
        
        headerView.addSubview(iconImageView)
        
        headerView.backgroundColor = ColorModel.returnNavyDark()
            //UIColor(r: 31, g: 41, b: 51)//ColorModel.returnNavyDark()
        headerView.addSubview(nameLabel)
        nameLabel.anchorCenterXToSuperview()
        nameLabel.anchorCenterYToSuperview(constant: 30)
        
        iconImageView.anchor(nil, left: nil, bottom: nameLabel.topAnchor, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 35, heightConstant: 40)
        iconImageView.anchorCenterXToSuperview()
        
        return headerView
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let containerHeight = view.frame.height * 0.3
        return containerHeight
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        return setupHeaderView()
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 1))
        return view
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        goTo(index: indexPath.row)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! VibrantCell
      //  cell.blurEffectStyle = SideMenuManager.default.menuBlurEffectStyle
        cell.indexRow = indexPath.row
        return cell
    }
 
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
            return 46
        }
    
    func goTo(index: Int) {
        switch index {
        case 0: handleChangeEmail()
        case 1: handleChangePassword()
        case 2: handleChangePhone()
        case 3: handleChangeCreditCard()
        case 4: handlePushNotifications()
        case 5: handlePrivacyPolicy()
        default: signOutAction()
        }
    }
    
     func signOutAction() {
        let alertController = UIAlertController(title: "Log Out", message: "Are you sure you would like to log out?", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            
            if self.user?.accountType == .email || self.user?.accountType == .facebook {
                do {
                    self.showLoading(state: true)
                    try Auth.auth().signOut()
                    self.showLoading(state: false)
                    self.navigationController?.popViewController(animated: true)
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                        guard let startupController = navController.topViewController as? StartupController else { return }
                        startupController.viewDidLoad()
                        
                    }
                    
                } catch let signOutErr {
                    print("Failed to sign out:", signOutErr)
                }
            }
            else { //if self.user?.accountType == .google {
                self.showLoading(state: true)
                GIDSignIn.sharedInstance()?.signOut()
                GIDSignIn.sharedInstance()?.disconnect()
                
                do {
                    try Auth.auth().signOut()
                    self.showLoading(state: false)
                    self.navigationController?.popViewController(animated: true)
                    UIApplication.shared.applicationIconBadgeNumber = 0
                    if let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController {
                        guard let startupController = navController.topViewController as? StartupController else { return }
                        startupController.viewDidLoad()
                    }
                    
                } catch let signOutErr {
                    print("Failed to sign out:", signOutErr)
                }
                
                let startupController = StartupController()
                let navController = UINavigationController(rootViewController: startupController)
                self.showLoading(state: false)
                self.present(navController, animated: true, completion: nil)
                
            }
            
        }))
        
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }

    
     func handleChangeEmail(){
        let emailController = EmailChangeController()
        emailController.user = self.user
        self.navigationController?.pushViewController(emailController, animated: true)
  
    }
    
     func handleChangePassword(){
        let passwordController = PasswordChangeController()
        self.navigationController?.pushViewController(passwordController, animated: true)
    }
    
     func handlePushNotifications(){
        let pushNotificationsController = PushNotificationsController()
        self.navigationController?.pushViewController(pushNotificationsController, animated: true)

    }
    
     func handleChangeCreditCard(){
        let cardController = CardController()
        cardController.user = self.user
        self.navigationController?.pushViewController(cardController, animated: true)
    }
    
     func handleChangePhone(){
        let phoneController = PhoneChangeController()
        phoneController.user = self.user
        self.navigationController?.pushViewController(phoneController, animated: true)

    }
    
     func handlePrivacyPolicy(){
        let ppController = PPController()
        self.navigationController?.pushViewController(ppController, animated: true)
    }
    
    
    lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.5
        view.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        view.isHidden = true
        return view
    }()
    
    lazy var spinner : UIActivityIndicatorView = {
        let spin = UIActivityIndicatorView()
        spin.anchorCenterSuperview()
        spin.hidesWhenStopped = true
        spin.color = ColorModel.returnWhite()
        spin.isHidden = true
        return spin
    }()
    
    override var prefersStatusBarHidden: Bool {
        setNeedsStatusBarAppearanceUpdate() 
        return true
    }
    
    func showLoading(state: Bool)  {
        if state {
            self.darkView.isHidden = false
            self.spinner.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.5
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { _ in
                self.spinner.stopAnimating()
                self.darkView.isHidden = true
            })
        }
    }
}
