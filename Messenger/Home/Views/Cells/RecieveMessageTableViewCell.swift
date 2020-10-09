//
//  RecieveMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class RecieveMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var leadingConstraintOfImageView: NSLayoutConstraint?
    @IBOutlet weak var leadingConstraintOfButton: NSLayoutConstraint?
    
    @IBOutlet weak var button: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        userImageView.image = UIImage(named: "noPhoto")
        leadingConstraintOfButton?.constant -= 15
        leadingConstraintOfImageView?.constant -= 15
        button?.isHidden = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        button?.setImage(nil, for: .normal)
    }
    
    func setCheckImage() {
        if isSelected  {
            button?.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            button?.setImage(UIImage.init(systemName: "checkmark.circle"), for: .normal)
        }
    }
    
    func setCheckButton(isPreview: Bool) {
        if isPreview {
            leadingConstraintOfButton?.constant = -10
            leadingConstraintOfImageView?.constant = -5
            button?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfButton?.constant = 10
            leadingConstraintOfImageView?.constant = 15
            button?.isHidden = false
        }
    }
    
    func editPage(isPreview: Bool?) {
        if isPreview == true {
            leadingConstraintOfButton?.constant -= 20
            leadingConstraintOfImageView?.constant -= 20
            button.isHidden = true
        } else if isPreview == false {
            leadingConstraintOfButton?.constant += 20
            leadingConstraintOfImageView?.constant += 20
            button.isHidden = false
        }
    }
    
    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 15
        messageLabel.clipsToBounds = true
        messageLabel.layer.cornerRadius = 10
    }
}
