//
//  SendMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class SentMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var readMessage: UILabel!
    @IBOutlet weak var checkImageView: UIImageView?
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leadingConstraintOfChaeckImage: NSLayoutConstraint?
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
        isSelected = false
        leadingConstraintOfChaeckImage?.constant = -10
        checkImageView?.isHidden = true
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        checkImageView?.image = nil
        
    }
    
   func setCheckButton(isPreview: Bool) {
       if isPreview {
           leadingConstraintOfChaeckImage?.constant = -10
           checkImageView?.isHidden = true
       } else if !isPreview {
           leadingConstraintOfChaeckImage?.constant = 10
           checkImageView?.isHidden = false
       }
   }
   
   func setCheckImage() {
       if isSelected  {
           checkImageView?.image = UIImage.init(systemName: "checkmark.circle.fill")
       } else {
           checkImageView?.image = UIImage.init(systemName: "circle")
       }
   }
   
   func changeShapeOfImageView() {
       messageLabel.clipsToBounds = true
       messageLabel.layer.cornerRadius = 10
   }
    
    func configureSendMessageTableViewCellInChannel(_ channelInfo: ChannelInfo?, _ message: Message, _ tap: UILongPressGestureRecognizer, isPreview: Bool?) {
        self.id = message._id
        if message.owner != nil {
            self.readMessage.text = "sent".localized()
        } else {
            self.readMessage.text = "waiting".localized()
        }
        self.messageLabel.backgroundColor = UIColor(red: 126/255, green: 192/255, blue: 235/255, alpha: 1)
        self.messageLabel.text = message.text
        self.messageLabel.sizeToFit()
        self.contentView.addGestureRecognizer(tap)
        self.checkImageView?.image = UIImage.init(systemName: "circle")
        if  (channelInfo?.role == 0 || channelInfo?.role == 1) {
            self.setCheckImage()
            self.setCheckButton(isPreview: isPreview!)
        } else {
            self.checkImageView?.isHidden = true
        }
    }
    
    func stringToDateD(date:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        if parsedDate == nil {
            return nil
        } else {
            return parsedDate
        }
    }
    
    func configureSendMessageTableViewCell(message: Message, statuses: [MessageStatus], _ tap: UILongPressGestureRecognizer) {
        self.messageLabel.text = message.text
        self.messageLabel.backgroundColor =  UIColor(red: 135/255, green: 192/255, blue: 237/255, alpha: 1)
        self.id = message._id
        self.messageLabel.textColor = .black
        self.messageLabel.sizeToFit()
        DispatchQueue.main.async {
            self.addGestureRecognizer(tap)
        }
        if message.createdAt != nil {
            let date = stringToDateD(date: message.createdAt!)
            let status = statuses[0].userId == SharedConfigs.shared.signedUser?.id ? statuses[1] : statuses[0]
            if date! < stringToDateD(date: status.receivedMessageDate!)! {
                if date! < stringToDateD(date: status.readMessageDate!)! || date! == stringToDateD(date: status.readMessageDate!)! {
                    self.readMessage.text = "seen".localized()
                } else {
                    self.readMessage.text = "delivered".localized()
                }
            } else if date! > stringToDateD(date: status.receivedMessageDate!)! {
                self.readMessage.text = "sent".localized()
            } else {
                if date! == stringToDateD(date: status.readMessageDate!)! || date! < stringToDateD(date: status.readMessageDate!)! {
                    self.readMessage.text = "seen".localized()
                } else {
                    self.readMessage.text = "delivered".localized()
                }
            }
        } else {
            self.readMessage.text = "waiting".localized()
        }
    }
}

extension SentMessageTableViewCell: CellProtocol {
    func select() {
        let image = UIImage.init(systemName: "checkmark.circle.fill")
        self.checkImageView?.image = image
    }
    
    func deselect() {
        let image = UIImage.init(systemName: "circle")
        self.checkImageView?.image = image
    }
}
