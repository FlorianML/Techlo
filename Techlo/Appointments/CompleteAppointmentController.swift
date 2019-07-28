//
//  CompleteAppointmentController.swift
//  Techlo
//
//  Created by Florian on 1/10/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
import Presentr
import KMPlaceholderTextView


class CompleteAppointmentController: ViewController, UITextViewDelegate {
    
    var previousValues: [String: Any]?
    
    let descriptionTextView: KMPlaceholderTextView = {
        let textView = KMPlaceholderTextView()
        textView.backgroundColor = ColorModel.returnGray()
        textView.isEditable = true
        textView.isScrollEnabled = false
        textView.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textView.placeholder = " Describe your issue here"
        textView.textContainer.maximumNumberOfLines = 10
        textView.returnKeyType = .done
        let color = UIColor(red: 0.76, green: 0.76, blue: 0.76, alpha: 1.0)
        textView.layer.borderWidth = 0.5
        textView.layer.borderColor = color.cgColor

        textView.alpha = 0.8
        textView.layer.cornerRadius = 10
        textView.clipsToBounds = true
        return textView
    }()
    
//    lazy var thumbnailButton: AddPhotoButton = {
//        let button = AddPhotoButton(type: UIButton.ButtonType.custom)
//        button.layoutStyle = .VerticalLayoutTitleDownImageUp
//        button.controller = self
//        button.backgroundColor = UIColor.flatWhiteColorDark()
//        button.setupButton()
//        button.setTitleColor(ColorModel.returnNavyDark(), for: .normal)
//        button.imageView?.tintColor = ColorModel.returnNavyDark()
//        return button
//    }()
    
    let thumbnailButton: AddPhotoButton = {
        let button = AddPhotoButton(type: UIButton.ButtonType.custom)
        button.layoutStyle = .VerticalLayoutTitleDownImageUp
        button.backgroundColor = UIColor.flatWhiteColorDark()
        button.setupButton()
        button.setTitleColor(ColorModel.returnNavyDark(), for: .normal)
        button.imageView?.tintColor = ColorModel.returnNavyDark()
        return button
    }()
    
    let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.setTitleColor(ColorModel.returnGray(), for: .normal)
        button.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
        button.isEnabled = false
        button.layer.cornerRadius = 10
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(goThroughWithSubmisson), for: .touchUpInside)
        return button
    }()
    
    lazy var presenter: Presentr = {
        let width =  ModalSize.fluid(percentage: 1)
        let height = ModalSize.fluid(percentage: 1)
        let center = ModalCenterPosition.center
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVerticalFromTop
        customPresenter.dismissTransitionType = .coverVerticalFromTop
        customPresenter.roundCorners = true
        customPresenter.backgroundColor = .clear
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = false
        customPresenter.blurBackground = true
        customPresenter.blurStyle = UIBlurEffect.Style.dark
        return customPresenter
    }()

    let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(dismissView), for: .touchUpInside)
        button.setTitle("Back", for: .normal)
        button.setTitleColor(ColorModel.returnNavyDark(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
        button.setImage(UIImage(named: "backArrow"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -8, bottom: 0, right: 0)
        return button
    }()
    
    let progressBar: UIProgressView = {
        let bar = UIProgressView(progressViewStyle: .bar)
        bar.trackTintColor = UIColor.lightGray
        bar.isHidden = true
        bar.tag = 1017
        bar.progressTintColor = ColorModel.returnNavyDark()
        return bar
    }()
    
    func enableCreateButton(){
        let isValid = (!descriptionTextView.text.isEmpty || checkForPicture())
        
        if isValid {
            createButton.isEnabled = true
            createButton.backgroundColor = ColorModel.returnNavyDark()
            createButton.setTitleColor(ColorModel.returnWhite(), for: .normal)
        } else {
            createButton.isEnabled = false
            createButton.backgroundColor = UIColor(r: 91, g: 127, b: 163, a: 1.0)
            createButton.setTitleColor(ColorModel.returnGray(), for: .normal)
        }
    }
    
    let activityIndicator = UIActivityIndicatorView(style: .gray)


    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func setupViews() {
        super.setupViews()
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        self.navigationItem.title = "Explain Issue"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]

        descriptionTextView.delegate = self
        
        let navBar = navigationController?.navigationBar
        navBar?.addSubview(progressBar)
        
        progressBar.anchor(nil, left: navBar?.leftAnchor, bottom: navBar?.bottomAnchor, right: navBar?.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 2)
        
        view.addSubview(descriptionTextView)
        view.addSubview(thumbnailButton)
        view.addSubview(createButton)
        
        if #available(iOS 11.0, *) {
            descriptionTextView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 40)
        } else {
            // Fallback on earlier versions
            descriptionTextView.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: 40)
        }
        
        let height = (view.frame.size.width - 60) * 0.7
        thumbnailButton.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 30, bottomConstant: 0, rightConstant: 30, widthConstant: 0, heightConstant: height)
        thumbnailButton.controller = self
        
        createButton.anchor(thumbnailButton.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 40, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 200, heightConstant: 60)
    
        createButton.anchorCenterXToSuperview()
        
        view.addSubview(darkView)
        view.addSubview(spinner)
        
        darkView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        spinner.anchorCenterSuperview()
        
    }
    
  @objc func goThroughWithSubmisson(){
        if checkForPicture() == false {
            noMediaAppointment()
        } else if thumbnailButton.videoUrlString == nil {
            uploadImageToFirebase()
        } else {
        uploadVideoToFirebase()
        }
    }
        
    func sendToFirebase(values: [String: Any]){
        var newValues = values
        
        guard let uid = Auth.auth().currentUser?.uid else { self.showLoading(state: false); return }
        let userAppointmentsRef = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid)
        let ref = userAppointmentsRef.childByAutoId()
        guard let refKey = ref.key else { self.showLoading(state: false); return }
        
        newValues.updateValue(refKey, forKey: "identifier")
        newValues.updateValue(false, forKey: "deposit")
        
        ref.updateChildValues(newValues) { (err, _) in
            if let err = err {
                self.showLoading(state: false)
                self.revealErrorAlert(title: "Failed", subtitle: "Cannot create appointment at this time.\n Please try again later")
                print("Failed to save appointment to DB", err)
                return
            }
            
            self.sendToMaster(values: newValues)
            //    navigatedToStartup = true
            if newValues["imageURL"] == nil {
                self.navigationController?.popToRootViewController(animated: true)
            }
            self.revealAppointmentUpdateAlert()
            self.progressBar.alpha = 0
//            print("Successfully saved appointment to DB")
        }
        
    }
    
    func sendToMaster(values: [String: Any]) {
        guard let id = values["identifier"] as? String else { return }
        let ref = Database.database().reference().child(FirebaseKey.master.rawValue).child(id)
        ref.updateChildValues(values)
    }
    
    
    func checkForPicture() -> Bool {
        guard let image = thumbnailButton.imageView?.image else { return false }
        let defaultImage = UIImage(named: "SampleAddPhoto")
        
        if image == defaultImage {
            return false
        }
        return true
    }
    
    func noMediaAppointment(){
        guard let previousValues = previousValues else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let descriptionText = descriptionTextView.text else { return }
        
        var newValues = previousValues
        
        newValues.updateValue(descriptionText, forKey: "description")
        newValues.updateValue(uid, forKey: "uid")

        sendToFirebase(values: newValues)
    }
    
    func mediaAppointment(urlString: String, urlVideoString: String?){
        guard let previousValues = previousValues else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let descriptionText = descriptionTextView.text else { return }
        guard let imageWidth = self.thumbnailButton.imageView?.image?.size.width else { return }
        guard let imageHeight = self.thumbnailButton.imageView?.image?.size.height else { return }
        
        var newValues = previousValues
        
        newValues.updateValue(descriptionText, forKey: "description")
        newValues.updateValue(urlString, forKey: "imageURL")
        newValues.updateValue(imageWidth, forKey: "imageWidth")
        newValues.updateValue(imageHeight, forKey: "imageHeight")
        newValues.updateValue(uid, forKey: "uid")

        if let urlVideoString = urlVideoString {
            newValues.updateValue(urlVideoString, forKey: "videoURL")
        }
        self.sendToFirebase(values: newValues)
    }
    
    func uploadImageToFirebase(videoUrl: String? = nil) {
        let imageName = UUID().uuidString
        let ref = Storage.storage().reference().child(FirebaseKey.attachment.rawValue).child(imageName)
        
        guard let image = thumbnailButton.imageView?.image else { return }
        
        guard let uploadData = image.jpegData(compressionQuality: 0.3) else { return }
        
        let downloadTask = ref.putData(uploadData, metadata: nil) { (metadata, error) in
            if let error = error {
                print("Failed to get metadata:", error)
            } else {
                ref.downloadURL { url, error in
                    
                    if let error = error {
                        print("Failed to download Url:", error)
                    } else {
                        guard let urlString = url?.absoluteString else { return }

                        self.mediaAppointment(urlString: urlString, urlVideoString: videoUrl)

                    }
                }
            }
        }
        
        downloadTask.observe(.progress) { (snapshot) in
            self.progressBar.isHidden = false
            self.progressBar.observedProgress = snapshot.progress
        }
        
        downloadTask.observe(.success) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatGreen()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0
            })
        }
        
        downloadTask.observe(.failure) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatRed()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0
            })
        }
        if videoUrl == nil {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    
    func uploadVideoToFirebase() {
        guard let videoString = thumbnailButton.videoUrlString, let url = URL(string: videoString) else { return }
        let filename = UUID().uuidString + ".mov"
        let storageRef = Storage.storage().reference().child(FirebaseKey.attachment.rawValue).child(filename)
        let downloadTask = storageRef.putFile(from: url, metadata: nil, completion: { (metadata, error) in
            
            if error != nil {
                print("Failed upload of video:", error!)
                self.showLoading(state: false)
                return
            }
            
            storageRef.downloadURL(completion: { (urlString, error) in
                
                if error != nil {
                    print("Failed to get downloadURL", error!)
                    return
                }
                
                guard let videoUrl = urlString?.absoluteString else { return }
                self.uploadImageToFirebase(videoUrl: videoUrl)
                
            })
        })
        
        downloadTask.observe(.progress) { (snapshot) in
            self.progressBar.isHidden = false
            self.progressBar.observedProgress = snapshot.progress
        }
        
        downloadTask.observe(.success) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatGreen()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0

            })
        }
        
        downloadTask.observe(.failure) { (snapshot) in
            self.progressBar.progressTintColor = UIColor.flatRed()
            UIView.animate(withDuration: 0.3, animations: {
                self.progressBar.alpha = 0
            })
        }
        
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    override func showLoading(state: Bool) {
        if state {
            self.darkView.isHidden = false
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.9
            })
        } else {
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0
            }, completion: { _ in
                self.darkView.isHidden = true
            })
        }
    }
    
    func checkForCustomerData(uid: String) -> Bool {
        var result = false
        let ref = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child("sourceId")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if (snapshot.exists()) {
                result = true
            }
            result =  false
        }
        print("customer data result: ", result)
        return result
    }
    
    func revealAppointmentUpdateAlert(){
        let banner = NotificationBanner(title: " Successful Appointment Request", subtitle: "Appointment will now be reviewed", style: .success)
        banner.subtitleLabel?.textAlignment = .center
        banner.titleLabel?.textAlignment = .center
        banner.duration = 3.0
        banner.show()
        self.dismiss(animated: true, completion: nil)
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        enableCreateButton()
        let size = CGSize(width: self.view.frame.width - 60, height: .infinity)
        let estimatedSize = CGSize(width: textView.sizeThatFits(size).width, height: (textView.sizeThatFits(size).height + 13))// textView.sizeThatFits(size)
        
        textView.constraints.forEach { (contraint) in
            if contraint.firstAttribute == .height {
                contraint.constant = estimatedSize.height - 7
            }
        }
    }
}
