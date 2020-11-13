//
//  SendCallTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 8/6/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SentCallTableViewCell: UITableViewCell {

    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var durationAndStartTimeLabel: UILabel!
    @IBOutlet weak var callMessageView: UIView!
    @IBOutlet weak var ststusLabel: UILabel!
    
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfCallMessageView()
    }

    func changeShapeOfCallMessageView() {
        callMessageView.clipsToBounds = true
        callMessageView.layer.cornerRadius = 8
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
    
    func configureSendCallTableViewCell(_ message: Message?, _ tap: UILongPressGestureRecognizer) {
        self.callMessageView.addGestureRecognizer(tap)
        self.id = message?._id
        if message?.call?.status == CallStatus.accepted.rawValue {
            self.ststusLabel.text = CallStatus.outgoing.rawValue.localized()
            self.durationAndStartTimeLabel.text =  "\(stringToDate(date: (message?.call?.callSuggestTime ?? ""))), \(Int(message?.call?.duration ?? 0).secondsToHoursMinutesSeconds())"
        } else if message?.call?.status == CallStatus.missed.rawValue.lowercased() {
            self.ststusLabel.text = "\(CallStatus.outgoing.rawValue)".localized()
            self.durationAndStartTimeLabel.text = "\(stringToDate(date: (message?.call?.callSuggestTime ?? "")))"
        } else {
            self.ststusLabel.text = "\(CallStatus.outgoing.rawValue)".localized()
            self.durationAndStartTimeLabel.text = "\(stringToDate(date: (message?.call?.callSuggestTime ?? "")))"
        }
    }
}
