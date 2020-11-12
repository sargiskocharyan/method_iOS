//
//  SendImageMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 10/28/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SentMediaMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewUnderImage: UIView!
    @IBOutlet weak var snedImageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfChaeckImage: NSLayoutConstraint!
    @IBOutlet weak var checkImage: UIImageView?
    var id: String?
    var viewOnCell: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        snedImageView?.contentMode = .scaleAspectFill
        leadingConstraintOfChaeckImage?.constant = -10
        checkImage?.isHidden = true
        viewUnderImage.clipsToBounds = true
        viewUnderImage.layer.cornerRadius = 10
        viewOnCell?.tag = 12

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImage?.image = nil
        viewOnCell?.removeFromSuperview()
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
    
    func setStartVideoImage(type: String) {
        if type == "video" {
            let imagView = UIImageView(image: UIImage(systemName: "play.fill"))
            viewOnCell = UIView()
            viewOnCell?.frame = snedImageView.frame
            snedImageView.addSubview(viewOnCell ?? UIView())
            viewOnCell?.addSubview(imagView)
            imagView.translatesAutoresizingMaskIntoConstraints = false
            imagView.centerYAnchor.constraint(equalTo: snedImageView.centerYAnchor, constant: 0).isActive = true
            imagView.centerXAnchor.constraint(equalTo: snedImageView.centerXAnchor, constant: 0).isActive = true
            imagView.heightAnchor.constraint(equalTo: snedImageView.heightAnchor, multiplier: 0.3).isActive = true
            imagView.widthAnchor.constraint(equalTo: snedImageView.widthAnchor, multiplier: 0.3).isActive = true
        }
    }
    
}
