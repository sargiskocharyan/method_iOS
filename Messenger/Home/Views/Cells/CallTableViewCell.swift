//
//  CallTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 7/13/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import CoreData

protocol CallTableViewDelegate: class {
    func callSelected(id: String, duration: String, callStartTime: Date?, callStatus: String, type: String,  name: String, avatarURL: String)
}


class CallTableViewCell: UITableViewCell {

    @IBOutlet weak var callIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var callDurationLabel: UILabel!
    weak var delegate: CallTableViewDelegate?
    var calleId: String?
    var call: CallHistory?
    var contact: User?
 
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        delegate?.callSelected(id: calleId!, duration: callDurationLabel.text!, callStartTime: stringToDate(date: call?.callStartTime ?? call!.callSuggestTime!), callStatus: call!.status!, type: call!.type!, name: contact?.name ?? contact?.username ?? "Dynamic's user", avatarURL: contact?.avatarURL ?? "")
        //delegate?.callSelected(id: calleId!, duration: callDurationLabel.text!, time: stringToDate(date: call?.createdAt) , callMode: call!.isHandleCall ? CallMode.incoming : CallMode.outgoing, name: contact?.name ?? contact?.username ?? "Dynamic's user", avatarURL: contact?.avatarURL ?? "")
    }
    override func awakeFromNib() {
           super.awakeFromNib()
           userImageView.contentMode = .scaleAspectFill
           userImageView.layer.cornerRadius = 23
           userImageView.clipsToBounds = true
       }

    func stringToDate(date:String) -> Date? {
           let formatter = DateFormatter()
           formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
           let parsedDate = formatter.date(from: date)
           if parsedDate == nil {
               return nil
           } else {
              return parsedDate
           }
       }
    
    func dateToString(date: Date) -> String {
        let parsedDate = date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
             return "\(day >= 10 ? "\(day)" : "0\(day)").\(month >= 10 ? "\(month)" : "0\(month)")"
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        return "\(hour >= 10 ? "\(hour)" : "0\(hour)"):\(minutes >= 10 ? "\(minutes)" : "0\(minutes)")"
    }
    
 func secondsToHoursMinutesSeconds(seconds : Int) -> String {
    if seconds / 3600 == 0 && ((seconds % 3600) / 60) == 0 {
        return "\((seconds % 3600) % 60) sec."
    } else if seconds / 3600 == 0 {
        return "\((seconds % 3600) / 60) min. \((seconds % 3600) % 60) sec."
    }
    return "\(seconds / 3600) hr. \((seconds % 3600) / 60) min. \((seconds % 3600) % 60) sec."
    }
    
    func configureCell(contact: User, call: CallHistory) {
        self.call = call
        self.contact = contact
        if contact.name != nil {
        self.nameLabel.text = contact.name
        } else if contact.username != nil {
            self.nameLabel.text = contact.username
        } else {
            self.nameLabel.text = "Dynamic's user".localized()
        }
        let userCalendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [ .month, .day, .hour, .minute, .second]
        if call.callStartTime != nil && call.callEndTime != nil {
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: stringToDate(date: call.callEndTime!)!, to: stringToDate(date: call.callStartTime!)! )
            let hourSeconds = timeDifference.hour ?? 0 * 3600
            let minuteSeconds = timeDifference.minute ?? 0 * 60
            let seconds = hourSeconds + minuteSeconds + (timeDifference.second ?? 0)
        callDurationLabel.text = secondsToHoursMinutesSeconds(seconds: seconds)
            self.timeLabel.text = dateToString(date: stringToDate(date: call.callStartTime!)!)
        } else {
            self.timeLabel.text = dateToString(date: stringToDate(date: call.callSuggestTime!)!)
            callDurationLabel.text = ""
        }
        ImageCache.shared.getImage(url: contact.avatarURL ?? "", id: contact._id!) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
         
        if call.caller == SharedConfigs.shared.signedUser?.id {
            self.callIcon.image = UIImage.init(systemName: "arrow.up.right.video.fill")
        } else {
            self.callIcon.image = UIImage.init(systemName: "arrow.down.left.video.fill")
        }
    }
}
