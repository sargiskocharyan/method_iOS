//
//  RecieveCallTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 8/6/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class RecievedCallTableViewCell: UITableViewCell {

    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var cellMessageView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var durationAndStartCallLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
    }

    func changeShapeOfImageView() {
        userImageView.clipsToBounds = true
        userImageView.layer.cornerRadius = 15
        cellMessageView.clipsToBounds = true
        cellMessageView.layer.cornerRadius = 10
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
            return ("\(day >= 10 ? "\(day)" : "0\(day)").\(month >= 10 ? "\(month)" : "0\(month)")")
        }
        let hour = calendar.component(.hour, from: parsedDate!)
        let minutes = calendar.component(.minute, from: parsedDate!)
        return ("\(hour >= 10 ? "\(hour)" : "0\(hour)").\(minutes >= 10 ? "\(minutes)" : "0\(minutes)")")
    }
    
    func configureRecieveCallTableViewCell(_ message: Message?, image: UIImage, _ tap: UILongPressGestureRecognizer) {
        self.userImageView.image = image
        if message?.call?.status == CallStatus.accepted.rawValue {
            self.arrowImageView.tintColor = UIColor(red: 48/255, green: 121/255, blue: 255/255, alpha: 1)
            self.statusLabel.text = CallStatus.incoming.rawValue.localized()
            self.durationAndStartCallLabel.text = "\(stringToDate(date: ((message?.call?.callSuggestTime)) ?? "")), \(Int(message?.call?.duration ?? 0).secondsToHoursMinutesSeconds())"
        } else if message?.call?.status == CallStatus.missed.rawValue.lowercased() {
            self.arrowImageView.tintColor = .red
            self.statusLabel.text = "\(CallStatus.missed.rawValue)_call".localized()
            self.durationAndStartCallLabel.text = "\(stringToDate(date: (message?.call?.callSuggestTime)!))"
        } else  {
            self.arrowImageView.tintColor = .red
            self.statusLabel.text = "\(CallStatus.cancelled.rawValue)_call".localized()
            self.durationAndStartCallLabel.text = "\(stringToDate(date: (message?.call?.callSuggestTime)!))"
        }
    }
    
}
