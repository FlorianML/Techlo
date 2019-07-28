//
//  EmptyCell.swift
//  Techlo
//
//  Created by Florian on 11/21/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

class EmptyCell: UICollectionViewCell {
    
    let emptyMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "No appointment notes have been saved"
        label.textColor = ColorModel.returnNavyDark()
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        return label
    }()
    
    func setupLabel(){
        self.backgroundColor = ColorModel.returnWhite()
        contentView.addSubview(emptyMessageLabel)
        
        emptyMessageLabel.anchorCenterXToSuperview()
        emptyMessageLabel.anchorCenterYToSuperview(constant: -10)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
