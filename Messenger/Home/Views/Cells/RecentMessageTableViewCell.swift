//
//  RecentMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class RecentMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!

    var isOnline: Bool?
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        self.removeOnlineView()
        userImageView.image = nil
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
//        contentView.translatesAutoresizingMaskIntoConstraints = false
        changeShapeOfImageView()
        
    }
    
    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 30
    }
    
    func removeOnlineView() {
        self.viewWithTag(50)?.removeFromSuperview()
    }
    
    func setOnlineView() {
        let onlineView = UIView()
        self.addSubview(onlineView)
        userImageView.backgroundColor = .clear
        onlineView.backgroundColor = UIColor(red: 125/255, green: 204/255, blue: 1/255, alpha: 1)
        onlineView.contentMode = . scaleAspectFill
        onlineView.layer.masksToBounds = true
        onlineView.layer.borderWidth = 2
        onlineView.layer.borderColor = UIColor(named: "imputColor")?.cgColor
        onlineView.layer.cornerRadius = 9
        onlineView.clipsToBounds = true
        onlineView.tag = 50
        onlineView.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: 0).isActive = true
        onlineView.rightAnchor.constraint(equalTo: userImageView.rightAnchor, constant: 0).isActive = true
        onlineView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        onlineView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        onlineView.isUserInteractionEnabled = true
        onlineView.anchor(top: nil, paddingTop: 20, bottom: userImageView.bottomAnchor, paddingBottom: 0, left: nil, paddingLeft: 0, right: userImageView.rightAnchor, paddingRight: 0, width: 18, height: 18)
    }
    
    func configure(chat: Chat) {
        print(nameLabel.hasAmbiguousLayout)
        if isOnline != nil && isOnline == true {
            setOnlineView()
        } else {
            removeOnlineView()
        }
        userImageView.image = UIImage(named: "noPhoto")
        ImageCache.shared.getImage(url: chat.recipientAvatarURL ?? "", id: chat.id) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
        if chat.name != nil && chat.lastname != nil {
            nameLabel.text = "\(chat.name!) \(chat.lastname!)"
        } else if chat.username != nil {
            nameLabel.text = chat.username
        } else {
            nameLabel.text = "no username"
        }
        if chat.message != nil {
            timeLabel.text = stringToDate(date: chat.message!.createdAt ?? "" )
        }
        
        if chat.id == chat.message?.senderId {
            lastMessageLabel.text = chat.message?.text ?? "Call"
//            if chat.unreadMessageExists {
//                lastMessageLabel.textColor = .black
//                self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
//            } 
        } else {
            lastMessageLabel.text = "you".localized() + (chat.message?.text ?? "Call")
        }
    }
    
    
    func stringToDate(date:String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate!)
        let month = calendar.component(.month, from: parsedDate!)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
            return "\(day >= 10 ? "\(day)" : "0\(day)").\(month >= 10 ? "\(month)" : "0\(month)")"
        }
        let hour = calendar.component(.hour, from: parsedDate!)
        let minutes = calendar.component(.minute, from: parsedDate!)
        return "\(hour >= 10 ? "\(hour)" : "0\(hour)"):\(minutes >= 10 ? "\(minutes)" : "0\(minutes)")"
        
    }
}
