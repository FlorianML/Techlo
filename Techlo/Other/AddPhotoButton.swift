//
//  AddPhotoButton.swift
//  VC
//
//  Created by Florian on 1/24/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit
import Firebase
import AVFoundation

class AddPhotoButton: FlexButton, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var dictionary = [String : Any]()
    var videoUrlString: String?
    var controller: CompleteAppointmentController?
    
    override init(layoutStyle style: FlexButtonLayoutStyle, frame: CGRect) {
        super.init(layoutStyle: style, frame: frame)
        setupButton()
    }
    
    func setupButton() {
        self.layer.cornerRadius = 10
        self.clipsToBounds = true
        self.setImage(UIImage(named: "SampleAddPhoto"), for: .normal)
        self.setTitle("Add Photo or Video", for: .normal)
        self.titleLabel?.font = UIFont.systemFont(ofSize: 15, weight: .light)
        self.setTitleColor(ColorModel.returnNavyDark(), for: .normal)
        self.tintColor = ColorModel.returnNavyDark()
        self.titleEdgeInsets = UIEdgeInsets(top:-25, left: 10, bottom: 25, right: 0)
        self.imageEdgeInsets = UIEdgeInsets(top: -25, left: 0, bottom: 25, right: 0)
        self.contentMode = .scaleAspectFill
        self.addTarget(self, action: #selector(handlePlusPhoto), for: .touchUpInside)
        addCancelButton()
    }
    
    let cancelButton : UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "SampleCancel")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(cancelPhoto), for: .touchUpInside)
        button.contentMode = .scaleAspectFit
        button.isHidden = true
        return button
    }()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addCancelButton(){
        self.addSubview(cancelButton)
        
        cancelButton.anchor(self.topAnchor, left: nil, bottom: nil, right: self.rightAnchor, topConstant: 4, leftConstant: 0, bottomConstant: 0, rightConstant: 4, widthConstant: 0, heightConstant: 0)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            self.setImage(getThumbnailFrom(path: videoUrl), for: .normal)
            self.imageView?.contentMode = .scaleAspectFill
            self.videoUrlString = videoUrl.absoluteString
            self.layoutStyle = .DefaultLayout
            self.layoutSubviews()
        } else {
            handleImageSelectedForInfo(info)
            self.layoutStyle = .DefaultLayout
            self.layoutSubviews()
        }
        
        self.cancelButton.isHidden = false
        self.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        controller?.enableCreateButton()
        controller?.dismiss(animated: true, completion: nil)
    }
    
    @objc func cancelPhoto(){
        self.setImage(UIImage(named: "SampleAddPhoto"), for: .normal)
        cancelButton.isHidden = true
        self.layoutStyle = .VerticalLayoutTitleDownImageUp
        self.layoutSubviews()
    }
    
    
    @objc func handlePlusPhoto() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        imagePickerController.videoMaximumDuration = 150
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        setupActionSheet(imagePickerController: imagePickerController)
    }
    
    func setupActionSheet(imagePickerController: UIImagePickerController){
        //  let title = NSMutableAttributedString(string: "Add Media", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 18, weight: .light)])
        
        
        //    let message = NSMutableAttributedString(string: "Add photos and videos from camera roll or \ncapture using the camera", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15, weight: .light)]).string
        
        let actionSheet = UIAlertController(title: "Add Media", message: "Add photos and videos from camera roll or \ncapture using the camera", preferredStyle: .actionSheet)
        //     actionSheet.setValue(title, forKey: "attributedTitle")
        let cameraOption = UIAlertAction(title: "Camera", style: .default) { _ in

            imagePickerController.sourceType = .camera
//            if AVCaptureDevice.authorizationStatus(for: .video) ==  .authorized {
//                self.controller?.present(imagePickerController, animated: true, completion: nil)
//            } else {
                AVCaptureDevice.requestAccess(for: .video, completionHandler: { (granted: Bool) in
                    if granted {
                        self.controller?.present(imagePickerController, animated: true, completion: nil)
                    } else {
                        return
                    }
                })
//            }
        }
        
        let photoAlbumOption = UIAlertAction(title: "Photos Library", style: .default) { _ in
            imagePickerController.sourceType = .photoLibrary
            self.controller?.present(imagePickerController, animated: true, completion: nil)
        }
        
        let cancelOption = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            return
        }
        
        actionSheet.addAction(cameraOption)
        actionSheet.addAction(photoAlbumOption)
        actionSheet.addAction(cancelOption)
        
        if UIDevice.current.model == "iPad" {
            let forIpadAlert = UIAlertController(title: "Add Media", message: "Add photos and videos from camera roll or \ncapture using the camera", preferredStyle: .alert)
            forIpadAlert.addAction(cameraOption)
            forIpadAlert.addAction(photoAlbumOption)
            forIpadAlert.addAction(cancelOption)
            controller?.present(forIpadAlert, animated: true, completion: nil)
            return
        }
        
        controller?.present(actionSheet, animated: true, completion: nil)
    }
    
    func handleImageSelectedForInfo(_ info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage = info[.editedImage] as? UIImage {
            self.setImage(editedImage.withRenderingMode(.alwaysOriginal), for: .normal)
        } else if let originalImage = info[.originalImage] as? UIImage {
            self.setImage(originalImage.withRenderingMode(.alwaysOriginal), for: .normal)
        }
        
    }
    func getThumbnailFrom(path: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: path , options: nil)
            let imgGenerator = AVAssetImageGenerator(asset: asset)
            imgGenerator.appliesPreferredTrackTransform = true
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let thumbnail = UIImage(cgImage: cgImage)
            
            return thumbnail
            
        } catch let error {
            print("*** Error generating thumbnail: \(error.localizedDescription)")
            return nil
        }
    }
}
