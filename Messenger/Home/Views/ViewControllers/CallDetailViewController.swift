//
//  CallDetailViewController.swift
//  Messenger
//
//  Created by Employee1 on 8/3/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

enum CallMode: String {
    case incoming = "Incomming call"
    case outgoing = "Outgoing call"
    case missed = "Missed call"
    case canceled = "Canceled call"
}

class CallDetailViewController: UIViewController {

    var date: Date?
    var callDuration: String?
    var callMode: CallMode?
    var onContactPage: Bool?
    var name: String?
    var avatarURL: String?
    var id: String?
    
    @IBOutlet weak var aboutCallView: UIView!
    @IBOutlet weak var audioCallView: UIView!
    @IBOutlet weak var videoCallView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var callModeLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var audioCallLabel: UILabel!
    @IBOutlet weak var videoCallLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var videoOrAudioLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    
    func configureViews() {
        userImageView.contentMode = . scaleAspectFill
        userImageView.layer.cornerRadius = 55
        userImageView.clipsToBounds = true
        
        audioCallView.contentMode = . scaleAspectFill
        audioCallView.layer.cornerRadius = 22.5
        audioCallView.clipsToBounds = true
        
        videoCallView.contentMode = . scaleAspectFill
        videoCallView.layer.cornerRadius = 22.5
        videoCallView.clipsToBounds = true
        
        messageView.contentMode = . scaleAspectFill
        messageView.layer.cornerRadius = 22.5
        messageView.clipsToBounds = true
        
        aboutCallView.layer.borderColor = UIColor.lightGray.cgColor
        aboutCallView.layer.borderWidth = 1.0
        aboutCallView.layer.masksToBounds = true
    }
    
    func setLabels() {
        messageLabel.text = "message".localized()
        videoCallLabel.text = "video".localized()
        audioCallLabel.text = "call".localized()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setLabels()
        username.text = name
        dateToString(date: date!)
        durationLabel.text = callDuration
//        timeLabel.text = d
        callModeLabel.text = callMode?.rawValue
        ImageCache.shared.getImage(url: avatarURL ?? "", id: id!) { (image) in
            self.userImageView.image = image
        }
    }
    
    

    @IBAction func startVideoCall(_ sender: Any) {
    }
    @IBOutlet weak var startAudioCall: NSLayoutConstraint!
    @IBAction func sendMessageButton(_ sender: Any) {
    }
  
    func dateToString(date: Date) {
        let parsedDate = date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let year = calendar.component(.year, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay == day {
            dateLabel.text = "today".localized()
        } else if currentDay - 1 == day {
            dateLabel.text = "yesterday".localized()
        } else {
            dateLabel.text = "\(day > 10 ? "\(day)" : "0\(day)"):\(month > 10 ? "\(month)" : "0\(month)"):\(year)"
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        timeLabel.text = "\(hour > 10 ? "\(hour)" : "0\(hour)"):\(minutes > 10 ? "\(minutes)" : "0\(minutes)")"
    }
}
