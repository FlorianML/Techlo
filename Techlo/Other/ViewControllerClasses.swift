//
//  ViewController.swift
//  Techlo
//
//  Created by Florian on 1/19/19.
//  Copyright © 2019 LaplancheApps. All rights reserved.
//

import UIKit
import VersaPlayer
import NotificationBannerSwift
import CoreMedia

class VideoViewController: UIViewController, VersaPlayerPlaybackDelegate {
    func timeDidChange(player: VersaPlayer, to time: CMTime) {
        
    }
    
    func playbackShouldBegin(player: VersaPlayer) -> Bool {
        buffer()
        return true
    }
    
    func playbackDidJump(player: VersaPlayer) {
        buffer()
    }
    
    func playbackWillBegin(player: VersaPlayer) {
        buffer()
    }
    
    func playbackReady(player: VersaPlayer) {
        buffer()
    }
    
    func playbackDidBegin(player: VersaPlayer) {
        controls.hideBuffering()
    }
    
    func playbackDidEnd(player: VersaPlayer) {
        controls.behaviour.show()
    }
    
    func startBuffering(layer: VersaPlayer) {
        buffer()
    }
    
    func endBuffering(player: VersaPlayer) {
        controls.hideBuffering()
    }
    
    func playbackDidFailed(with error: VersaPlayerPlaybackError) {
        closePlayer()
    }
    
    
    var videoUrl: URL?
    var enableFullscreen: Bool = false
    
    lazy var videoPlayer: VersaPlayerView = {
        let play = VersaPlayerView()
        play.contentMode = .scaleAspectFill
        return play
    }()
    
    lazy var controls: VersaPlayerControls = {
        let control = VersaPlayerControls()
        
        let playPauseButton = VersaStatefulButton(type: .system)
        playPauseButton.activeImage = UIImage(named: "pause")
        playPauseButton.inactiveImage = UIImage(named: "play")
        playPauseButton.tintColor = ColorModel.returnWhite()
        
        let closeButton = UIButton(type: .system)
        closeButton.setImage(UIImage(named: "fullscreen_disable"), for: .normal)
        closeButton.addTarget(self, action: #selector(closePlayer), for: .touchUpInside)
        closeButton.tintColor = ColorModel.returnWhite()
        
        let seekbarSlider = VersaSeekbarSlider()
        seekbarSlider.tintColor = ColorModel.returnWhite()
        let currentTimeLabel = VersaTimeLabel()
        currentTimeLabel.timeFormat = "mm:ss"
        currentTimeLabel.textColor = ColorModel.returnWhite()
        let totalTimeLabel = VersaTimeLabel()
        totalTimeLabel.timeFormat = "mm:ss"
        totalTimeLabel.textColor = ColorModel.returnWhite()
        let bufferingView = UIActivityIndicatorView()
        bufferingView.color = ColorModel.returnWhite()
        
        control.playPauseButton = playPauseButton
        control.seekbarSlider = seekbarSlider
        control.currentTimeLabel = currentTimeLabel
        control.totalTimeLabel = totalTimeLabel
        control.bufferingView = bufferingView
        
        control.addSubview(playPauseButton)
        control.addSubview(currentTimeLabel)
        control.addSubview(totalTimeLabel)
        control.addSubview(seekbarSlider)
        control.addSubview(bufferingView)
        control.addSubview(closeButton)
        
        let seekbarWidth = control.frame.size.width * 0.65
        playPauseButton.anchorCenterSuperview()
                
        currentTimeLabel.anchor(nil, left: control.leftAnchor, bottom: control.bottomAnchor, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 15, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        seekbarSlider.anchor(nil, left: currentTimeLabel.rightAnchor, bottom: control.bottomAnchor, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 10, rightConstant: 0, widthConstant: seekbarWidth, heightConstant: 0)
        totalTimeLabel.anchor(nil, left: seekbarSlider.rightAnchor, bottom: control.bottomAnchor, right: control.rightAnchor, topConstant: 0, leftConstant: 10, bottomConstant: 15, rightConstant: 10, widthConstant: 0, heightConstant: 0)
        bufferingView.anchor(control.topAnchor, left: nil, bottom: nil, right: control.rightAnchor, topConstant: 30, leftConstant: 0, bottomConstant: 0, rightConstant: 20, widthConstant: 0, heightConstant: 0)
        closeButton.anchor(control.topAnchor, left: control.leftAnchor, bottom: nil, right: nil, topConstant: 20, leftConstant: 15, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        return control
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    @objc func handlePlay(){
        if videoUrl != nil {
            self.setupPlayer()
        }
    }
    
    @objc func closePlayer(){
        videoPlayer.pause()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.enableFullscreenAction()
            self.backgroundView.alpha = 0
            self.videoPlayer.alpha = 0
            self.controls.alpha = 0
        }) { _ in
            
            self.backgroundView.removeFromSuperview()
            self.videoPlayer.removeFromSuperview()
            self.controls.removeFromSuperview()
        }
    }
    
    func enableFullscreenAction(){
        if enableFullscreen == false {
            enableFullscreen = true
            self.navigationController?.setNavigationBarHidden(true, animated: true)
        } else {
            enableFullscreen = false
            self.navigationController?.setNavigationBarHidden(false, animated: true)
            guard let progressBar =  navigationController?.navigationBar.viewWithTag(1017) else { print("no tag");return }
            progressBar.alpha = 0
        }
    }
    
    func setupPlayer(){
        backgroundView.alpha = 0
        videoPlayer.alpha = 0
        controls.alpha = 0
        
        videoPlayer.layer.backgroundColor = UIColor.black.cgColor
        videoPlayer.use(controls: controls)
        
        guard let url = videoUrl else { return }
        let item = VersaPlayerItem(url: url)
        videoPlayer.set(item: item)
        
        view.addSubview(videoPlayer)
        view.addSubview(backgroundView)
        view.bringSubviewToFront(videoPlayer)
        view.addSubview(controls)
        
        backgroundView.anchor(view.topAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        videoPlayer.anchor(view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        videoPlayer.anchorCenterYToSuperview()
        
        controls.anchor(videoPlayer.topAnchor, left: videoPlayer.leftAnchor, bottom: videoPlayer.bottomAnchor, right: videoPlayer.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0)
        
        UIView.animate(withDuration: 0.3) {
            self.enableFullscreenAction()
            self.backgroundView.alpha = 1
            self.videoPlayer.alpha = 1
            self.controls.alpha = 1
            self.buffer()
            self.videoPlayer.play()
        }
    }
    
    func buffer() {
        if let buffer = controls.bufferingView as? UIActivityIndicatorView {
            buffer.startAnimating()
            controls.showBuffering()
        }
    }
}


class ViewController: UIViewController {
    lazy var darkView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.alpha = 0.9
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
    
    func showLoading(state: Bool)  {
        if state {
            self.darkView.isHidden = false
            self.spinner.isHidden = false
            self.spinner.startAnimating()
            UIView.animate(withDuration: 0.3, animations: {
                self.darkView.alpha = 0.9
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
    
    func setupViews(){
        view.backgroundColor = ColorModel.returnWhite()
        view.hideKeyboardWhenTappedAround()
    }
    
    func revealErrorAlert(title: String, subtitle: String) {
        let banner = NotificationBanner(title: title, subtitle: subtitle, style: .danger)
        banner.duration = 4.0
        banner.show()
    }
    
}
