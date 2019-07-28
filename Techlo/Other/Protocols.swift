//
//  Protocols.swift
//  Techlo
//
//  Created by Florian on 11/14/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

protocol LibraryCellDelegate {
    func zoomInOnPicture(imageView: UIImageView)
}

protocol VibrantCellDelegate {
    func goTo(index: Int)
}
