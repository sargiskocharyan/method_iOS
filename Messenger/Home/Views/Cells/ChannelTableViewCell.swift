//
//  ChannelTableViewCell.swift
//  Messenger
//
//  Created by Employee3 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
