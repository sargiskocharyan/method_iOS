//
//  RecieveImageMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 10/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class RecieveImageMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var viewUnderImage: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sendImageView: UIImageView!
    @IBOutlet weak var leadingConstraintOfImageView: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var leadingConstraintOfCheckImage: NSLayoutConstraint!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkImage: UIImageView!


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        sendImageView?.contentMode = .scaleAspectFill
        userImageView.image = UIImage(named: "noPhoto")
        leadingConstraintOfCheckImage?.constant -= 15
        leadingConstraintOfImageView?.constant -= 15
        checkImage?.isHidden = true
        viewUnderImage.clipsToBounds = true
        viewUnderImage.layer.cornerRadius = 10
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
    }
    
}
