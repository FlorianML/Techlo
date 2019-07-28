//
//  ModalLibraryController.swift
//  Techlo
//
//  Created by Florian on 12/29/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import AVFoundation
import Presentr
import Firebase

class FullNoteController: VideoViewController {
    
    var note: Note? {
        didSet {
            guard let note = note else { return }
              self.descriptionTextView.text = note.description
//            """
//                Techlo ("us", "we", or "our") operates the Techlo mobile application (the "Service").
//            This page informs you of our policies regarding the collection, use, and disclosure of personal
//            data when you use our Service and the choices you have associated with that data.
//            We use your data to provide and improve the Service. By using the Service, you agree to the
//            collection and use of information in accordance with this policy. Unless otherwise defined in this
//            Privacy Policy, terms used in this Privacy Policy have the same meanings as in our Terms and
//            Conditions.We use your data to provide and improve the Service. By using the Service, you agree to the
//            collection and use of information in accordance with this policy. Unless otherwise defined in this
//            Privacy Policy, terms used in this Privacy Policy have the same meanings as in our Terms and
//            Conditions
//            """
            
            let date = note.date
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .short
            let dateString = dateFormatter.string(from: date)
            dateLabel.text = "\(dateString)"

            noteTitle.text = note.title
            
            if let imageUrl = note.thumbnailUrl {
                thumbnailImageView.loadImage(urlString: imageUrl)
                setupThumbnailView()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    if self.thumbnailImageView.image?.isDark == true {
                        self.playButton.tintColor = UIColor.flatWhiteColorDark()
                    } else {
                        self.playButton.tintColor = UIColor.flatBlack()
                    }
                }
            }
            view.layoutIfNeeded()
            
            if let videoUrl = note.videoUrl {
                self.videoUrl = URL(string: videoUrl)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
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
    
    
    let noteTitle : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = ColorModel.returnNavyDark()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.text = "How to Make a Can Explode"
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
        textView.textContainer.maximumNumberOfLines = 20
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
        if note?.videoUrl != nil {
            handlePlay()
            return
        }
        
        if let _ = tapGesture.view as? UIImageView {
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
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.text = "Jan 23, 2019"
        return label
    }()
    
    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "play-button")?.withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor.flatWhiteColorDark()
        button.alpha = 0.8
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        return button
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        self.navigationItem.title = "Note"
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnNavyDark()]

        if note?.thumbnailUrl == nil {
            withoutImage()
        } else {
            withImage()
        }
        view.layoutIfNeeded()
    }
    
    func withoutImage(){
        view.addSubview(descriptionTextView)
        view.addSubview(dateLabel)
        view.addSubview(noteTitle)
        
        let buttonSize = CGSize(width: view.frame.width * 0.65, height: view.frame.height * 0.05)
        
        if #available(iOS 11.0, *) {
            noteTitle.anchor(view.safeAreaLayoutGuide.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
        } else {
            noteTitle.anchor(view.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 5, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: buttonSize.width, heightConstant: buttonSize.height)
            // Fallback on earlier versions
        }
        noteTitle.anchorCenterXToSuperview()
        
        dateLabel.anchor(noteTitle.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 10, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true

        descriptionTextView.anchor(self.dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 5, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
    }
    
    func withImage(){
        view.addSubview(scrollView)
        scrollView.addSubview(descriptionTextView)
        scrollView.addSubview(dateLabel)
        scrollView.addSubview(noteTitle)
        
        if #available(iOS 11.0, *) {
            scrollView.anchor(view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        } else {
            // Fallback on earlier versions
            scrollView.anchor(view.layoutMarginsGuide.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        }
        
            // Fallback on earlier versions
        noteTitle.anchor(scrollView.topAnchor, left: nil, bottom: nil, right: nil, topConstant: 15, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        noteTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        dateLabel.anchor(noteTitle.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 15, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        dateLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        if descriptionTextView.text != "" {
            descriptionTextView.anchor(self.dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 15, leftConstant: 13, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        }
        
    }
    
    func setScrollViewContentSize(){
        var height: CGFloat = 0
        
        let _ = scrollView.subviews.filter { (subview) -> Bool in
            height += subview.frame.height
            return true
        }
        
        height = height + 350
        scrollView.contentSize.height = height
        scrollView.contentSize = CGSize(width: 0, height: height)
    }
    
    
    func setupThumbnailView(){
        if note?.thumbnailUrl != nil {
            scrollView.addSubview(thumbnailImageView)
            
            let width = view.frame.size.width
            let height = width * 0.7
            if descriptionTextView.text != "" {
                thumbnailImageView.anchor(descriptionTextView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: height)
            } else {
                thumbnailImageView.anchor(dateLabel.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: height)
                
            }
            
            scrollView.addSubview(playButton)
            
            playButton.anchor(thumbnailImageView.topAnchor, left: thumbnailImageView.leftAnchor, bottom: thumbnailImageView.bottomAnchor, right: thumbnailImageView.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
            
            if note?.videoUrl != nil {
                playButton.isHidden = false
            } else {
                playButton.isHidden = true
            }
            setScrollViewContentSize()
        }
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

