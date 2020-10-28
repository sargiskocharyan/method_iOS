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
        channelLogoImageView.layer.cornerRadius = channelLogoImageView.frame.height / 2 - 2
        channelLogoImageView.clipsToBounds = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.channelLogoImageView.image = nil
    }
    
    func configureCell(avatar: String?, name: String, id: String) {
        channelNameLabel.text = name
        channelLogoImageView.contentMode = .scaleAspectFit
        ImageCache.shared.getImage(url: avatar ?? "", id: id, isChannel: true) { (image) in
            DispatchQueue.main.async {
                self.channelLogoImageView.image = image
            }
        }
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
