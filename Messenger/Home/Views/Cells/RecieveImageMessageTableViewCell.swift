//
//  RecieveImageMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 10/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class RecieveImageMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var leadingConstraintOfImageView: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var leadingConstraintOfCheckImage: NSLayoutConstraint!
    @IBOutlet weak var checkImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
