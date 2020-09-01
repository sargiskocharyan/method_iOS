//
//  ChatViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import SocketIO

enum CallStatus: String {
    case accepted  = "accepted"
    case missed    = "missed"
    case cancelled = "cancelled"
    case incoming  = "incoming_call"
    case outgoing  = "outgoing_call"
    case ongoing   = "ongoing"
}

class ChatViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var typingLabel: UILabel!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var viewModel: ChatMessagesViewModel?
    var id: String?
    var allMessages: Messages?
    var bottomConstraint: NSLayoutConstraint?
    let center = UNUserNotificationCenter.current()
    var name: String?
    var username: String?
    var avatar: String?
    static let sendMessageCellIdentifier = "sendMessageCell"
    static let receiveMessageCellIdentifier = "receiveMessageCell"
    var image = UIImage(named: "noPhoto")
    var tabbar: MainTabBarController?
    var mainRouter: MainRouter?
    var statuses: [MessageStatus]?
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "imputColor")
        return view
    }()
    
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = ""
        return textField
    }()
    
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        
        button.setImage(UIImage(named: "send"), for: .normal)
        return button
    }()
    var timer: Timer?
    
    
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getChatMessages()
        tabbar = tabBarController as? MainTabBarController
        addConstraints()
        setupInputComponents()
        setObservers()
        inputTextField.placeholder = "enter_message".localized()
        sendButton.setTitle("send".localized(), for: .normal)
        self.navigationItem.rightBarButtonItem = .init(UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .done, target: self, action: #selector(infoButtonAction)))
        setTitle()
        getImage()
        setObservers()
        activity.tag = 5
            if (SocketTaskManager.shared.socket?.handlers.count)! < 11 {
                self.handleReadMessage()
                self.handleMessageTyping()
                self.handleReceiveMessage()
        }
        inputTextField.addTarget(self, action: #selector(inputTextFieldDidCghe), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.endEditing(true)
        if !(tabBarController?.tabBar.isHidden)! {
            tabBarController?.tabBar.isHidden = true
        }
        if (navigationController?.navigationBar.isHidden)! {
            navigationController?.navigationBar.isHidden = false
        }
        checkAndSendReadEvent()
    }
    
    //MARK: Helper methods
    @objc func infoButtonAction() {
        mainRouter?.showContactProfileViewControllerFromChat(id: id!, fromChat: true)
    }
    
    @objc func inputTextFieldDidCghe() {
        SocketTaskManager.shared.messageTyping(chatId: id!)
    }
    
    @objc func sendMessage() {
        if inputTextField.text != "" {
            let text = inputTextField.text
            inputTextField.text = ""
            SocketTaskManager.shared.send(message: text!, id: id!)
            self.allMessages?.array?.append(Message(call: nil, type: "text", _id: nil, reciever: id, text: text, createdAt: nil, updatedAt: nil, owner: nil, senderId: SharedConfigs.shared.signedUser?.id))
            
            self.tableView.insertRows(at: [IndexPath(row: allMessages!.array!.count - 1, section: 0)], with: .automatic)
        }
    }
    
    func setTitle() {
        if name != nil {
            self.title = name
        } else if username != nil {
            self.title = username
        } else {
            self.title = "dynamics_user".localized()
        }
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func handleMessageReadFromTabbar(createdAt: String, userId: String) {
        if userId == self.id {
            let createdAtDate = self.stringToDateD(date: createdAt)!
            for i in 0..<self.allMessages!.array!.count {
                if let date = self.stringToDateD(date: self.allMessages?.array?[i].createdAt ?? "") {
                if date <= createdAtDate {
                    if allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                        self.allMessages?.statuses![1].readMessageDate = createdAt
                    } else {
                        self.allMessages?.statuses![0].readMessageDate = createdAt
                    }
                    if allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                    (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.readMessage.text = "seen"
                    }
                }
                }
            }
        }
    }
    
    func handleMessageReceiveFromTabbar(createdAt: String, userId: String) {
        if userId == self.id {
            let createdAtDate = self.stringToDateD(date: createdAt)!
            for i in 0..<self.allMessages!.array!.count {
                
                if let date = self.stringToDateD(date: self.allMessages?.array?[i].createdAt ?? "") {
                if date <= createdAtDate {
                    if allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                        self.allMessages?.statuses![1].receivedMessageDate = createdAt
                    } else {
                        self.allMessages?.statuses![0].receivedMessageDate = createdAt
                    }
                    if allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                        (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.readMessage.text = "received"
                    }
                }
                } else {
                    
                }
        }
    }
}

    func handleMessageTypingFromTabbar(userId: String) {
         if userId == self.id {
                       self.typingLabel.text = "typing"
                       self.timer?.invalidate()
                       self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                           self.typingLabel.text = ""
                       })
                   }
    }
    
    func handleReadMessage()  {
        SocketTaskManager.shared.addMessageReadListener { (createdAt, userId) in
           if userId == self.id {
                let createdAtDate = self.stringToDateD(date: createdAt)!
                for i in 0..<self.allMessages!.array!.count {
                    let date = self.stringToDateD(date: self.allMessages!.array![i].createdAt!)!
                    if date <= createdAtDate {
                        if self.allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                            self.allMessages?.statuses![1].readMessageDate = createdAt
                        } else {
                            self.allMessages?.statuses![0].readMessageDate = createdAt
                        }
                        if self.allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                        (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.readMessage.text = "seen"
                        }
                    }
                }
            }
        }
    }
    
    func handleReceiveMessage()  {
        SocketTaskManager.shared.addMessageReceivedListener { (createdAt, userId) in
            if userId == self.id {
                let createdAtDate = self.stringToDateD(date: createdAt)!
                for i in 0..<self.allMessages!.array!.count {
                    let date = self.stringToDateD(date: self.allMessages!.array![i].createdAt!)!
                    if date <= createdAtDate {
                        if self.allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                            self.allMessages?.statuses![1].receivedMessageDate = createdAt
                        } else {
                            self.allMessages?.statuses![0].receivedMessageDate = createdAt
                        }
                        if self.allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.readMessage.text = "received"
                        }
                    }
                }
            }
        }
    }
    
    func handleMessageTyping()  {
        SocketTaskManager.shared.addMessageTypingListener { (userId) in
            if userId == self.id {
                self.typingLabel.text = "typing"
                self.timer?.invalidate()
                self.timer = Timer.scheduledTimer(withTimeInterval: 2, repeats: true, block: { (timer) in
                    self.typingLabel.text = ""
                })
            }
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height  : 0
            tableViewBottomConstraint.constant = isKeyboardShowing ? -keyboardFrame!.height - 55 : -55
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    if (self.allMessages?.array!.count)! > 1 {
                        let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
                        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    
    func getnewMessage(callHistory: CallHistory?, message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
        if (message.reciever == self.id || message.senderId == self.id) &&  message.senderId != message.reciever && self.id != SharedConfigs.shared.signedUser?.id {
            if message.senderId != SharedConfigs.shared.signedUser?.id {
                self.allMessages?.array!.append(message)
                if navigationController?.viewControllers.count == 2 {
                    SocketTaskManager.shared.messageRead(chatId: id!, messageId: message._id!)
                }
            } else {
                for i in 0..<allMessages!.array!.count {
                    if message.text  == allMessages!.array![i].text {
                         (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.readMessage.text = "hasav serverin"
                        self.allMessages!.array![i] = message
                    }
                }
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else if self.id == SharedConfigs.shared.signedUser?.id && message.senderId == message.reciever  {
            DispatchQueue.main.async {
                self.inputTextField.text = ""
            }
            self.allMessages?.array!.append(message)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            if message.senderId != SharedConfigs.shared.signedUser?.id {
                if (callHistory != nil && callHistory?.status == CallStatus.missed.rawValue) {
                    if callHistory?.caller != SharedConfigs.shared.signedUser?.id {
                        self.scheduleNotification(center: MainTabBarController.center, callHistory, message: message, name, lastname, username)
                    }
                } else if callHistory == nil {
                    self.scheduleNotification(center: MainTabBarController.center, callHistory, message: message, name, lastname, username)
                }
            }
        }
    }
    
    func addConstraints() {
        view.addSubview(messageInputContainerView)
        messageInputContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        messageInputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        messageInputContainerView.isUserInteractionEnabled = true
        messageInputContainerView.anchor(top: nil, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 25, height: 48)
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: 0)
        view.addConstraint(bottomConstraint!)
    }
    
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor, constant: 10).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor, constant: 0).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        inputTextField.isUserInteractionEnabled = true
        inputTextField.anchor(top: messageInputContainerView.topAnchor, paddingTop: 0, bottom: messageInputContainerView.bottomAnchor, paddingBottom: 0, left: messageInputContainerView.leftAnchor, paddingLeft: 5, right: view.rightAnchor, paddingRight: 30, width: 25, height: 48)
        sendButton.rightAnchor.constraint(equalTo: messageInputContainerView.rightAnchor, constant: 0).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        sendButton.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor, constant: 14).isActive = true
        sendButton.isUserInteractionEnabled = true
        sendButton.anchor(top: messageInputContainerView.topAnchor, paddingTop: 10, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: messageInputContainerView.rightAnchor, paddingRight: 0, width: 25, height:
            25)
        messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]", views: topBorderView)
        view.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .trailing, relatedBy: .equal, toItem: messageInputContainerView, attribute: .trailing, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .centerY, relatedBy: .equal, toItem: messageInputContainerView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func getImage() {
        ImageCache.shared.getImage(url: avatar ?? "", id: id!) { (userImage) in
            self.image = userImage
        }
    }
    
    func checkAndSendReadEvent() {
        if allMessages != nil && allMessages?.array != nil {
            if (self.allMessages?.array!.count)! > 0 {
                let status = self.allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id ? self.allMessages?.statuses![0] : self.allMessages?.statuses![1]
                let readMessageDate = self.stringToDateD(date: (status?.readMessageDate)!)
                for i in (0...((self.allMessages?.array!.count)! - 1)) {
                    let index = (self.allMessages?.array!.count)! - i - 1
                    let createdAt = self.allMessages!.array![index].createdAt
                    if self.allMessages!.array![(self.allMessages?.array!.count)! - i - 1].senderId != SharedConfigs.shared.signedUser?.id {
                        let date = self.stringToDateD(date: self.allMessages!.array![(self.allMessages?.array!.count)! - i - 1].createdAt!)!
                        if date.compare(readMessageDate!).rawValue == 1 {
                            SocketTaskManager.shared.messageRead(chatId: self.id!, messageId: self.allMessages!.array![(self.allMessages?.array!.count)! - i - 1]._id!)
                            
                            if self.allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                                self.allMessages?.statuses![0].readMessageDate = createdAt
                            } else {
                                self.allMessages?.statuses![1].readMessageDate = createdAt
                            }
                            let recent = (tabbar?.viewControllers![1] as! UINavigationController).viewControllers[0] as! RecentMessagesViewController
                            recent.handleRead(id: self.id!)
                            var oldModel = SharedConfigs.shared.signedUser
                            oldModel?.unreadMessagesCount! -= 1
                            UserDataController().populateUserProfile(model: oldModel!)
                            break
                        }
                    }
                }
                let indexPath = IndexPath(item: self.allMessages!.array!.count - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
    func getChatMessages() {
        self.activity.startAnimating()
        viewModel!.getChatMessages(id: id!) { (messages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.view.viewWithTag(5)?.removeFromSuperview()
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if messages?.array != nil {
                self.allMessages = messages!
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.view.viewWithTag(5)?.removeFromSuperview()
                    self.tableView.reloadData()
                    self.checkAndSendReadEvent()
                }
            }
        }
    }
}

//MARK: Extension
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (allMessages?.array?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size: CGSize?
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if (allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id) {
            if allMessages?.array![indexPath.row].type == "text" {
                size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
                let frame = NSString(string: allMessages?.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
                return frame.height + 30 + 22
            } else {
                return 80
            }
        } else {
            if allMessages?.array![indexPath.row].type == "text" {
                size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
                let frame = NSString(string: allMessages?.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
                return frame.height + 30
            } else {
                return 80
            }
        }
    }
    
    func secondsToHoursMinutesSeconds(seconds : Int) -> String {
        if seconds / 3600 == 0 && ((seconds % 3600) / 60) == 0 {
            return "\((seconds % 3600) % 60) sec."
        } else if seconds / 3600 == 0 {
            return "\((seconds % 3600) / 60) min. \((seconds % 3600) % 60) sec."
        }
        return "\(seconds / 3600) hr. \((seconds % 3600) / 60) min. \((seconds % 3600) % 60) sec."
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if !tabbar!.onCall {
            tabbar!.handleCallClick(id: id!, name: name ?? username ?? "", mode: .videoCall)
            tabbar!.callsVC?.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: id!)
        } else {
            tabbar!.handleClickOnSamePerson()
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            if allMessages?.array![indexPath.row].type == "text" {
                let cell = tableView.dequeueReusableCell(withIdentifier: Self.sendMessageCellIdentifier, for: indexPath) as! SendMessageTableViewCell
                cell.messageLabel.text = allMessages?.array![indexPath.row].text
                cell.messageLabel.backgroundColor =  UIColor.blue.withAlphaComponent(0.8)
                cell.messageLabel.textColor = .white
                cell.messageLabel.sizeToFit()
                if allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
                    if allMessages?.array![indexPath.row]._id != nil {
                        let date = stringToDateD(date: allMessages!.array![indexPath.row].createdAt!)
                        let status = allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id ? allMessages?.statuses![1] : allMessages?.statuses![0]
                        if date! < stringToDateD(date: status!.receivedMessageDate!)! {
                            if date! < stringToDateD(date: status!.readMessageDate!)! || date! == stringToDateD(date: status!.readMessageDate!)! {
                                cell.readMessage.text = "seen"
                            } else {
                                cell.readMessage.text = "received"
                            }
                        } else if date! > stringToDateD(date: status!.receivedMessageDate!)! {
                            cell.readMessage.text = "hasav serverin"
                        } else {
                            if date! == stringToDateD(date: status!.readMessageDate!)! || date! < stringToDateD(date: status!.readMessageDate!)! {
                                cell.readMessage.text = "seen"
                            } else {
                                cell.readMessage.text = "received"
                            }
                        }
                    } else {
                        cell.readMessage.text = "chi hasel server"
                    }
                }
                return cell
            } else if allMessages?.array![indexPath.row].type == "call" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendCallCell", for: indexPath) as! SendCallTableViewCell
                let tapSendCallTableViewCell = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                cell.callMessageView.addGestureRecognizer(tapSendCallTableViewCell)
                if allMessages?.array![indexPath.row].call?.status == CallStatus.accepted.rawValue {
                    cell.ststusLabel.text = CallStatus.outgoing.rawValue.localized()
                    cell.durationAndStartTimeLabel.text =  "\(stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!)), \(Int(allMessages?.array![indexPath.row].call?.duration ?? 0).secondsToHoursMinutesSeconds())"
                    return cell
                } else if allMessages?.array![indexPath.row].call?.status == CallStatus.missed.rawValue.lowercased() {
                    cell.ststusLabel.text = "\(CallStatus.outgoing.rawValue)".localized()
                    cell.durationAndStartTimeLabel.text = "\(stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!))"
                    return cell
                } else {
                    cell.ststusLabel.text = "\(CallStatus.outgoing.rawValue)".localized()
                    cell.durationAndStartTimeLabel.text = "\(stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!))"
                    return cell
                }
            } 
        } else {
            if allMessages?.array![indexPath.row].type == "text" {
                let cell = tableView.dequeueReusableCell(withIdentifier: Self.receiveMessageCellIdentifier, for: indexPath) as! RecieveMessageTableViewCell
                cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
                cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
                cell.userImageView.image = image
                cell.messageLabel.text = allMessages?.array![indexPath.row].text
                cell.messageLabel.sizeToFit()
                return cell
            }  else if allMessages?.array![indexPath.row].type == "call" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveCallCell", for: indexPath) as! RecieveCallTableViewCell
                let tapSendCallTableViewCell = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
                cell.cellMessageView.addGestureRecognizer(tapSendCallTableViewCell)
                cell.userImageView.image = image
                if allMessages?.array![indexPath.row].call?.status == CallStatus.accepted.rawValue {
                    cell.arrowImageView.tintColor = UIColor(red: 48/255, green: 121/255, blue: 255/255, alpha: 1)
                    cell.statusLabel.text = CallStatus.incoming.rawValue.localized()
                    cell.durationAndStartCallLabel.text = "\(stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!)), \(Int(allMessages?.array![indexPath.row].call?.duration ?? 0).secondsToHoursMinutesSeconds())"
                    return cell
                } else if allMessages?.array![indexPath.row].call?.status == CallStatus.missed.rawValue.lowercased() {
                    cell.arrowImageView.tintColor = .red
                    cell.statusLabel.text = "\(CallStatus.missed.rawValue)_call".localized()
                    cell.durationAndStartCallLabel.text = "\(stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!))"
                    return cell
                } else  {
                    cell.arrowImageView.tintColor = .red
                    cell.statusLabel.text = "\(CallStatus.cancelled.rawValue)_call".localized()
                    cell.durationAndStartCallLabel.text = "\(stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!))"
                    return cell
                }
                
            }
        }
        return UITableViewCell()
    }
}
