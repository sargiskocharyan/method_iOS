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
    func callSelected(id: String, duration: String, time: Date?, callMode: CallMode, name: String, avatarURL: String)
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
    var call: FetchedCall?
    var contact: User?
 
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        delegate?.callSelected(id: calleId!, duration: callDurationLabel.text!, time: call?.time, callMode: call!.isHandleCall ? CallMode.incoming : CallMode.outgoing, name: contact?.name ?? contact?.username ?? "Dynamic's user", avatarURL: contact?.avatarURL ?? "")
    }
    override func awakeFromNib() {
           super.awakeFromNib()
           userImageView.contentMode = .scaleAspectFill
           userImageView.layer.cornerRadius = 23
           userImageView.clipsToBounds = true
       }

    func dateToString(date: Date) -> String {
        let parsedDate = date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
            return ("\(day).0\(month)")
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        return ("\(hour):\(minutes)")
    }
    
 func secondsToHoursMinutesSeconds(seconds : Int) -> String {
    if seconds / 3600 == 0 && ((seconds % 3600) / 60) == 0 {
        return "\((seconds % 3600) % 60) sec."
    } else if seconds / 3600 == 0 {
        return "\((seconds % 3600) / 60) min. \((seconds % 3600) % 60) sec."
    }
    return "\(seconds / 3600) hr. \((seconds % 3600) / 60) min. \((seconds % 3600) % 60) sec."
    }
    
    func configureCell(contact: User, call: FetchedCall) {
        self.call = call
        self.contact = contact
        if contact.name != nil {
        self.nameLabel.text = contact.name
        } else if contact.username != nil {
            self.nameLabel.text = contact.username
        } else {
            self.nameLabel.text = "Dynamic's user".localized()
        }
        callDurationLabel.text = secondsToHoursMinutesSeconds(seconds: call.callDuration ?? 0)
        ImageCache.shared.getImage(url: contact.avatarURL ?? "", id: contact._id!) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
         self.timeLabel.text = dateToString(date: call.time)
        if call.isHandleCall != true {
            self.callIcon.image = UIImage.init(systemName: "arrow.up.right.video.fill")
        } else {
            self.callIcon.image = UIImage.init(systemName: "arrow.down.left.video.fill")
        }
    }
}
