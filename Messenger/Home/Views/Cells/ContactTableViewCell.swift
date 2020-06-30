//
//  ContactTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
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
        ImageCache.shared.getImage(url: contact.avatar ?? "") { (image) in
            DispatchQueue.main.async {
                self.contactImageView.image = image
            }
        }
        if contact.name == nil {
            nameLabel.textColor = .darkGray
            nameLabel.text = "name".localized()
        } else {
            nameLabel.text = contact.name
        }
        usernameLabel.text = contact.username
        if contact.lastname == nil {
            lastnameLabel.textColor = .darkGray
            lastnameLabel.text = "lastname".localized()
        } else {
            lastnameLabel.text = contact.lastname
        }
    }
}
