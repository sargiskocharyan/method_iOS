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
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfMarkImageView: NSLayoutConstraint?
    
    @IBOutlet weak var markImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        isSelected = false
        leadingConstraintOfMarkImageView?.constant = -10
        markImageView?.isHidden = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        markImageView.image = nil
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
            leadingConstraintOfMarkImageView?.constant = -10
            markImageView?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfMarkImageView?.constant = 10
            markImageView?.isHidden = false
        }
    }
    
    func setCheckImage() {
        if isSelected  {
//            markImageView?.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
            markImageView.image = UIImage(systemName: "checkmark.circle.fill")
        } else {
//            markImageView?.setImage(UIImage.init(systemName: "checkmark.circle"), for: .normal)
            markImageView.image = UIImage(systemName: "checkmark.circle")
        }
    }

    func changeShapeOfImageView() {
           messageLabel.clipsToBounds = true
           messageLabel.layer.cornerRadius = 10
       }
}
