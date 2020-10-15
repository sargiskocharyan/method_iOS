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
    @IBOutlet weak var leadingConstraintOfMarkImageView: NSLayoutConstraint?
    
    @IBOutlet weak var markImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        userImageView.image = UIImage(named: "noPhoto")
        leadingConstraintOfMarkImageView?.constant -= 15
        leadingConstraintOfImageView?.constant -= 15
        markImageView?.isHidden = true
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
//        markImageView?.setImage(nil, for: .normal)
        markImageView?.image = nil
    }
    
    func setCheckImage() {
        if isSelected  {
//            markImageView?.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
            markImageView?.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
//            markImageView?.setImage(UIImage.init(systemName: "checkmark.circle"), for: .normal)
            markImageView?.image = UIImage(systemName: "checkmark.circle")
        }
    }
    
    func setCheckButton(isPreview: Bool) {
        if isPreview {
            leadingConstraintOfMarkImageView?.constant = -10
            leadingConstraintOfImageView?.constant = -5
            markImageView?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfMarkImageView?.constant = 10
            leadingConstraintOfImageView?.constant = 15
            markImageView?.isHidden = false
        }
    }
    
    func editPage(isPreview: Bool?) {
        if isPreview == true {
            leadingConstraintOfMarkImageView?.constant -= 20
            leadingConstraintOfImageView?.constant -= 20
            markImageView?.isHidden = true
        } else if isPreview == false {
            leadingConstraintOfMarkImageView?.constant += 20
            leadingConstraintOfImageView?.constant += 20
            markImageView?.isHidden = false
        }
    }
    
    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 15
        messageLabel.clipsToBounds = true
        messageLabel.layer.cornerRadius = 10
    }
}
