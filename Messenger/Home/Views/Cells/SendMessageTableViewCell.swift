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
    @IBOutlet weak var button: UIButton?
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfButton: NSLayoutConstraint?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        isSelected = false
        leadingConstraintOfButton?.constant = -10
        button?.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        button?.setImage(nil, for: .normal)
        
    }
    
//    func editPage(isPreview: Bool) {
//        if !isPreview {
//            button?.isHidden = true
//        } else {
//            button?.isHidden = false
//        }
//    }
    
    func setCheckButton(isPreview: Bool) {
        if isPreview {
            leadingConstraintOfButton?.constant = -10
            button?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfButton?.constant = 10
            button?.isHidden = false
        }
    }
    
    func setCheckImage() {
        if isSelected  {
            button?.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
        } else {
            button?.setImage(UIImage.init(systemName: "checkmark.circle"), for: .normal)
        }
    }

    func changeShapeOfImageView() {
           messageLabel.clipsToBounds = true
           messageLabel.layer.cornerRadius = 10
       }
}
