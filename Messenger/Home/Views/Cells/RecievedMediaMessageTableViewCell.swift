//
//  RecieveImageMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 10/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class RecievedMediaMessageTableViewCell: UITableViewCell {

    @IBOutlet weak var messageContentStackView: UIStackView!
    @IBOutlet weak var messageLabel: UILabel!
//    @IBOutlet weak var viewUnderImage: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var sendImageView: UIImageView!
//    @IBOutlet weak var leadingConstraintOfImageView: NSLayoutConstraint!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var leadingConstraintOfCheckImage: NSLayoutConstraint!
//    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var checkImage: UIImageView!
    var viewOnCell: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        sendImageView?.contentMode = .scaleAspectFill
        userImageView.image = UIImage(named: "noPhoto")
        leadingConstraintOfCheckImage?.constant -= 30
//        leadingConstraintOfImageView?.constant -= 15
        checkImage?.isHidden = true
//        messageContentStackView.clipsToBounds = true
//        messageContentStackView.layer.cornerRadius = 10
        viewOnCell?.tag = 12
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImage?.image = nil
        viewOnCell?.removeFromSuperview()
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
//            leadingConstraintOfCheckImage?.constant = -10
//            leadingConstraintOfImageView?.constant = -5
            checkImage?.isHidden = true
        } else if !isPreview {
//            leadingConstraintOfCheckImage?.constant = 10
//            leadingConstraintOfImageView?.constant = 15
            checkImage?.isHidden = false
        }
    }
    
    func editPage(isPreview: Bool?) {
        if isPreview == true {
//            leadingConstraintOfCheckImage?.constant -= 20
//            leadingConstraintOfImageView?.constant -= 20
            checkImage.isHidden = true
        } else if isPreview == false {
//            leadingConstraintOfCheckImage?.constant += 20
//            leadingConstraintOfImageView?.constant += 20
            checkImage.isHidden = false
        }
    }

    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 15
    }
    
    func setStartVideoImage() {
        let imagView = UIImageView(image: UIImage(systemName: "play.fill"))
        viewOnCell = UIView()
        viewOnCell?.frame = sendImageView.frame
        sendImageView.addSubview(viewOnCell!)
        viewOnCell?.addSubview(imagView)
//        imageView?.translatesAutoresizingMaskIntoConstraints = false
//        imagView.centerYAnchor.constraint(equalTo: viewOnCell!.centerYAnchor, constant: 0).isActive = true
//        imagView.centerXAnchor.constraint(equalTo: viewOnCell!.centerXAnchor, constant: 0).isActive = true
//        imagView.heightAnchor.constraint(equalToConstant: 50).isActive = true
//        imagView.widthAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func configureRecieveVideoMessageTableViewCell(_ message: Message, _ tap: UILongPressGestureRecognizer, _ tapOnVideo: UITapGestureRecognizer) {
        self.sendImageView.isUserInteractionEnabled = true
        self.sendImageView.image = nil
        self.sendImageView.addGestureRecognizer(tapOnVideo)
        self.setStartVideoImage()
        ImageCache.shared.getThumbnail(videoUrl: message.video ?? "", messageId: message._id ?? "") { (image) in
            DispatchQueue.main.async {
                self.messageLabel.text = message.text
                self.addGestureRecognizer(tap)
                self.sendImageView.image = image
            }
        }
    }

    
    func configureRecieveVideoMessageTableViewCellInChannel(_ channelInfo: ChannelInfo, _ tap: UILongPressGestureRecognizer, message: Message, isPreview: Bool?, tapOnVideo: UITapGestureRecognizer, thumbnail: UIImage) {
        self.sendImageView.isUserInteractionEnabled = true
        self.sendImageView.addGestureRecognizer(tapOnVideo)
        setStartVideoImage()
        for i in 0..<(channelInfo.channel?.subscribers?.count)! {
            if channelInfo.channel?.subscribers?[i].user == message.senderId {
                self.nameLabel.text = channelInfo.channel?.subscribers?[i].name 
                ImageCache.shared.getImage(url: channelInfo.channel?.subscribers?[i].avatarURL ?? "", id: channelInfo.channel?.subscribers?[i].user ?? "", isChannel: false) { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                        self.messageLabel.text = message.text
                    }
                }
                break
            }
        }
        self.messageLabel.sizeToFit()
        if (channelInfo.role == 0 || channelInfo.role == 1) {
            self.setCheckImage()
            self.setCheckButton(isPreview: isPreview!)
        } else {
            self.checkImage.isHidden = true
        }
        if let videoUrl = message.video {
            ImageCache.shared.getThumbnail(videoUrl: videoUrl, messageId: message._id ?? "") { (image) in
                DispatchQueue.main.async {
                    self.messageLabel.text = message.text
                    self.sendImageView.image = image
                    
                }
            }
        } else {
            self.messageLabel.text = message.text
            self.sendImageView.image = thumbnail
        }
    }
    
    func configureRecieveImageMessageTableViewCellInChannel(_ channelInfo: ChannelInfo, isPreview: Bool?, message: Message, tapOnImage: UITapGestureRecognizer) {
        self.sendImageView.isUserInteractionEnabled = true
        self.sendImageView.addGestureRecognizer(tapOnImage)
        for i in 0..<(channelInfo.channel?.subscribers?.count)! {
            if channelInfo.channel?.subscribers?[i].user == message.senderId {
                self.nameLabel.text = channelInfo.channel?.subscribers?[i].name
                ImageCache.shared.getImage(url: channelInfo.channel?.subscribers?[i].avatarURL ?? "", id: channelInfo.channel?.subscribers?[i].user ?? "", isChannel: false) { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                    }
                }
                break
            }
        }
        if (channelInfo.role == 0 || channelInfo.role == 1) {
            self.setCheckImage()
            self.setCheckButton(isPreview: isPreview!)
        } else {
            self.checkImage.isHidden = true
        }
        ImageCache.shared.getImage(url: message.image?.imageURL ?? "", id: message._id ?? "", isChannel: false) { (image) in
            DispatchQueue.main.async {
                self.messageLabel.text = message.text
                self.sendImageView.image = image
            }
        }
        self.messageLabel.text = message.text
    }
    
    func configureRecieveImageMessageTableViewCell(_ message: Message, _ tap: UILongPressGestureRecognizer, _ tapOnImage: UITapGestureRecognizer, image: UIImage) {
        self.sendImageView.isUserInteractionEnabled = true
        self.sendImageView.addGestureRecognizer(tapOnImage)
        ImageCache.shared.getImage(url: message.image?.imageURL ?? "", id: message._id ?? "", isChannel: false) { (image) in
            DispatchQueue.main.async {
                self.messageLabel.text = message.text
                self.addGestureRecognizer(tap)
                self.sendImageView.image = image
            }
        }
        nameLabel.text = ""
        self.userImageView.image = image
    }
}

extension RecievedMediaMessageTableViewCell: CellProtocol {
    func select() {
        let image = UIImage.init(systemName: "checkmark.circle.fill")
        self.checkImage?.image = image
    }
    
    func deselect() {
        let image = UIImage.init(systemName: "circle")
        self.checkImage?.image = image
    }
}
