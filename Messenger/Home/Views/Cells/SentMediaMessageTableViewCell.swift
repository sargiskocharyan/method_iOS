//
//  SendImageMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 10/28/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SentMediaMessageTableViewCell: UITableViewCell {
    
    //    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var viewUnderImage: UIView!
    @IBOutlet weak var snedImageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfChaeckImage: NSLayoutConstraint!
    @IBOutlet weak var checkImage: UIImageView?
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        //    snedImageView.contentMode = .scaleAspectFill
        leadingConstraintOfChaeckImage?.constant = -10
        checkImage?.isHidden = true
        viewUnderImage.clipsToBounds = true
        viewUnderImage.layer.cornerRadius = 10
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImage?.image = nil
    }
    
    func setCheckButton(isPreview: Bool) {
        if isPreview {
            leadingConstraintOfChaeckImage?.constant = -10
            checkImage?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfChaeckImage?.constant = 10
            checkImage?.isHidden = false
        }
    }
    
    func setCheckImage() {
        if isSelected  {
            checkImage?.image = UIImage.init(systemName: "checkmark.circle.fill")
        } else {
            checkImage?.image = UIImage.init(systemName: "circle")
        }
    }
    
}
