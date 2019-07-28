//
//  CardController.swift
//  Techlo
//
//  Created by Florian on 11/13/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import Stripe
import CreditCardForm
import NotificationBannerSwift

class CardController: UIViewController, STPPaymentCardTextFieldDelegate {
    
    var user: AppUser? {
        didSet {
            guard let user = user else { return }
            
            if let last4 = user.last4, last4 != "" {
                creditCardView.cardNumberMaskTemplate = "**** **** **** \(last4)"
            }
        }
    }
    
    var navigatedTo = false
    var appointmentId: String?
    
    let creditCardView = CreditCardFormView()
    
    lazy var paymentTextField : STPPaymentCardTextField = {
        let field = STPPaymentCardTextField()
        field.frame = CGRect(x: 15, y: 199, width: self.view.frame.size.width - 30, height: 44)
        field.delegate = self
        field.translatesAutoresizingMaskIntoConstraints = false
        field.borderWidth = 0
        field.postalCodeEntryEnabled = true
        
        let border = CALayer()
        let width = CGFloat(1.0)
        border.borderColor = UIColor.darkGray.cgColor
        border.frame = CGRect(x: 0, y: field.frame.size.height - width, width:  field.frame.size.width, height: field.frame.size.height)
        border.borderWidth = width
        field.layer.addSublayer(border)
        field.layer.masksToBounds = true
        return field
    }()

    
    let submitNewCardButton: UIButtonX = {
        let button = UIButtonX(type: .system)
        button.setTitle("Add New Card", for: .normal)
        button.addTarget(self, action: #selector(addNewButtonAction), for: .touchUpInside)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.setTitleColor(UIColor.lightGray, for: .normal)

        button.shadowColor = .darkGray
        button.shadowRadius = 4
        button.shadowOffsetY = 2
        button.cornerRadius = 10
        return button
    }()
    
    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(dismissController), for: .touchUpInside)
        button.setTitle("Back", for: .normal)
        button.tintColor = ColorModel.returnNavyDark()
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.setImage(UIImage(named: "backArrow"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        setupNavItems()

        view.addSubview(creditCardView)
        view.addSubview(paymentTextField)
        view.addSubview(submitNewCardButton)
        
        view.hideKeyboardWhenTappedAround()
        
        
        if #available(iOS 11.0, *) {
            creditCardView.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 300, heightConstant: 200)
        } else {
            // Fallback on earlier versions
            creditCardView.anchor(view.layoutMarginsGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 20, bottomConstant: 0, rightConstant: 20, widthConstant: 300, heightConstant: 200)
        }
        
        creditCardView.cardHolderPlaceholderString = "Techlo"
        creditCardView.chipImage = UIImage(named: "chip")
        creditCardView.isUserInteractionEnabled = false
        creditCardView.anchorCenterXToSuperview()
        
        view.addSubview(paymentTextField)
        
        let constantWidth = self.view.frame.size.width - 20
        
        paymentTextField.anchor(creditCardView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 20, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: constantWidth, heightConstant: 44)
        paymentTextField.anchorCenterXToSuperview()
        
        let width2 = view.frame.size.width * 0.45
        submitNewCardButton.anchor(paymentTextField.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 50, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width2, heightConstant: width2 * 0.3)
        submitNewCardButton.anchorCenterXToSuperview()

    }
    
    func setupNavItems(){
        navigationItem.title = "Card Information"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        if navigatedTo == true {
            UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
            UINavigationBar.appearance().shadowImage = UIImage()
            UINavigationBar.appearance().backgroundColor = .clear
            UINavigationBar.appearance().isTranslucent = true
            let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(dismissController))
            cancelButton.tintColor = ColorModel.returnNavyDark()
            self.navigationItem.leftBarButtonItem = cancelButton
            return
        }
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        let ref = Database.database().reference().child(FirebaseKey.source.rawValue).child("sourceId")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if snapshot.exists() == true {
                let button = UIBarButtonItem(title: "Delete", style: .done, target: self, action: #selector(self.removeCardInfo))
                button.tintColor = ColorModel.returnNavyDark()
                self.navigationItem.rightBarButtonItem = button
            }
        }
    }
    
    @objc func enableNewCardButton() {
        if paymentTextField.cardParams.address.postalCode?.count == 5 {
            submitNewCardButton.isEnabled = true
            submitNewCardButton.setTitleColor(.flatWhite(), for: .normal)
            submitNewCardButton.backgroundColor = ColorModel.returnNavyDark()
        } else {
            submitNewCardButton.isEnabled = false
            submitNewCardButton.setTitleColor(.lightGray, for: .normal)
            submitNewCardButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        }
    }
    
    @objc func addNewButtonAction(){
        addCard()
        
        if navigatedTo == false {
            revealCardUpdateAlert()
            return
        }
        
        let alert = UIAlertController(title: "Card Added", message: "Would you like to continue\n with a deposit for this appointment?", preferredStyle: .alert)

        let noAction = UIAlertAction(title: "No", style: .cancel) { _ in
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popToRootViewController(animated: true)
        }

        let yesAction = UIAlertAction(title: "Yes", style: .default) { _ in
            guard let uid = Auth.auth().currentUser?.uid else { return }

            let chargeRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.charge.rawValue).childByAutoId()
            
            let sourcesRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child("sourceId")
            
            sourcesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let paymentSourceId = snapshot.value as? String else { return }
                
                let values = ["amount": 199, "source": paymentSourceId, "description": "Techlo Appointment Deposit: $1.99"] as [String: Any]
                chargeRef.updateChildValues(values)
                
                guard let apptId = self.appointmentId else { return }
                let apptRef = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(apptId)
                apptRef.updateChildValues(["deposit": true])
                
                let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(apptId)
                let masterRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(apptId)
                
                ref.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": AppointmentResponse.customerApproved.rawValue])
                masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": AppointmentResponse.customerApproved.rawValue])
            })
        }

        alert.addAction(noAction)
        alert.addAction(yesAction)

        self.present(alert, animated: true, completion: nil)
    }
    
    func addCard(){
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let params = paymentTextField.cardParams
        let source = STPSourceParams.cardParams(withCard: params)

        let ref = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child("sourceId")
        
        STPAPIClient.shared().createSource(with: source) { (paymentSource, error) in
            if let error = error {
                print("Failed to create source with user card: ", error)
            }

            guard let stripeSourceId = paymentSource?.stripeID else {
                print("Failed to get the stripe id for the payment source")
                return
            }
            
            ref.removeValue()
            ref.setValue(stripeSourceId)
            
            if let last4 = params.last4() {
            Database.database().reference().child(FirebaseKey.user.rawValue).child(uid).updateChildValues([AccountProperty.last4.rawValue: last4])

                self.creditCardView.cardNumberMaskTemplate = "**** **** **** \(last4)"
            }
        }
    }
    
    @objc func removeCardInfo(){
        let alert = UIAlertController(title: "Remove Card", message: "Are you sure you want to remove\n your card?", preferredStyle: .alert)

        let removeAction = UIAlertAction(title: "Remove", style: .cancel) { _ in
            self.deleteCard()
        }
        alert.addAction(removeAction)

        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { _ in
            alert.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func deleteCard(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.fetchUserWithUID(uid: uid) { (user) in
            let ref = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child("sourceId")
            let userRef = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
            
            ref.removeValue()
            userRef.child(AccountProperty.last4.rawValue).removeValue()
            userRef.child(AccountProperty.paymentSourceId.rawValue).removeValue()
            self.creditCardView.cardNumberMaskTemplate = "**** **** **** ****"
            self.revealCardUpdateAlert(removed: true)
            print("removed card")
            
        }
    }
    
    func revealCardUpdateAlert(removed: Bool = false){
        if removed == true {
            let banner = NotificationBanner(title: "Card Removed", subtitle: "Card has been removed", style: .success)
            banner.duration = 3.0
            banner.titleLabel?.textAlignment = .center
            banner.subtitleLabel?.textAlignment = .center
            banner.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                self.dismissView()
            }
            return
        }
        
        let banner = NotificationBanner(title: "Card Updated", subtitle: "Card has been successfully saved", style: .success)
        banner.duration = 3.0
        banner.show()
        banner.titleLabel?.textAlignment = .center
        banner.subtitleLabel?.textAlignment = .center
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.dismissView()
        }
    }
    

    func paymentCardTextFieldDidChange(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidChange(cardNumber: textField.cardNumber, expirationYear: textField.expirationYear, expirationMonth: textField.expirationMonth, cvc: textField.cvc)
        enableNewCardButton()
    }
    
    func paymentCardTextFieldDidEndEditingExpiration(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingExpiration(expirationYear: textField.expirationYear)
    }
    
    func paymentCardTextFieldDidBeginEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidBeginEditingCVC()
    }
    
    func paymentCardTextFieldDidEndEditingCVC(_ textField: STPPaymentCardTextField) {
        creditCardView.paymentCardTextFieldDidEndEditingCVC()
    }
    
    @objc func dismissController(){
      //  self.navigationController?.pop(transitionType: CATransitionType.moveIn, subtype: CATransitionSubtype.fromBottom, duration: 0.4)
        self.dismiss(animated: true, completion: nil)
    }
}
