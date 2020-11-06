//
//  SendMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class SendMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var readMessage: UILabel!
    @IBOutlet weak var checkImageView: UIImageView?
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfChaeckImage: NSLayoutConstraint?
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        isSelected = false
        leadingConstraintOfChaeckImage?.constant = -10
        checkImageView?.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImageView?.image = nil
        
    }
    
   func setCheckButton(isPreview: Bool) {
       if isPreview {
           leadingConstraintOfChaeckImage?.constant = -10
           checkImageView?.isHidden = true
       } else if !isPreview {
           leadingConstraintOfChaeckImage?.constant = 10
           checkImageView?.isHidden = false
       }
   }
   
   func setCheckImage() {
       if isSelected  {
           checkImageView?.image = UIImage.init(systemName: "checkmark.circle.fill")
       } else {
           checkImageView?.image = UIImage.init(systemName: "circle")
       }
   }
   
   func changeShapeOfImageView() {
       messageLabel.clipsToBounds = true
       messageLabel.layer.cornerRadius = 10
   }
}
