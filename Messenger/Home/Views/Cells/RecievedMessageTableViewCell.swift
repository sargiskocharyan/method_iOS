//
//  RecieveMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class RecievedMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfImageView: NSLayoutConstraint?
    @IBOutlet weak var leadingConstraintOfCheckImage: NSLayoutConstraint?
    @IBOutlet weak var checkImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        userImageView.image = UIImage(named: "noPhoto")
        leadingConstraintOfCheckImage?.constant -= 15
        leadingConstraintOfImageView?.constant -= 15
        checkImage?.isHidden = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImage?.image = nil
    }
    
    func setCheckImage() {
        if isSelected  {
            checkImage.image = UIImage.init(systemName: "checkmark.circle.fill")
        } else {
            checkImage.image = UIImage.init(systemName: "circle")
        }
    }
    
    func setCheckButton(isPreview: Bool) {
        if isPreview {
            leadingConstraintOfCheckImage?.constant = -10
            leadingConstraintOfImageView?.constant = -5
            checkImage?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfCheckImage?.constant = 10
            leadingConstraintOfImageView?.constant = 15
            checkImage?.isHidden = false
        }
    }
    
    func editPage(isPreview: Bool?) {
        if isPreview == true {
            leadingConstraintOfCheckImage?.constant -= 20
            leadingConstraintOfImageView?.constant -= 20
            checkImage.isHidden = true
        } else if isPreview == false {
            leadingConstraintOfCheckImage?.constant += 20
            leadingConstraintOfImageView?.constant += 20
            checkImage.isHidden = false
        }
    }
    
    func configureRecieveMessageTableViewCellInChannel(_ message: Message, _ channelInfo: ChannelInfo?, _ isPreview: Bool?) {
        self.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.messageLabel.text = message.text
        for i in 0..<(channelInfo?.channel?.subscribers?.count)! {
            if channelInfo?.channel?.subscribers?[i].user == message.senderId {
                self.nameLabel.text = channelInfo?.channel?.subscribers?[i].name
                ImageCache.shared.getImage(url: channelInfo?.channel?.subscribers?[i].avatarURL ?? "", id: channelInfo?.channel?.subscribers?[i].user ?? "", isChannel: false) { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                }
                break
            }
        }
        self.messageLabel.sizeToFit()
        if (channelInfo?.role == 0 || channelInfo?.role == 1) {
            self.setCheckImage()
            self.setCheckButton(isPreview: isPreview!)
        } else {
            self.checkImage.isHidden = true
        }
    }
    
    func configureRecieveMessageTableViewCell(_ tap: UILongPressGestureRecognizer, _ message: Message, image: UIImage) {
        DispatchQueue.main.async {
            self.addGestureRecognizer(tap)
        }
        self.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        self.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        self.userImageView.image = image
        self.messageLabel.text = message.text
        self.messageLabel.sizeToFit()
    }
    
    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 15
        messageLabel.clipsToBounds = true
        messageLabel.layer.cornerRadius = 10
    }
}

extension RecievedMessageTableViewCell: CellProtocol {
    func select() {
        let image = UIImage.init(systemName: "checkmark.circle.fill")
        self.checkImage?.image = image
    }
    
    func deselect() {
        let image = UIImage.init(systemName: "circle")
        self.checkImage?.image = image
    }
}
