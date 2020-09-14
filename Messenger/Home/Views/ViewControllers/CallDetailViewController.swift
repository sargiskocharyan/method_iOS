//
//  CallDetailViewController.swift
//  Messenger
//
//  Created by Employee1 on 8/3/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class CallDetailViewController: UIViewController {

    var date: Date?
    var callDuration: String?
    var callMode: CallStatus?
    var onContactPage: Bool?
    var name: String?
    var avatarURL: String?
    var id: String?
    var isReceiverWe: Bool?
    var calls: [CallHistory] = []
    var callListViewController: CallListViewController?
    var tabBar: MainTabBarController?
    var nc: UINavigationController?
    var contactsViewModel: ContactsViewModel?
    var isThereContacts: Bool = false
    var mainRouter: MainRouter?
    let headerViewMaxHeight: CGFloat = 270
    var headerViewMinHeight: CGFloat?
    let userImageViewMaxHeight: CGFloat = 110
    let userImageViewMinHeight: CGFloat = 50
    let userImageViewMaxWidth: CGFloat = 110
    let userImageViewMinWidth: CGFloat = 50
    let usernameLabelMaxHeight: CGFloat = 29
    let usernameLabelMinHeight: CGFloat = 16
    
    @IBOutlet weak var audioCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var aboutCallView: UIView!
    @IBOutlet weak var audioCallView: UIView!
    @IBOutlet weak var usernameLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var userImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var videoCallView: UIView!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var audioCallLabel: UILabel!
    @IBOutlet weak var videoCallLabel: UILabel!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
    
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
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        contactsViewModel = tabBar?.contactsViewModel
        isThereContacts = false
        for i in 0..<contactsViewModel!.contacts.count {
            if contactsViewModel?.contacts[i]._id == id {
                isThereContacts = true
            }
        }
        tableView.tableFooterView = UIView()
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        aboutCallView.backgroundColor = UIColor(named: "imputColor")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureViews()
        setLabels()
        username.adjustsFontSizeToFitWidth = true
        username.text = name
        username.minimumScaleFactor = 0.5
        tableView.delegate = self
        tableView.dataSource = self
        tabBar = tabBarController as? MainTabBarController
        nc = tabBar?.viewControllers?[0] as? UINavigationController
        callListViewController = nc?.viewControllers[0] as? CallListViewController
        getCalls()
        ImageCache.shared.getImage(url: avatarURL ?? "", id: id!) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
    }

    func getCalls() {
        if isReceiverWe! {
            for i in 0..<(callListViewController?.viewModel?.calls.count)! {
                if callListViewController?.viewModel?.calls[i].caller == id && callListViewController?.viewModel?.calls[i].status == callMode?.rawValue && callListViewController?.viewModel?.calls[i].status == CallStatus.missed.rawValue {
                    calls.append((callListViewController?.viewModel?.calls[i])!)
                } else if callListViewController?.viewModel?.calls[i].caller == id && callMode?.rawValue != CallStatus.missed.rawValue && callListViewController?.viewModel?.calls[i].status != CallStatus.missed.rawValue {
                    calls.append((callListViewController?.viewModel?.calls[i])!)
                }
            }
        }
        else {
            calls = callListViewController!.viewModel!.calls.filter({ (call) -> Bool in
                return (call.caller == SharedConfigs.shared.signedUser?.id && call.receiver == id)
            })
        }
        print(calls)
        tableView.reloadData()
    }
    
    
    @IBAction func startVideoCall(_ sender: Any) {
        let tabBar = tabBarController as! MainTabBarController
        if !tabBar.onCall {
            tabBar.handleCallClick(id: id!, name: name!, mode: .videoCall)
            callListViewController?.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: id!)
        } else {
            tabBar.handleClickOnSamePerson()
        }
    }
    
    @IBAction func startAudioCall(_ sender: Any) {
        let tabBar = tabBarController as! MainTabBarController
        tabBar.videoVC?.isCallHandled = false
        if !tabBar.onCall {
            tabBar.handleCallClick(id: id!, name: name!, mode: .audioCall)
            callListViewController?.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: id!)
        } else {
            tabBar.handleClickOnSamePerson()
        }
    }
    
    @IBAction func sendMessageButton(_ sender: Any) {
        mainRouter?.showChatViewControllerFromCallDetail(name: name, username: name, avatarURL: avatarURL, id: id!)
    }

}


extension CallDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let headerViewMinHeight: CGFloat = 189
        let yPos = tableView.contentOffset.y
        let newHeaderViewHeight: CGFloat = headerViewHeightConstraint.constant - yPos
        let newUsernameLabelHeight: CGFloat = usernameLabelHeightConstraint.constant - yPos
        let newUserImageViewHeight: CGFloat = userImageViewHeightConstraint.constant - yPos

        if newHeaderViewHeight > headerViewMaxHeight {
            headerViewHeightConstraint.constant = headerViewMaxHeight
            userImageView.layer.cornerRadius = userImageViewMaxHeight / 2
            userImageViewHeightConstraint.constant = userImageViewMaxHeight
            userImageViewWidthConstraint.constant = userImageViewMaxWidth
            usernameLabelHeightConstraint.constant = usernameLabelMaxHeight
        } else if newHeaderViewHeight < headerViewMinHeight {
            headerViewHeightConstraint.constant = headerViewMinHeight
            userImageView.layer.cornerRadius = userImageViewMinHeight / 2
            userImageViewHeightConstraint.constant = userImageViewMinHeight
            userImageViewWidthConstraint.constant = userImageViewMinWidth
            usernameLabelHeightConstraint.constant = usernameLabelMinHeight
        } else {
            headerViewHeightConstraint.constant = newHeaderViewHeight
            userImageView.layer.cornerRadius = newUserImageViewHeight / 2
            if newUserImageViewHeight <= 110 && newUserImageViewHeight >= 50 {
                userImageViewHeightConstraint.constant = newUserImageViewHeight
                userImageViewWidthConstraint.constant = newUserImageViewHeight
            }
            if newUsernameLabelHeight <= 29 && newUsernameLabelHeight >= 16 {
                usernameLabelHeightConstraint.constant = newUsernameLabelHeight
            }
            tableView.contentOffset.y = 0 // block scroll view
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calls.count
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallDetailTableViewCell", for: indexPath) as! CallDetailTableViewCell
        let parsedDate = stringToDateD(date: calls[indexPath.row].callSuggestTime!)!
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let year = calendar.component(.year, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay == day {
            cell.dateLabel.text = "today".localized()
        } else if currentDay - 1 == day {
            cell.dateLabel.text = "yesterday".localized()
        } else {
            cell.dateLabel.text = "\(day >= 10 ? "\(day)" : "0\(day)").\(month >= 10 ? "\(month)" : "0\(month)").\(year)"
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        cell.timeLabel.text = "\(hour >= 10 ? "\(hour)" : "0\(hour)"):\(minutes >= 10 ? "\(minutes)" : "0\(minutes)")"
        cell.statusLabel.text = calls[indexPath.row].status
        let userCalendar = Calendar.current
        let requestedComponent: Set<Calendar.Component> = [.hour, .minute, .second]
        if calls[indexPath.row].callStartTime != nil {
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: stringToDateD(date: calls[indexPath.row].callStartTime!)!, to: stringToDateD(date: calls[indexPath.row].callEndTime!)!)
            let hourToSeconds = timeDifference.hour! * 3600
            let minuteToSeconds = timeDifference.minute! * 60
            let seconds = timeDifference.second!
            cell.durationLabel.text = (seconds + minuteToSeconds + hourToSeconds).secondsToHoursMinutesSeconds()
        } else {
            cell.durationLabel.text = ""
        }
        return cell
    }
    
    
}
