//
//  LibraryPreviewCell.swift
//  Techlo
//
//  Created by Florian on 12/29/18.
//  Copyright © 2018 LaplancheApps. All rights reserved.
//

import UIKit

class NotePreviewCell: UICollectionViewCellX {
    
    var note: Note? {
        didSet {
            guard let note = note else { return }
            
            self.noteTitle.text = note.title
            
            let date = note.date
            let dateFormatter = DateFormatter()

          //  dateFormatter.dateStyle = .short
           // dateFormatter.timeStyle = .none
             dateFormatter.dateFormat = "MMMM dd, yyyy"
            let dateString = dateFormatter.string(from: date)
            
            self.dateLabel.text = dateString

        }
    }
    
    let separatorLineView: UIView = {
        let lineView = UIView()
        lineView.backgroundColor = ColorModel.returnCollectionViewColor()
        lineView.isHidden = false
        return lineView
    }()
    
    let dateLabel : UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.textColor = ColorModel.returnNavyDark()//ColorModel.returnWhite() //.black
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 14, weight: .light)
        label.text = "Jan 23, 2019"
        return label
    }()
    
    let noteTitle: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = UIFont.systemFont(ofSize: 16, weight: .light)
        label.textColor = ColorModel.returnNavyDark() // ColorModel.returnWhite()
        label.text = "Appointment Session Title Label"
        label.textAlignment = .center
        return label
    }()
    
    func setupViews() {
        self.backgroundColor =  ColorModel.returnWhite()//ColorModel.returnNavyDark()
//        noteTitle.font = UIFont.systemFont(ofSize: 17, weight: .light)
//        dateLabel.font = UIFont.systemFont(ofSize: 15, weight: .light)
        
        contentView.addSubview(noteTitle)
        contentView.addSubview(dateLabel)
        
        noteTitle.anchor(self.topAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 8, leftConstant: 5, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
        dateLabel.anchor(noteTitle.bottomAnchor, left: self.leftAnchor, bottom: nil, right: self.rightAnchor, topConstant: 2, leftConstant: 5, bottomConstant: 0, rightConstant: 5, widthConstant: 0, heightConstant: 0)
        
        contentView.addSubview(separatorLineView)

        separatorLineView.anchor(nil, left: leftAnchor, bottom: bottomAnchor, right: rightAnchor, topConstant: 0, leftConstant: 0, bottomConstant: 0, rightConstant: 0, widthConstant: 0, heightConstant: 0.75)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

