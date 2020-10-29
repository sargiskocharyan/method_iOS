//
//  SendImageMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 10/28/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SendImageMessageTableViewCell: UITableViewCell {

//    @IBOutlet weak var imageViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var snedImageView: UIImageView!
//    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    internal var aspectConstraint : NSLayoutConstraint? {
        didSet {
            if oldValue != nil {
                snedImageView.removeConstraint(oldValue!)
            }
            if aspectConstraint != nil {
                aspectConstraint?.priority = UILayoutPriority(rawValue: 999)  //add this
                snedImageView.addConstraint(aspectConstraint!)
            }
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        aspectConstraint = nil
        snedImageView.image = nil
    }

    func setPostedImage(image : UIImage) {
        let aspect = image.size.width / image.size.height
        aspectConstraint = NSLayoutConstraint(item: snedImageView!, attribute: NSLayoutConstraint.Attribute.width, relatedBy: NSLayoutConstraint.Relation.equal, toItem: snedImageView, attribute: NSLayoutConstraint.Attribute.height, multiplier: aspect, constant: 0.0)
        snedImageView.image = image
    }
}
