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

class ChatViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
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
    var indexPath: IndexPath?
    var mode: MessageMode?
    var fromContactProfile: Bool?
    var rowHeights:[Int:CGFloat] = [:]
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
    var check = false
    var newArray: [Message]?
    var test = false
    let sendImage = UIImage(named: "sea")
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        mode = .main
        getChatMessages(dateUntil: nil)
        tabbar = tabBarController as? MainTabBarController
        addConstraints()
//        tableView.estimatedRowHeight = 100
//        tableView.rowHeight = UITableView.automaticDimension
        setupInputComponents()
        setObservers()
        inputTextField.placeholder = "enter_message".localized()
        sendButton.setTitle("send".localized(), for: .normal)
        self.navigationItem.rightBarButtonItem = .init(UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .done, target: self, action: #selector(infoButtonAction)))
        setTitle()
        getImage()
        setObservers()
        activity.tag = 5
        if (SocketTaskManager.shared.socket?.handlers.count)! < 13 {
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
        if !fromContactProfile! {
            mainRouter?.showContactProfileViewControllerFromChat(id: id!, fromChat: true)
        } else {
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    @objc func inputTextFieldDidCghe() {
        SocketTaskManager.shared.messageTyping(chatId: id!)
    }
    
    @objc func sendMessage() {
        if mode == .main {
            if inputTextField.text != "" {
                let text = inputTextField.text
                inputTextField.text = ""
                SocketTaskManager.shared.send(message: text!, id: id!)
                self.allMessages?.array?.append(Message(call: nil, type: "text", _id: nil, reciever: id, text: text, createdAt: nil, updatedAt: nil, owner: nil, senderId: SharedConfigs.shared.signedUser?.id, image: nil))
                self.tableView.insertRows(at: [IndexPath(row: allMessages!.array!.count - 1, section: 0)], with: .automatic)
                self.removeLabel()
            }
        } else {
            mode = .main
            if inputTextField.text != "" {
                if let cell = tableView.cellForRow(at: indexPath!) as? SendMessageTableViewCell {
                    self.viewModel?.editChatMessage(messageId: cell.id!, text: inputTextField.text!, completion: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                            }
                        } else {
                            DispatchQueue.main.async {
                                cell.messageLabel.text = self.inputTextField.text
                                self.inputTextField.text = ""
                            }
                        }
                    })
                }
            }
        }
    }
    
    func setLabel(text: String) {
        let label = UILabel()
        label.text = text
        label.tag = 13
        label.textAlignment = .center
        label.textColor = .darkGray
        self.tableView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func removeLabel() {
        self.view.viewWithTag(13)?.removeFromSuperview()
    }
    
    func handleDeleteMessage(messages: [Message]) {
        if let _ =  self.navigationController?.visibleViewController as? ChatViewController {
            for message in messages {
                var i = 0
                if message.owner != SharedConfigs.shared.signedUser?.id {
                    DispatchQueue.main.async {
                        while i < self.allMessages?.array?.count ?? 0 {
                            if self.allMessages?.array?[i]._id == message._id {
                                self.allMessages?.array?.remove(at: i)
                                self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                                if self.allMessages?.array?.count == 0 {
                                    self.setLabel(text: "there_is_no_messages_yet".localized())
                                }
                            } else {
                                i += 1
                            }
                        }
                    }
                }
            }
        }
    }
    
    func handleMessageEdited(message: Message) {
        if self.navigationController?.visibleViewController == self || (self.navigationController?.viewControllers.count ?? 0) - 1 >=  self.navigationController?.viewControllers.lastIndex(of: self) ?? 0 {
            var count = 0
            for i in 0..<(allMessages?.array!.count)! {
                if allMessages?.array![i]._id == message._id {
                    allMessages?.array![i] = message
                    count = i
                    break
                }
            }
            if id != SharedConfigs.shared.signedUser?.id {
                if let cell = tableView.cellForRow(at: IndexPath(row: count, section: 0)) as? RecieveMessageTableViewCell {
                    DispatchQueue.main.async {
                        cell.messageLabel.text = message.text
                    }
                }
            }
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
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell
                            if cell?.readMessage.text != "seen".localized() {
                                cell?.readMessage.text = "seen".localized()
                            }
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
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell
                            if cell != nil && cell?.readMessage.text != "seen".localized() && cell?.readMessage.text != "delivered".localized() {
                                cell?.readMessage.text = "delivered".localized()
                            }
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
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell
                            if cell?.readMessage.text != "seen".localized() {
                                cell?.readMessage.text = "seen".localized()
                            }
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
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell
                            if cell != nil && cell?.readMessage.text != "seen".localized() && cell?.readMessage.text != "delivered".localized() {
                                cell?.readMessage.text = "delivered".localized()
                            }
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
                    if (self.allMessages?.array != nil && (self.allMessages?.array!.count)! > 1) {
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
                self.removeLabel()
                if (navigationController?.viewControllers.count == 2) || (tabBarController?.selectedIndex == 2 && navigationController?.viewControllers.count == 6)  {
                    SocketTaskManager.shared.messageRead(chatId: id!, messageId: message._id!)
                }
            } else {
                for i in 0..<allMessages!.array!.count {
                    if message.text  == allMessages!.array![i].text {
                        (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.readMessage.text = "sent"
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
            self.removeLabel()
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
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        bottomConstraint?.isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        messageInputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        messageInputContainerView.isUserInteractionEnabled = true
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func setSendImageView(image: UIImage) {
        let viewOfImage = UIView()
        tableView.addSubview(viewOfImage)
        viewOfImage.translatesAutoresizingMaskIntoConstraints = false
        viewOfImage.leftAnchor.constraint(equalTo: self.tableView.leftAnchor, constant: 10).isActive = true
        viewOfImage.bottomAnchor.constraint(equalTo: messageInputContainerView.topAnchor, constant: -5).isActive = true
        viewOfImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        viewOfImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let sendingImage = UIImageView()
        tableView.addSubview(sendingImage)
        sendingImage.translatesAutoresizingMaskIntoConstraints = false
        sendingImage.leftAnchor.constraint(equalTo: self.tableView.leftAnchor, constant: 10).isActive = true
        sendingImage.bottomAnchor.constraint(equalTo: viewOfImage.bottomAnchor, constant: 0).isActive = true
        sendingImage.topAnchor.constraint(equalTo: viewOfImage.topAnchor, constant: 0).isActive = true
        sendingImage.rightAnchor.constraint(equalTo: viewOfImage.rightAnchor, constant: 0).isActive = true
        sendingImage.clipsToBounds = true
        sendingImage.image = image
//        sendingImage.contentMode = .scaleAspectFit
        sendingImage.layer.cornerRadius = 20
       
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            setSendImageView(image: selectedImage)
        }
        dismiss(animated: true, completion: nil)
    }
    
    func setupInputComponents() {
        let topBorderView = UIView()
      
        
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -32).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor, constant: 44).isActive = true
        inputTextField.bottomAnchor.constraint(equalTo: messageInputContainerView.bottomAnchor, constant: 0).isActive = true
        inputTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        inputTextField.isUserInteractionEnabled = true
        sendButton.translatesAutoresizingMaskIntoConstraints = false
        sendButton.rightAnchor.constraint(equalTo: messageInputContainerView.rightAnchor, constant: -10).isActive = true
        sendButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        sendButton.topAnchor.constraint(equalTo: messageInputContainerView.topAnchor, constant: 10).isActive = true
        sendButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        sendButton.isUserInteractionEnabled = true
        messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]", views: topBorderView)
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
//        uploadImageView.image = UIImage(named: "more") //UIImage(systemName: "photo.on.rectangle.fill")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        uploadImageView.backgroundColor = .red
        messageInputContainerView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: messageInputContainerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
    }
    
    func getImage() {
        ImageCache.shared.getImage(url: avatar ?? "", id: id!, isChannel: false) { (userImage) in
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
                            if self.allMessages!.array![(self.allMessages?.array!.count)! - i - 1].call == nil {
                                let profileNC = tabbar?.viewControllers?[2] as? UINavigationController
                                let profileVC = profileNC?.viewControllers[0] as? ProfileViewController
                                profileVC?.changeNotificationNumber()
                                break
                            } else {
                                continue
                            }
                        }
                    }
                }
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
        tabbar?.videoVC?.isCallHandled = false
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
    
    func getChatMessages(dateUntil: String?) {
        if self.activity != nil {
            self.activity.startAnimating()
        }
        viewModel!.getChatMessages(id: id!, dateUntil: dateUntil) { (messages, error) in
            if messages?.array?.count == 0 || messages?.array == nil {
                self.check = true
                DispatchQueue.main.async {
                    if dateUntil == nil {
                        self.activity?.stopAnimating()
                        self.setLabel(text: "there_is_no_messages_yet".localized())
                    }
                }
            }
            if error != nil {
                DispatchQueue.main.async {
                    self.activity?.stopAnimating()
                    self.view.viewWithTag(5)?.removeFromSuperview()
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if messages?.array != nil {
                if self.allMessages != nil && self.allMessages!.array != nil {
                    let array = self.allMessages?.array
                    self.allMessages?.array = messages?.array
                    self.allMessages?.array?.append(contentsOf: array!)
                    self.test = true
                } else {
                    self.newArray = messages?.array
                    self.allMessages = messages
                }
                DispatchQueue.main.async {
                    if self.activity != nil {
                        self.activity.stopAnimating()
                    }
                    self.view.viewWithTag(5)?.removeFromSuperview()
                    var arrayOfIndexPaths: [IndexPath] = []
                    for i in 0..<messages!.array!.count {
                        arrayOfIndexPaths.append(IndexPath(row: i, section: 0))
                    }
                    if dateUntil != nil {
                        let initialOffset = self.tableView.contentOffset.y
                        self.tableView.beginUpdates()
                        UIView.setAnimationsEnabled(false)
                        self.tableView.insertRows(at: arrayOfIndexPaths, with: .none)
                        self.tableView.endUpdates()
                        self.tableView.scrollToRow(at: IndexPath(row: arrayOfIndexPaths.count, section: 0), at: .top, animated: false)
                        UIView.setAnimationsEnabled(true)
                        self.tableView.contentOffset.y += initialOffset
                    } else {
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                            if arrayOfIndexPaths.count > 1 {
                                self.tableView.scrollToRow(at: IndexPath(row: arrayOfIndexPaths.count - 1, section: 0), at: .bottom, animated: false)
                            }
                        }
                    }
                    self.checkAndSendReadEvent()
                }
            }
        }
    }
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureReconizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let cell = tableView.cellForRow(at: indexPath) as? SendMessageTableViewCell
                print("cell?.messageLabel.text \(String(describing: cell?.messageLabel.text))")
                let alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { (action) in
                    self.viewModel?.deleteChatMessages(arrayMessageIds: [cell?.id ?? ""], completion: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                            }
                        }
                    })
                }))
                alert.addAction(UIAlertAction(title: "edit".localized(), style: .default, handler: { (action) in
                    self.mode = .edit
                    self.indexPath = indexPath
                    self.inputTextField.text = cell?.messageLabel.text
                }))
                alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
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
        if let cell = tableView.cellForRow(at: indexPath) as? SendImageMessageTableViewCell {
        if let height = self.rowHeights[indexPath.row]{
            return self.sendImage!.size.height
        } else {
            return 200
        }
                } else{
                    return 60
                }
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
        return 300
//        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap(gestureReconizer:)))
       
//        let cell = tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SendImageMessageTableViewCell
//        DispatchQueue.main.async {
            
//            let aspectRatio = (self.sendImage! as UIImage).size.height/(self.sendImage! as UIImage).size.width
            
//            cell.snedImageView.image = self.sendImage
//            var imageHeight =  (self.sendImage! as UIImage).size.height //self.view.frame.width * aspectRatio
//            tableView.beginUpdates()
//            if (self.image?.size.height)! > 500 {
//                imageHeight = cell.snedImageView.frame.width
//            }
//            cell.setPostedImage(image: self.sendImage!)
//            cell.imageViewHeightConstraint.constant = self.sendImage!.size.height
//            cell.imageWidthConstraint.constant = (self.sendImage?.size.width)!
//            self.rowHeights[indexPath.row] = imageHeight
    
//            tableView.endUpdates()
            
//        }
        
//        return cell
        if allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            if allMessages?.array![indexPath.row].type == "text" {
                let cell = tableView.dequeueReusableCell(withIdentifier: Self.sendMessageCellIdentifier, for: indexPath) as! SendMessageTableViewCell
                cell.messageLabel.text = allMessages?.array![indexPath.row].text
                cell.messageLabel.backgroundColor =  UIColor(red: 135/255, green: 192/255, blue: 237/255, alpha: 1)
                cell.id = allMessages!.array![indexPath.row]._id
                cell.messageLabel.textColor = .black
                cell.messageLabel.sizeToFit()
                cell.addGestureRecognizer(tap)
                if allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
                    if allMessages?.array![indexPath.row]._id != nil {
                        let date = stringToDateD(date: allMessages!.array![indexPath.row].createdAt!)
                        let status = allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id ? allMessages?.statuses![1] : allMessages?.statuses![0]
                        if date! < stringToDateD(date: status!.receivedMessageDate!)! {
                            if date! < stringToDateD(date: status!.readMessageDate!)! || date! == stringToDateD(date: status!.readMessageDate!)! {
                                cell.readMessage.text = "seen".localized()
                            } else {
                                cell.readMessage.text = "delivered".localized()
                            }
                        } else if date! > stringToDateD(date: status!.receivedMessageDate!)! {
                            cell.readMessage.text = "sent".localized()
                        } else {
                            if date! == stringToDateD(date: status!.readMessageDate!)! || date! < stringToDateD(date: status!.readMessageDate!)! {
                                cell.readMessage.text = "seen".localized()
                            } else {
                                cell.readMessage.text = "delivered".localized()
                            }
                        }
                    } else {
                        cell.readMessage.text = "waiting".localized()
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
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && self.allMessages?.array![indexPath.row] != nil && (self.allMessages?.array!.count)! > 1 {
            self.getChatMessages(dateUntil: self.allMessages?.array![0].createdAt)
        }
    }
}

fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
