//
//  ContactRequestTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 9/16/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ContactRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 35
        userImageView.clipsToBounds = true
        confirmButton.layer.cornerRadius = 5
        rejectButton.layer.cornerRadius = 5
        confirmButton.clipsToBounds = true
        rejectButton.clipsToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(user: User) {
        if user.name != nil && user.lastname != nil {
            nameLabel.text = user.name! + " " + user.lastname!
        } else {
            nameLabel.text = user.username
        }
        ImageCache.shared.getImage(url: user.avatarURL ?? "", id: user._id!) { (image) in
            self.userImageView.image = image
        }
    }
    
}
