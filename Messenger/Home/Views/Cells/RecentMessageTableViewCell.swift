//
//  RecentMessageTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import Combine

class RecentMessageTableViewCell: UITableViewCell {
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
    }
    
    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 30
    }

    func configure(chat: Chat) {
        print(chat)
        userImageView.image = UIImage(named: "noPhoto")
        ImageCache.shared.getImage(url: chat.recipientAvatarURL ?? "") { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
        if chat.name != nil && chat.lastname != nil {
            nameLabel.text = "\(chat.name!) \(chat.lastname!)"
        } else {
            nameLabel.text = chat.username
        }
        if chat.message != nil {
            timeLabel.text = stringToDate(date: chat.message!.createdAt ?? "" )
        }
        lastMessageLabel.text = chat.message?.text
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
            return ("\(day).0\(month)")
        }
        let hour = calendar.component(.hour, from: parsedDate!)
        let minutes = calendar.component(.minute, from: parsedDate!)
        return ("\(hour):\(minutes)")
        
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        userImageView.image = nil
    }
}
