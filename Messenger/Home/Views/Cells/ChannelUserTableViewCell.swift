//
//  ChannelUserTableViewCell.swift
//  Messenger
//
//  Created by Employee3 on 10/27/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contactImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func changeShapeOfImageView() {
        contactImageView.clipsToBounds = true
        contactImageView.layer.cornerRadius = 25
    }
    
    func configure(contact: User) {
        contactImageView.image = UIImage(named: "noPhoto")
        ImageCache.shared.getImage(url: contact.avatarURL ?? "", id: contact._id!, isChannel: false) { (image) in
            DispatchQueue.main.async {
                self.contactImageView.image = image
            }
        }
        if let name = contact.name, let lastname = contact.lastname {
            usernameLabel.text = "\(name ) \(lastname)"
        } else if contact.username != nil {
            usernameLabel.text = contact.username
        } else {
            usernameLabel.text = "Method's user"
        }
    }
}

