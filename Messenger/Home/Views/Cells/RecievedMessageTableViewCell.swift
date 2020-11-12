//
//  RecieveMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class RecievedMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfImageView: NSLayoutConstraint?
    @IBOutlet weak var leadingConstraintOfCheckImage: NSLayoutConstraint?
    
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        userImageView.image = UIImage(named: "noPhoto")
        leadingConstraintOfCheckImage?.constant -= 15
        leadingConstraintOfImageView?.constant -= 15
        checkImage?.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImage?.image = nil
    }
    
    func setCheckImage() {
        if isSelected  {
            checkImage.image = UIImage.init(systemName: "checkmark.circle.fill")
        } else {
            
            checkImage.image = UIImage.init(systemName: "circle")
        }
    }
    
    func setCheckButton(isPreview: Bool) {
        if isPreview {
            leadingConstraintOfCheckImage?.constant = -10
            leadingConstraintOfImageView?.constant = -5
            checkImage?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfCheckImage?.constant = 10
            leadingConstraintOfImageView?.constant = 15
            checkImage?.isHidden = false
        }
    }
    
    func editPage(isPreview: Bool?) {
        if isPreview == true {
            leadingConstraintOfCheckImage?.constant -= 20
            leadingConstraintOfImageView?.constant -= 20
            checkImage.isHidden = true
        } else if isPreview == false {
            leadingConstraintOfCheckImage?.constant += 20
            leadingConstraintOfImageView?.constant += 20
            checkImage.isHidden = false
        }
    }
    
    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 15
        messageLabel.clipsToBounds = true
        messageLabel.layer.cornerRadius = 10
    }
}
