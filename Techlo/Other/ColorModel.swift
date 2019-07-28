//
//  ColorModel.swift
//  VC
//
//  Created by Florian on 1/30/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

var darkMode: Bool = false

struct ColorModel {
    
    private let colors = [UIColor(red: 184/255.0, green: 233/255.0, blue: 134/255.0, alpha: 1.0),
                  UIColor(r: 32, g: 158, b: 255, a: 1.0),
                  UIColor(white: 1, alpha: 0.97), UIColor(r: 225, g: 225, b: 225), UIColor(r: 64, g: 171, b: 254, a: 1.0)]
    


    static func returnGray() -> UIColor {
        return ColorModel().colors[2]
    }
    
    static func returnCollectionViewColor() -> UIColor {
        return ColorModel().colors[3]
    }
    
    static func returnNavyDark() -> UIColor {
        return UIColor.flatNavyBlueColorDark()
    }
    
    static func returnWhite() -> UIColor {
        return UIColor.flatWhite()
    }

}
