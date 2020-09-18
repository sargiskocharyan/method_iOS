//
//  AdminMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 9/16/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class AdminMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var appImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        appImageView.clipsToBounds = true
        appImageView.layer.cornerRadius = 30
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(adminMessage: AdminMessage)  {
        self.messageLabel.text = adminMessage.body
        self.titleLabel.text = adminMessage.title
        self.appImageView.image = UIImage(named: "AppIcon")
    }
    
}
