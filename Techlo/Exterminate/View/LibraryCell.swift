//
//  LibraryCell.swift
//  Techlo
//
//  Created by Florian on 11/6/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import AVFoundation

class LibraryCell: UICollectionViewCellX {
    
    var delegate: LibraryCellDelegate?
    
    var recording: Recording? {
        didSet {
            guard let recording = recording else { return }
            
            self.recordingTitle.text = recording.title
            self.descriptionTextView.text = recording.description
            
            let date = recording.date
            let dateFormatter = DateFormatter()
            dateFormatter.amSymbol = "AM"
            dateFormatter.pmSymbol = "PM"
            dateFormatter.dateStyle = .long
            dateFormatter.timeStyle = .short
            // dateFormatter.dateFormat = "MMM dd, yyyy h:mm a"
            let dateString = dateFormatter.string(from: date)
            
            self.dateLabel.text = dateString
            
            guard let thumbnailUrl = recording.thumbnailUrl else { return }
            thumbnailImageView.loadImage(urlString: thumbnailUrl)
        }
    }
    
    
    let recordingTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .black
        label.tintColor = .black
        label.underline()
        label.text = "Appointment Session Title Label"
        return label
    }()
    
    lazy var descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.backgroundColor = .clear
        textView.isSelectable = false
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.delegate = self
        textView.font = UIFont.systemFont(ofSize: 15, weight: .light)
        textView.text = "I am #currently writing this block of text just to fill up the text view of the event cell. This is just for placeholder purposes and will be removed later. This is #this last thing I need to adjust before moving on to the next section of cell design. Later I'm going to dynamically size each cell so that there is no extra white space. I also need to be able to add a image view to this cell in case someone has a flyer they wanted to #attach.I also need to be able to add a image view to this cell in case someone has a flyer they wanted to #attach.I also need to be able to add a image view to this cell in case someone has a flyer they wanted to #attach.I also need to be able to add a image view to this cell in case someone has a flyer they wanted to #attach"
        return textView
    }()
    
    lazy var thumbnailImageView : CustomImageView = {
        let thumbnail = CustomImageView()
        thumbnail.clipsToBounds = true
        thumbnail.layer.cornerRadius = 5
        thumbnail.contentMode = .scaleAspectFill
        thumbnail.isUserInteractionEnabled = true
        thumbnail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleZoomTap)))
        return thumbnail
    }()
    
    @objc func handleZoomTap(_ tapGesture: UITapGestureRecognizer) {
        if recording?.videoUrl != nil {
            return
        }
        if let imageView = tapGesture.view as? UIImageView {
            //PRO Tip: don't perform a lot of custom logic inside of a view class
            delegate?.zoomInOnPicture(imageView: imageView)
        }
    }

    lazy var playButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let image = UIImage(named: "play")
        button.tintColor = UIColor.white
        button.setImage(UIImage(named: "SamplePlay"), for: .normal)
        
        button.addTarget(self, action: #selector(handlePlay), for: .touchUpInside)
        
        return button
    }()
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(style: .whiteLarge)
        aiv.hidesWhenStopped = true
        return aiv
    }()
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    
    @objc func handlePlay() {
        
        if let videoString = recording?.videoUrl, let videoUrl = URL(string: videoString){
            player = AVPlayer(url: videoUrl)
            
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = thumbnailImageView.bounds
            thumbnailImageView.layer.addSublayer(playerLayer!)
            
            player?.play()
            activityIndicatorView.startAnimating()
            playButton.isHidden = true
            
            print("Attempting to play video......???")
        }
    }
    
    let dateLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = .black
        label.isUserInteractionEnabled = true
        label.font = UIFont.systemFont(ofSize: 15, weight: .light)
        label.text = "Jan 23, 2019"
        return label
    }()
    
    func setupViews(){
        
        contentView.addSubview(recordingTitle)
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(descriptionTextView)
        contentView.addSubview(dateLabel)
        
        recordingTitle.anchor(self.contentView.topAnchor, left: self.contentView.leftAnchor, bottom: nil, right: nil, topConstant: 15, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        recordingTitle.anchorCenterXToSuperview()
        
        dateLabel.anchor(self.recordingTitle.bottomAnchor, left: self.contentView.leftAnchor, bottom: nil, right: nil, topConstant: 8, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        descriptionTextView.anchor(self.dateLabel.bottomAnchor, left: self.contentView.leftAnchor, bottom: nil, right: self.contentView.rightAnchor, topConstant: 0, leftConstant: 15, bottomConstant: 0, rightConstant: 15, widthConstant: 0, heightConstant: 0)
        
        setupThumbnailView()
    }
    
    func setupThumbnailView(){
        if let _ = recording?.thumbnailUrl {
            let width = UIScreen.main.bounds.size.width * 0.9
            let height = self.frame.size.height * 0.45
            thumbnailImageView.anchor(descriptionTextView.bottomAnchor, left: nil, bottom: nil, right: nil, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: width, heightConstant: height)
            thumbnailImageView.anchorCenterXToSuperview()
        } else {
            descriptionTextView.textContainer.maximumNumberOfLines = 11
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        thumbnailImageView.image = nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        
        self.shadowRadius = 10
        self.shadowOffsetY = 2
      //  self.alpha = 0.8
        self.cornerRadius = 10
        self.shadowColor = .darkGray
        self.clipsToBounds = true

        self.backgroundColor = UIColor.flatSkyBlue()
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
