//
//  AlternateCardController.swift
//  Techlo
//
//  Created by Florian on 2/13/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//


import UIKit
import Firebase
import Stripe
import CreditCardForm
import NotificationBannerSwift

class AlternateCardController: STPAddCardViewController {
    
    var user: AppUser? {
        didSet {
            guard let user = user else { return }
            
            if let last4 = user.last4, last4 != "" {
                creditCardView.cardNumberMaskTemplate = "**** **** **** \(last4)"
                self.navigationItem.rightBarButtonItem = deleteButton
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     //   setupViews()
        setupNavItems()
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
            self.dismiss(animated: true, completion: {
                if let apptController = self.navigationController?.topViewController as? CompleteAppointmentController {
                    guard let uid = Auth.auth().currentUser?.uid else { return }
                    apptController.showLoading(state: true)
                    let ref = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.charge.rawValue).childByAutoId()
                    
                    if let paymentSourceId = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid).value(forKey: AccountProperty.paymentSourceId.rawValue) as? String {
                        
                        let tokenRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child(paymentSourceId)
                        guard let token = tokenRef.value(forKey: "token") else { return }
                        
                        let values = ["amount": 2, "source": token] as [String: Any]
                        ref.updateChildValues(values)
                        
                        guard let status = ref.value(forKey: "status") as? String else { apptController.revealErrorAlert(title: "Sorry", subtitle: "Cannot submit appointment at this moment. Please try again later"); return }
                        
                        
                        if ref.value(forKey: "status") != nil && status == "succeeded" {
                            apptController.goThroughWithSubmisson()
                        } else {
                            apptController.revealErrorAlert(title: "Sorry", subtitle: "Cannot submit appointment at this moment. Please try again later")
                        }
                        
                        apptController.showLoading(state: false)
                    }
                    apptController.showLoading(state: false)
                }
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
        let ref = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).childByAutoId()
        
        
        STPAPIClient.shared().createSource(with: source) { (paymentSource, error) in
            if let error = error {
                print("Fail to create source with user card: ", error)
            }
            
            guard let token = source.token else { return }
            ref.updateChildValues(["token": token])
            
            
            if let last4 = params.last4(), let key = ref.key {
                Database.database().reference().child(FirebaseKey.user.rawValue).child(uid).updateChildValues([AccountProperty.last4.rawValue: last4, AccountProperty.paymentSourceId.rawValue: key])
                
                self.creditCardView.cardNumberMaskTemplate = "**** **** **** \(last4)"
            }
        }
        
        
        
        //        STPAPIClient.shared().createToken(withCard: params) { (stripeToken, error) in
        //            if let error = error {
        //                print("Fail to create token with user card: ", error)
        //            }
        //            guard let token = stripeToken else { return }
        //            ref.updateChildValues(["token": token.tokenId])
        //
        //
        //            if let last4 = params.last4(), let key = ref.key {
        //                Database.database().reference().child(FirebaseKey.user.rawValue).child(uid).updateChildValues([AccountProperty.last4.rawValue: last4, AccountProperty.paymentSourceId.rawValue: key])
        //
        //                self.creditCardView.cardNumberMaskTemplate = "**** **** **** \(last4)"
        //            }
        //        }
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
            if let paymentSourceId = user.paymentSourceId {
                let ref = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child(paymentSourceId)
                let userRef = Database.database().reference().child(FirebaseKey.user.rawValue).child(uid)
                
                ref.removeValue()
                userRef.updateChildValues([AccountProperty.last4.rawValue: "", AccountProperty.paymentSourceId.rawValue: ""])
                self.creditCardView.cardNumberMaskTemplate = "**** **** **** ****"
                self.revealCardUpdateAlert(removed: true)
                print("removed card")
            }
        }
    }
    
    func revealCardUpdateAlert(removed: Bool = false){
        if removed == true {
            let banner = NotificationBanner(title: "Card Removed", subtitle: "Card has been removed", style: .success)
            banner.duration = 3.0
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
    
    func addCardViewController(_ addCardViewController: STPAddCardViewController, didCreateToken token: STPToken, completion: @escaping STPErrorBlock) {
        StripeClient.shared.completeCharge(with: token, amount: 199) { result in
            switch result {
            // 1
            case .success:
                completion(nil)
                
                let alertController = UIAlertController(title: "Congrats", message: "Your payment was successful!", preferredStyle: .alert)
                let alertAction = UIAlertAction(title: "OK", style: .default, handler: { _ in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(alertAction)
                self.present(alertController, animated: true)
            // 2
            case .failure(let error):
                completion(error)
            }
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

