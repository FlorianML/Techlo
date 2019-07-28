//
//  AppointmentDetailsController.swift
//  Techlo
//
//  Created by Florian on 1/12/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import Presentr
import Firebase
import AVFoundation

class AppointmentDetailsController: VideoViewController {

    var appointment: Appointment? {
        didSet {
            
            guard let appointment = appointment else { return }
              self.descriptionTextView.text = appointment.description
            
            let date = appointment.date
            
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "am"
            dateFormatter.pmSymbol = "pm"
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            dateFormatter.dateFormat = "MMM dd, yyyy @ h:mm a"
            let dateString = dateFormatter.string(from: date)
            
            dateLabel.text = "Date: \n\(dateString)"
            locationLabel.text = "Location: \n\(appointment.location)"
            
            if appointment.quote == 0 {
                self.quoteLabel.text = "Quote: Pending Review"
            } else {
                self.quoteLabel.text = "Quote: $\(appointment.quote)"
            }
            
            if let response = appointment.response {
                partyTime(response: response)
            }
            if let imageUrl = appointment.imageUrl {
                thumbnailImageView.loadImage(urlString: imageUrl)
                setupThumbnailView()
            }
            view.layoutIfNeeded()
            
            if let videoUrl = appointment.videoUrl {
                self.videoUrl = URL(string: videoUrl)
             }
        }
    }
    
    lazy var scrollView : UIScrollView = {
        let view = UIScrollView()
        view.backgroundColor = .clear
        view.isUserInteractionEnabled = true
        view.alwaysBounceVertical = true
        view.alwaysBounceHorizontal = false
        view.showsHorizontalScrollIndicator = false
        view.autoresizingMask = .flexibleHeight
        view.isScrollEnabled = true
        return view
    }()
    
    var startingFrame: CGRect?
    var blackBackgroundView: UIView?
    var startingImageView: UIImageView?
    
    let locationLabel: UILabel = {
        let label = UILabel()
        label.text = "5113 Madison Green Dr, Mableton, GA 30126"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 15, weight: .bold)
        label.textAlignment = .center
        label.textColor = ColorModel.returnNavyDark()
        label.backgroundColor = .clear
        return label
    }()
    
    let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isSelectable = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textAlignment = .justified
        textView.textColor = ColorModel.returnNavyDark()
        textView.textContainer.lineBreakMode = .byWordWrapping
        textView.textContainer.maximumNumberOfLines = 11
        textView.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textView.text = "I am currently writing this block of text just to fill up the text view of the event cell. This is just for placeholder purposes and will be removed later. This is this last thing I need to adjust before moving on to the next section of cell design. Later I'm going to dynamically size each cell so that there is no extra white space. I also need to be able to add a image view to this cell in case someone has a flyer they wanted to attach. I am currently writing this block of text just to fill up the text view of the event cell. This is just for placeholder purposes and will be removed later. This is this last thing I need to adjust before moving on to the next section of cell design. Later I'm going to dynamically size each cell so that there is no extra white space. I also need to be able to add a image view to this cell in case someone has a flyer they wanted to attach"
        return textView
    }()
    
    lazy var thumbnailImageView : CustomImageView = {
        let thumbnail = CustomImageView()
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 5
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.isUserInteractionEnabled = true
        thumbnail.backgroundColor = UIColor.flatWhiteColorDark()
        thumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return thumbnail
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if appointment?.videoUrl != nil {
            handlePlay()
            return
        }
        
        if let _ = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            performZoomInForStartingImageView(thumbnailImageView)
        }
    }
    
    let dateLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = ColorModel.returnNavyDark()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Jan 23, 2019"
        return label
    }()
    
    let quoteLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = ColorModel.returnNavyDark()
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "Quote: $30"
        label.textAlignment = .center
        return label
    }()
    
    lazy var responseLabel : UILabelX = {
        let label = UILabelX()
        label.textColor = ColorModel.returnNavyDark()
        label.isUserInteractionEnabled = true
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.text = "Pending Review"
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openOptions)))
        
        label.cornerRadius = 10
        label.clipsToBounds = true
        return label
    }()
    
    lazy var presenter: Presentr = {
        let width =  ModalSize.fluid(percentage: 0.9)
        let height = ModalSize.fluid(percentage: 0.5)
        let center = ModalCenterPosition.topCenter
        let customType = PresentationType.custom(width: width, height: height, center: center)
        
        let customPresenter = Presentr(presentationType: customType)
        customPresenter.transitionType = .coverVertical
        customPresenter.dismissTransitionType = .coverVertical
        customPresenter.roundCorners = true
        customPresenter.backgroundColor = ColorModel.returnWhite()
        customPresenter.backgroundOpacity = 0.5
        customPresenter.dismissOnSwipe = false
        customPresenter.blurBackground = true
        customPresenter.blurStyle = UIBlurEffect.Style.dark
        return customPresenter
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play-button")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.flatWhiteColorDark()
        button.alpha = 0.8
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        
        navigationItem.title = "Appointment Details"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]
        
        if appointment?.imageUrl == "" {
            withoutImage()
        } else {
            withImage()
        }
        view.layoutIfNeeded()
        checkForDeposit()
    }
    
    func withoutImage(){
        view.addSubview(locationLabel)
        view.addSubview(thumbnailImageView)
        view.addSubview(descriptionTextView)
        view.addSubview(dateLabel)
        view.addSubview(responseLabel)
        view.addSubview(quoteLabel)
        
        let buttonSize = CGSize(width: view.frame.width * 0.65, height: view.frame.height * 0.05)
        if #available(iOS 11.0, *) {
            responseLabel.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
        } else {
            responseLabel.anchor(view.layoutMarginsGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
            // Fallback on earlier versions
        }
        responseLabel.anchorCenterXToSuperview()
        
        dateLabel.anchor(responseLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        dateLabel.anchorCenterXToSuperview()
        
        locationLabel.anchor(dateLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        locationLabel.anchorCenterXToSuperview()
        
        quoteLabel.anchor(locationLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        descriptionTextView.anchor( quoteLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
    }
    
    func withImage(){
        
        view.addSubview(scrollView)
        scrollView.addSubview(locationLabel)
        scrollView.addSubview(thumbnailImageView)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(responseLabel)
        scrollView.addSubview(quoteLabel)
        
        if #available(iOS 11.0, *) {
            scrollView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        } else {
            // Fallback on earlier versions
            scrollView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        
        
        let buttonSize = CGSize(width: view.frame.width * 0.65, height: view.frame.height * 0.05)
        responseLabel.anchor(scrollView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
        responseLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        dateLabel.anchor(responseLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 25, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        locationLabel.anchor(dateLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        quoteLabel.anchor(locationLabel.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 10, leftConstant: 15, bottomConstant: 15, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        quoteLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        if appointment?.description != "" {
            descriptionTextView.anchor(quoteLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        }
    }

    func setScrollViewContentSize(){
        var height: CGFloat = 0

    
        let _ = scrollView.subviews.filter { (subview) -> Bool in
            height += subview.frame.height
            return true
        }

        height = height + 85
        scrollView.contentSize.height = height
        scrollView.contentSize = CGSize(width: 0, height: height)
        
        
    }

    func setupThumbnailView(){
        if appointment?.imageUrl != nil {
            scrollView.addSubview(thumbnailImageView)
            
            let width = view.frame.size.width
            let height = width * 0.7
            if appointment?.description != "" {
                thumbnailImageView.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 35, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: height)
            } else {
                thumbnailImageView.anchor(quoteLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 35, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: height)
            }
            
            scrollView.addSubview(playButton)
            
            playButton.anchor(thumbnailImageView.topAnchor, left: thumbnailImageView.leftAnchor, bottom: thumbnailImageView.bottomAnchor, right: thumbnailImageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)

            if appointment?.videoUrl != nil {
                playButton.isHidden = false
            } else {
                playButton.isHidden = true
            }
            setScrollViewContentSize()
        }
    }
    
    func partyTime(response: AppointmentResponse) {
        switch response {
        case .pendingSpecialistApproval:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = AppointmentResponseTitle.pending.rawValue
            
        case .pendingForCustomerApproval:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = "Needs Approval"
            
        case .specialistApproved, .customerApproved:
            responseLabel.backgroundColor = UIColor.flatMint()
            responseLabel.text = AppointmentResponseTitle.approved.rawValue
            
        case .specialistDenied, .customerDenied:
            responseLabel.backgroundColor = UIColor.flatRed()
            responseLabel.text = AppointmentResponseTitle.denied.rawValue
            
        case .specialistCancelled, .customerCancelled:
            responseLabel.backgroundColor = UIColor.flatRed()
            responseLabel.text = AppointmentResponseTitle.cancelled.rawValue
            
        case .appointmentCompleted:
            responseLabel.backgroundColor = UIColor.flatMint()
            responseLabel.text = AppointmentResponseTitle.completed.rawValue
            
        case .contactRequested:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = AppointmentResponseTitle.contactRequested.rawValue
            
        case .appointmentChanged:
            responseLabel.backgroundColor = UIColor.flatYellowColorDark()
            responseLabel.text = AppointmentResponseTitle.appointmentChanged.rawValue
        }
    }
    
    
    @objc func openOptions(){
      //  let title = NSMutableAttributedString(string: "Appointment Status", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light)])
        let alert = UIAlertController(title: "Appointment Status", message: nil, preferredStyle: .actionSheet)
    //    alert.setValue(title, forKey: "attributedTitle")
        
        guard let response = appointment?.response else { return }
        let actions = createActionSheet(response: response)
        
        if actions.count > 0 {
            for action in actions {
                alert.addAction(action)
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
                alert.dismiss(animated: true, completion: nil)
            }
            alert.addAction(cancelAction)
            
            customPresentViewController(presenter, viewController: alert, animated: true)
        } else {
            print("no options")
        }
    }
    
    @objc func appointmentStatusOptionChange(response: Int){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let id = appointment?.identifier else { return }
        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(id)
        let masterRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(id)
        
        guard let appointmentResponse = AppointmentResponse(rawValue: response) else { return }
        partyTime(response: appointmentResponse)
        
        switch appointmentResponse {
        case .pendingSpecialistApproval:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.pending.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.pending.rawValue, "status": response])

        case .pendingForCustomerApproval:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.pendingForCustomerApproval.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.pendingForCustomerApproval.rawValue, "status": response])

        case .specialistApproved:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": response])
            
        case .customerApproved:
                self.checkForDeposit()
            
        case .specialistDenied, .customerDenied:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.customerDenied.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.customerDenied.rawValue, "status": response])

        case .specialistCancelled, .customerCancelled:
            let action = UIAlertAction(title: "Yes", style: .default) { _ in
                ref.updateChildValues(["statusTitle": AppointmentResponseTitle.cancelled.rawValue, "status": response])
                masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.cancelled.rawValue, "status": response])
            }
            
            let alert = UIAlertController.alertWithAddedAction(title: "Cancel Appointment", message: "Are you sure you would like \n to cancel your appointment? If appointment time\n is within 24 hours, you will be subject to \n a 50% cancellation fee.", action: action)
            self.present(alert, animated: true, completion: nil)
            
        case .appointmentCompleted:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.completed.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.completed.rawValue, "status": response])

        case .contactRequested:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.contactRequested.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.contactRequested.rawValue, "status": response])

        case .appointmentChanged:
            ref.updateChildValues(["statusTitle": AppointmentResponseTitle.appointmentChanged.rawValue, "status": response])
            masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.appointmentChanged.rawValue, "status": response])
        }
    }
    
    
    func createActionSheet(response: AppointmentResponse) -> [UIAlertAction] {
        
        var actions = [UIAlertAction]()
        
        switch response {
        case .pendingSpecialistApproval, .specialistApproved, .appointmentChanged, .customerApproved:
            actions.append(createAlertForStatus(title: .cancelled))
            actions.append(createAlertForStatus(title: .request))
            
        case .pendingForCustomerApproval:
            actions.append(createAlertForStatus(title: .approve))
            actions.append(createAlertForStatus(title: .denied))
            actions.append(createAlertForStatus(title: .cancelled))
            actions.append(createAlertForStatus(title: .request))
            
        case .appointmentCompleted, .customerCancelled, .customerDenied, .specialistDenied: break
            
        case .specialistCancelled:
            actions.append(createAlertForStatus(title: .request))
            
        case .contactRequested:
            actions.append(createAlertForStatus(title: .contact))
        }
        return actions
    }
    
    func createAlertForStatus(title: DropDownCellTitle) -> UIAlertAction {
        var alert = UIAlertAction()
        
        switch title {
        case .approve:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.customerApproved.rawValue)
            })
        case .denied:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.customerDenied.rawValue)
            })
        case.cancelled:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                self.appointmentStatusOptionChange(response: AppointmentResponse.customerCancelled.rawValue)
            })
        case.request:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                //                self.appointmentStatusOptionChange(response: AppointmentResponse.pendingSpecialistApproval.rawValue)
                
                let editApptController = EditAppointmentController()
                editApptController.appointment = self.appointment
                let navController = UINavigationController(rootViewController: editApptController)
                
                let width =  ModalSize.fluid(percentage: 1)
                let height = ModalSize.fluid(percentage: 1)
                let center = ModalCenterPosition.center
                let customType = PresentationType.custom(width: width, height: height, center: center)
                
                self.presenter.presentationType = customType
                self.customPresentViewController(self.presenter, viewController: navController, animated: true)
                
            })
        case.contact:
            alert = UIAlertAction(title: title.rawValue, style: .default, handler: { _ in
                
                guard let uid = Auth.auth().currentUser?.uid else { return }
                Database.fetchUserWithUID(uid: uid, completion: { (user) in
                    if user.phone == nil {
                        let phoneController = PhoneChangeController()
                        phoneController.user = user
                        self.navigationController?.pushViewController(phoneController, animated: true)
                        return
                    }
                })
                self.appointmentStatusOptionChange(response: AppointmentResponse.contactRequested.rawValue)
            })
        }
        
        return alert
    }
    
    func checkForDeposit(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let apptId = appointment?.identifier else { return }
        
        let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(apptId).child("deposit")
        
        ref.observeSingleEvent(of: .value) { (snapshot) in
            if !snapshot.exists() && self.appointment?.quote != 0  {
                let sourceRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child("sourceId")
                
                sourceRef.observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {
                        self.alertForDeposit()
                    } else {
                        self.alertForAddingCard()
                    }
                })
            }
        }
    }
    
    
    func alertForDeposit(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let action = UIAlertAction(title: "Yes", style: .default) { _ in
            //    self.showLoading(state: true)
            let chargeRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.charge.rawValue).childByAutoId()
            
            let sourcesRef = Database.database().reference().child(FirebaseKey.customer.rawValue).child(uid).child(FirebaseKey.source.rawValue).child("sourceId")
            
            sourcesRef.observeSingleEvent(of: .value, with: { (snapshot) in
                guard let paymentSourceId = snapshot.value as? String else { return }
                
                let values = ["amount": 199, "source": paymentSourceId, "description": "Techlo Appointment Deposit: $1.99"] as [String: Any]
                chargeRef.updateChildValues(values)
                
                guard let apptId = self.appointment?.identifier else { return }
                let apptRef = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(apptId)
                apptRef.updateChildValues(["deposit": true])
                
                let ref = Database.database().reference().child(FirebaseKey.appointment.rawValue).child(uid).child(apptId)
                let masterRef = Database.database().reference().child(FirebaseKey.master.rawValue).child(apptId)
                
                ref.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": AppointmentResponse.customerApproved.rawValue])
                masterRef.updateChildValues(["statusTitle": AppointmentResponseTitle.approved.rawValue, "status": AppointmentResponse.customerApproved.rawValue])
            })
        }
        
        let alert = UIAlertController.alertWithAddedAction(title: "Deposit", message: "A deposit of $1.99 is required to set up\n an appointment. Would you like to\n make the deposit? ", action: action)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func alertForAddingCard(){
        let action = UIAlertAction(title: "Update", style: .default) { _ in
            let cardController = CardController()
            cardController.navigatedTo = true
            cardController.appointmentId = self.appointment?.identifier
            let navController = UINavigationController(rootViewController: cardController)
            
            self.present(navController, animated: true, completion: nil)
        }
        
        let alert = UIAlertController.alertWithAddedAction(title: "Update Card Information", message: "Deposit of $1.99 is required to set up\n an appointment. If you decide to\n cancel appointment up to 24 hours\n before appointment time, your deposit\n will be refunded in full. Any time\n after will result in a 50%\n cancellation fee charge", action: action)
        
        self.present(alert, animated: true, completion: nil)
    }

    
    func performZoomInForStartingImageView(_ startingImageView: UIImageView) {
        
        self.startingImageView = startingImageView
        self.startingImageView?.isHidden = true
        
        startingFrame = startingImageView.superview?.convert(startingImageView.frame, to: nil)
        
        let zoomingImageView = UIImageView(frame: startingFrame!)
        zoomingImageView.backgroundColor = UIColor.red
        zoomingImageView.image = startingImageView.image
        zoomingImageView.isUserInteractionEnabled = true
        zoomingImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow {
            blackBackgroundView = UIView(frame: keyWindow.frame)
            blackBackgroundView?.backgroundColor = UIColor.black
            blackBackgroundView?.alpha = 0
            keyWindow.addSubview(blackBackgroundView!)
            
            keyWindow.addSubview(zoomingImageView)
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                self.blackBackgroundView?.alpha = 1
                
                // math?
                // h2 / w1 = h1 / w1
                // h2 = h1 / w1 * w1
                let height = self.startingFrame!.height / self.startingFrame!.width * keyWindow.frame.width
                
                zoomingImageView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                
                zoomingImageView.center = keyWindow.center
                
            }, completion: { (completed) in
                //                    do nothing
            })
            
        }
    }
    
    @objc func handleZoomOut(_ tapGesture: UITapGestureRecognizer) {
        if let zoomOutImageView = tapGesture.view {
            //need to animate back out to controller
            zoomOutImageView.layer.cornerRadius = 16
            zoomOutImageView.clipsToBounds = true
            
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                
                zoomOutImageView.frame = self.startingFrame!
                self.blackBackgroundView?.alpha = 0
                
            }, completion: { (completed) in
                zoomOutImageView.removeFromSuperview()
                self.startingImageView?.isHidden = false
            })
        }
    }
}


