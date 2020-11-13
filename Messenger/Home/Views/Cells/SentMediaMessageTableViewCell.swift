//
//  SendImageMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 10/28/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SentMediaMessageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var viewUnderImage: UIView!
    @IBOutlet weak var snedImageView: UIImageView!
    @IBOutlet weak var imageWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfChaeckImage: NSLayoutConstraint!
    @IBOutlet weak var checkImage: UIImageView?
    var id: String?
    var viewOnCell: UIView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        snedImageView?.contentMode = .scaleAspectFill
        leadingConstraintOfChaeckImage?.constant = -10
        checkImage?.isHidden = true
        viewUnderImage.clipsToBounds = true
        viewUnderImage.layer.cornerRadius = 10
        viewOnCell?.tag = 12

    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImage?.image = nil
        viewOnCell?.removeFromSuperview()
        snedImageView.image = nil
    }
    
    func setCheckButton(isPreview: Bool) {
        if isPreview {
            leadingConstraintOfChaeckImage?.constant = -10
            checkImage?.isHidden = true
        } else if !isPreview {
            leadingConstraintOfChaeckImage?.constant = 10
            checkImage?.isHidden = false
        }
    }
    
    
    
    func setCheckImage() {
        if isSelected  {
            checkImage?.image = UIImage.init(systemName: "checkmark.circle.fill")
        } else {
            checkImage?.image = UIImage.init(systemName: "circle")
        }
    }
    
    func setStartVideoImage() {
        let imagView = UIImageView(image: UIImage(systemName: "play.fill"))
        viewOnCell = UIView()
        viewOnCell?.frame = snedImageView.frame
        snedImageView.addSubview(viewOnCell ?? UIView())
        viewOnCell?.addSubview(imagView)
        imagView.translatesAutoresizingMaskIntoConstraints = false
        imagView.centerYAnchor.constraint(equalTo: snedImageView.centerYAnchor, constant: 0).isActive = true
        imagView.centerXAnchor.constraint(equalTo: snedImageView.centerXAnchor, constant: 0).isActive = true
        imagView.heightAnchor.constraint(equalTo: snedImageView.heightAnchor, multiplier: 0.3).isActive = true
        imagView.widthAnchor.constraint(equalTo: snedImageView.widthAnchor, multiplier: 0.3).isActive = true
    }
    
    func configureSendVideoMessageTableViewCellInChannel(_ message: Message, _ channelInfo: ChannelInfo?, _ tap: UILongPressGestureRecognizer, isPreview: Bool?, tapOnVideo: UITapGestureRecognizer) {
        self.id = message._id
        self.snedImageView.isUserInteractionEnabled = true
        self.snedImageView.addGestureRecognizer(tapOnVideo)
        self.setStartVideoImage()
        ImageCache.shared.getThumbnail(videoUrl: message.video ?? "", messageId: message._id ?? "") { (image) in
            DispatchQueue.main.async {
                self.messageLabel.text = message.text
                self.addGestureRecognizer(tap)
                self.snedImageView.image = image
            }
        }
        self.messageLabel.sizeToFit()
        if  (channelInfo?.role == 0 || channelInfo?.role == 1) {
            self.setCheckImage()
            self.setCheckButton(isPreview: isPreview!)
        } else {
            self.checkImage?.isHidden = true
        }
    }
    
    func configureSendImageMessageTableViewCell(_ message: Message, _ tap: UILongPressGestureRecognizer, _ tapOnImage: UITapGestureRecognizer, tmpImage: UIImage?) {
        self.id = message._id
        self.snedImageView.isUserInteractionEnabled = true
        self.snedImageView.addGestureRecognizer(tapOnImage)
        self.addGestureRecognizer(tap)
        if let imageUrl = message.image?.imageURL {
            ImageCache.shared.getImage(url: imageUrl, id: message._id ?? "", isChannel: false) { (image) in
                DispatchQueue.main.async {
                    self.messageLabel.text = message.text
                    self.snedImageView.image = image
                }
            }
        } else {
            self.messageLabel.text = message.text
            self.snedImageView.image = tmpImage
        }
        
    }
    
    func configureSendImageMessageTableViewCellInChannel(_ message: Message, _ tap: UILongPressGestureRecognizer, isPreview: Bool?, channelInfo: ChannelInfo?, tapOnImage: UITapGestureRecognizer) {
        self.contentView.addGestureRecognizer(tap)
        self.snedImageView.isUserInteractionEnabled = true
        self.snedImageView.addGestureRecognizer(tapOnImage)
        ImageCache.shared.getImage(url: message.image?.imageURL ?? "", id: message._id ?? "", isChannel: false) { (image) in
            DispatchQueue.main.async {
                self.messageLabel.text = message.text
                self.addGestureRecognizer(tap)
                self.snedImageView.image = image
            }
        }
        self.checkImage?.image = UIImage.init(systemName: "circle")
        if  (channelInfo?.role == 0 || channelInfo?.role == 1) {
            self.setCheckImage()
            self.setCheckButton(isPreview: isPreview!)
        } else {
            self.checkImage?.isHidden = true
        }
        self.messageLabel.text = message.text
    }
    
    func configureSendVideoMessageTableViewCell(_ message: Message, _ tap: UILongPressGestureRecognizer, _ tapOnVideo: UITapGestureRecognizer, thumbnail: UIImage) {
        self.id = message._id
        self.snedImageView.image = nil
        self.snedImageView.isUserInteractionEnabled = true
        self.snedImageView.addGestureRecognizer(tapOnVideo)
        self.setStartVideoImage()
        self.addGestureRecognizer(tap)
        if let videoUrl = message.video {
        ImageCache.shared.getThumbnail(videoUrl: videoUrl, messageId: message._id ?? "") { (image) in
            DispatchQueue.main.async {
                self.messageLabel.text = message.text
                self.snedImageView.image = image
            }
        }
        } else {
            self.messageLabel.text = message.text
            self.snedImageView.image = thumbnail
        }
    }
    
}

extension SentMediaMessageTableViewCell: CellProtocol {
    func select() {
        let image = UIImage.init(systemName: "checkmark.circle.fill")
        self.checkImage?.image = image
    }
    
    func deselect() {
        let image = UIImage.init(systemName: "circle")
        self.checkImage?.image = image
    }
}
