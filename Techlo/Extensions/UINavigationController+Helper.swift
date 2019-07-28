//
//  UINavigationController+Helper.swift
//  VendorMatch
//
//  Created by Florian on 2/10/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit


public extension UINavigationController {
    
    /**
     Pop current view controller to previous view controller.
     
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func pop(transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popViewController(animated: false)
    }
    
    func popAll(transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.popToRootViewController(animated: false)
    }
    
    /**
     Push a new view controller on the view controllers's stack.
     
     - parameter vc:       view controller to push.
     - parameter type:     transition animation type.
     - parameter duration: transition animation duration.
     */
    func push(viewController vc: UIViewController, transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        self.addTransition(transitionType: type, subtype: subtype, duration: duration)
        self.pushViewController(vc, animated: false)
    }
    
    private func addTransition(transitionType type: CATransitionType, subtype: CATransitionSubtype, duration: CFTimeInterval) {
        let transition = CATransition()
        transition.duration = duration
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = type
        transition.subtype = subtype
        self.view.layer.add(transition, forKey: nil)
    }
    
    func whiteNavBar(){
        self.navigationBar.shadowImage = UIImage()
        self.navigationBar.setBackgroundImage(UIImage(), for: .default)
        
        let separatorLineView = UIView()
        separatorLineView.backgroundColor = ColorModel.returnCollectionViewColor()

        self.navigationBar.addSubview(separatorLineView)

        separatorLineView.anchor(nil, left: self.navigationBar.leftAnchor, bottom: self.navigationBar.bottomAnchor, right: self.navigationBar.rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.5)
    }
    
    func stylizeNavBar(){
        
        self.navigationBar.isTranslucent = true
        self.navigationBar.barTintColor = ColorModel.returnNavyDark() //ColorModel.returnNavyDark()
        self.navigationBar.tintColor = ColorModel.returnWhite()

        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : ColorModel.returnWhite(), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20, weight: .light)]
    }
    
}
