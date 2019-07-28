//
//  VibrantCell.swift
//  Pods
//
//  Created by Jon Kent on 1/14/16.
//
//

import UIKit

open class VibrantCell: UITableViewCell {
    
    var delegate: VibrantCellDelegate?
    
    var indexRow: Int? {
        didSet {
            guard let index = indexRow else { return }
            switch index {
            case 0:
                self.textLabel?.text = "Email"
                self.iconImageView.image = UIImage(named: "EmailIcon")?.withRenderingMode(.alwaysTemplate)
                
            case 1:
                self.textLabel?.text = "Password"
                self.iconImageView.image = UIImage(named: "lock")?.withRenderingMode(.alwaysTemplate)

            case 2:
                self.textLabel?.text = "Phone Number"
                self.iconImageView.image = UIImage(named: "telephone")?.withRenderingMode(.alwaysTemplate)

            case 3:
                self.textLabel?.text = "Card Information"
                self.iconImageView.image = UIImage(named: "wallet")?.withRenderingMode(.alwaysTemplate)

            case 4:
                self.textLabel?.text = "Push Notifications"
                self.iconImageView.image = UIImage(named: "bell-symbol")?.withRenderingMode(.alwaysTemplate)

            case 5:
                self.textLabel?.text = "Privacy Policy"
                self.iconImageView.image = UIImage(named: "contract")?.withRenderingMode(.alwaysTemplate)
            default:
                self.textLabel?.text = "Log Out"
                self.iconImageView.image = UIImage(named: "logout")?.withRenderingMode(.alwaysTemplate)

            }
           textLabel?.textColor = ColorModel.returnNavyDark()
            //ColorModel.returnCollectionViewColor()
            textLabel?.font = UIFont.systemFont(ofSize: 16, weight: .light)
            
        }
    }
    
    lazy var iconImageView : UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFit
        return icon
    }()
    
    func setupViews(){
        self.tintColor = ColorModel.returnNavyDark()//ColorModel.returnCollectionViewColor()
        addSubview(iconImageView)
        
        iconImageView.anchor(nil, left: self.leftAnchor, bottom: nil, right: nil, topConstant: 0, leftConstant: 10, bottomConstant: 0, rightConstant: 0, widthConstant: 15, heightConstant: 15)
        iconImageView.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0).isActive = true
    }
    
    fileprivate var vibrancyView:UIVisualEffectView = UIVisualEffectView()
    fileprivate var vibrancySelectedBackgroundView:UIVisualEffectView = UIVisualEffectView()
    fileprivate var defaultSelectedBackgroundView:UIView?
    open var blurEffectStyle: UIBlurEffect.Style? {
        didSet {
            updateBlur()
        }
    }
    
    // For registering with UITableView without subclassing otherwise dequeuing instance of the cell causes an exception
    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        vibrancyView.frame = bounds
        vibrancyView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        for view in subviews {
            vibrancyView.contentView.addSubview(view)
        }
        addSubview(vibrancyView)
        
        let blurSelectionEffect = UIBlurEffect(style: .light)
        vibrancySelectedBackgroundView.effect = blurSelectionEffect
        defaultSelectedBackgroundView = selectedBackgroundView
        
        updateBlur()
        setupViews()
    }
    
    internal func updateBlur() {
        // shouldn't be needed but backgroundColor is set to white on iPad:
       //backgroundColor = UIColor(r: 32, g: 158, b: 255, a: 0.5)
        backgroundColor = .clear
        
        if let blurEffectStyle = blurEffectStyle, !UIAccessibility.isReduceTransparencyEnabled {
            let blurEffect = UIBlurEffect(style: blurEffectStyle)
            vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect)
            
            if selectedBackgroundView != nil && selectedBackgroundView != vibrancySelectedBackgroundView {
                vibrancySelectedBackgroundView.contentView.addSubview(selectedBackgroundView!)
                selectedBackgroundView = vibrancySelectedBackgroundView
            }
        } else {
            vibrancyView.effect = nil
            selectedBackgroundView = defaultSelectedBackgroundView
        }
    }
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 35, y: textLabel!.frame.origin.y - 0, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 35, y: detailTextLabel!.frame.origin.y , width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
        
    }
}
