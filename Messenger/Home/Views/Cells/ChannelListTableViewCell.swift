//
//  ChannelTableViewCell.swift
//  Messenger
//
//  Created by Employee3 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelListTableViewCell: UITableViewCell {

    @IBOutlet weak var channelNameLabel: UILabel!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        channelLogoImageView.contentMode = .scaleAspectFill
        channelLogoImageView.layer.cornerRadius = 23
        channelLogoImageView.clipsToBounds = true
    }
    
    func configureCell(avatar: String?, name: String, id: String) {
        channelNameLabel.text = name
        ImageCache.shared.getImage(url: avatar ?? "", id: id, isChannel: true) { (image) in
            DispatchQueue.main.async {
                self.channelLogoImageView.image = image
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
