//
//  ChatViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import SocketIO
import AVKit
import AVFoundation
import Photos

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
    var image = UIImage(named: "noPhoto")
    var tabbar: MainTabBarController?
    var mainRouter: MainRouter?
    var statuses: [MessageStatus]?
    var indexPath: IndexPath?
    var mode: MessageMode?
    var fromContactProfile: Bool?
    var viewonCell = UIView()
    var rowHeights:[Int:CGFloat] = [:]
    var viewConfigurator: ConfigureChatViewController!
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
    var sendImage: UIImage?
    var sendAsset: AVURLAsset?
    var sendThumbnail: UIImage?
    var sendImageTmp: UIImage?
    var player = AVPlayer()
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigurator = ConfigureChatViewController(mainRouter: mainRouter!)
        tableView.delegate = self
        tableView.dataSource = self
        mode = .main
        player.preventsDisplaySleepDuringVideoPlayback = true
        getChatMessages(dateUntil: nil)
        tabbar = tabBarController as? MainTabBarController
        viewConfigurator.addConstraints()
        viewConfigurator.setupInputComponents()
        viewConfigurator.setObservers()
        inputTextField.placeholder = "enter_message".localized()
        sendButton.setTitle("send".localized(), for: .normal)
        self.navigationItem.rightBarButtonItem = .init(UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .done, target: self, action: #selector(infoButtonAction)))
        viewConfigurator.setTitle()
        viewConfigurator.getImage()
        viewonCell.tag = 12
        activity.tag = 5
        tableView.estimatedRowHeight = 100
        tableView.rowHeight = UITableView.automaticDimension
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
        if tabBarController?.tabBar.isHidden == false {
            tabBarController?.tabBar.isHidden = true
        }
        if navigationController?.navigationBar.isHidden == true {
            navigationController?.navigationBar.isHidden = false
        }
        checkAndSendReadEvent()
        viewConfigurator.setupInputComponents()
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
            if sendImage != nil {
                ChatNetworkManager().sendImageInChat(tmpImage: sendImage, userId: self.id ?? "", text: inputTextField.text!) { (error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    }
                }
            } else if sendAsset != nil {
                let text = inputTextField.text
                let sendAssetCopy = sendAsset
                inputTextField.text = ""
                sendAsset = nil
                viewConfigurator.removeSendImageView()
                let uuid = UUID().uuidString
                self.allMessages?.array?.append(Message(call: nil, type: "video", _id: uuid, reciever: id, text: text, createdAt: nil, updatedAt: nil, owner: nil, senderId: SharedConfigs.shared.signedUser?.id, image: Image(imageName: nil, imageURL: nil), video: nil))
                self.tableView.insertRows(at: [IndexPath(row: allMessages!.array!.count - 1, section: 0)], with: .automatic)
                let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.viewModel?.encodeVideo(at: sendAssetCopy?.url.absoluteURL ?? URL(fileURLWithPath: "")) { (url, error) in
                    if let url = url {
                        do {
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                ChatNetworkManager().sendVideoInChat(data: data, id: self.id!, text: self.inputTextField.text!)
                            }
                          
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            } else if inputTextField.text != "" {
                let text = inputTextField.text
                inputTextField.text = ""
                let uuid = UUID().uuidString
                SocketTaskManager.shared.send(message: text!, id: id!, uuid: uuid)
                self.allMessages?.array?.append(Message(call: nil, type: "text", _id: uuid, reciever: id, text: text, createdAt: nil, updatedAt: nil, owner: nil, senderId: SharedConfigs.shared.signedUser?.id, image: nil, video: nil))
                self.tableView.insertRows(at: [IndexPath(row: allMessages!.array!.count - 1, section: 0)], with: .automatic)
                let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.viewModel?.removeLabel(view: self.view)
            }
        } else {
            mode = .main
            if inputTextField.text != "" {
                if let cell = tableView.cellForRow(at: indexPath!) as? SentMessageTableViewCell {
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
    
    func getnewMessage(callHistory: CallHistory?, message: Message, _ name: String?, _ lastname: String?, _ username: String?, uuid: String) {
        if (message.reciever == self.id || message.senderId == self.id) &&  message.senderId != message.reciever && self.id != SharedConfigs.shared.signedUser?.id {
            if message.senderId != SharedConfigs.shared.signedUser?.id {
                self.allMessages?.array!.append(message)
                self.tableView.insertRows(at: [IndexPath(row: allMessages!.array!.count - 1, section: 0)], with: .automatic)
                let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.viewModel?.removeLabel(view: self.view)
                if (navigationController?.viewControllers.count == 2) || (tabBarController?.selectedIndex == 2 && navigationController?.viewControllers.count == 6)  {
                    SocketTaskManager.shared.messageRead(chatId: id!, messageId: message._id!)
                }
            } else {
                    for i in 0..<allMessages!.array!.count {
                        if uuid == allMessages!.array![i]._id {
                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell)?.readMessage.text = "sent"
                            self.allMessages!.array![i] = message
                        }
                    }
                if message.type == "image" {
                    self.sendImageTmp = nil
                } else if message.type == "video" {
                    self.sendThumbnail = nil
                }
            }
        } else if self.id == SharedConfigs.shared.signedUser?.id && message.senderId == message.reciever  {
            DispatchQueue.main.async {
                self.inputTextField.text = ""
            }
            self.allMessages?.array!.append(message)
            self.viewModel?.removeLabel(view: self.view)
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
                                    self.viewModel?.setLabel(text: "there_is_no_messages_yet".localized(), view: self.view, superView: self.tableView)
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
                if let cell = tableView.cellForRow(at: IndexPath(row: count, section: 0)) as? RecievedMessageTableViewCell {
                    DispatchQueue.main.async {
                        cell.messageLabel.text = message.text
                    }
                }
            }
        }
    }
    
    func handleMessageReadFromTabbar(createdAt: String, userId: String) {
        if userId == self.id {
            let createdAtDate = self.viewModel!.stringToDateD(date: createdAt)!
            for i in 0..<self.allMessages!.array!.count {
                if let date = self.viewModel!.stringToDateD(date: self.allMessages?.array?[i].createdAt ?? "") {
                    if date <= createdAtDate {
                        if allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                            self.allMessages?.statuses![1].readMessageDate = createdAt
                        } else {
                            self.allMessages?.statuses![0].readMessageDate = createdAt
                        }
                        if allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell
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
            let createdAtDate = self.viewModel!.stringToDateD(date: createdAt)!
            for i in 0..<self.allMessages!.array!.count {
                
                if let date = self.viewModel!.stringToDateD(date: self.allMessages?.array?[i].createdAt ?? "") {
                    if date <= createdAtDate {
                        if allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                            self.allMessages?.statuses![1].receivedMessageDate = createdAt
                        } else {
                            self.allMessages?.statuses![0].receivedMessageDate = createdAt
                        }
                        if allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell
                            if cell != nil && cell?.readMessage.text != "seen".localized() && cell?.readMessage.text != "delivered".localized() {
                                cell?.readMessage.text = "delivered".localized()
                            }
                        }
                    }
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
                let createdAtDate = self.viewModel!.stringToDateD(date: createdAt)!
                for i in 0..<self.allMessages!.array!.count {
                    let date = self.viewModel!.stringToDateD(date: self.allMessages!.array![i].createdAt!)!
                    if date <= createdAtDate {
                        if self.allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                            self.allMessages?.statuses![1].readMessageDate = createdAt
                        } else {
                            self.allMessages?.statuses![0].readMessageDate = createdAt
                        }
                        if self.allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell
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
                let createdAtDate = self.viewModel!.stringToDateD(date: createdAt)!
                for i in 0..<self.allMessages!.array!.count {
                    let date = self.viewModel!.stringToDateD(date: self.allMessages!.array![i].createdAt!)!
                    if date <= createdAtDate {
                        if self.allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id {
                            self.allMessages?.statuses![1].receivedMessageDate = createdAt
                        } else {
                            self.allMessages?.statuses![0].receivedMessageDate = createdAt
                        }
                        if self.allMessages!.array![i].senderId == SharedConfigs.shared.signedUser?.id {
                            let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell
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
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        viewConfigurator.handleFinishImagePicking(info: info)
    }
    
    func checkAndSendReadEvent() {
        if allMessages != nil && allMessages?.array != nil {
            if (self.allMessages?.array!.count)! > 0 {
                let status = self.allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id ? self.allMessages?.statuses![0] : self.allMessages?.statuses![1]
                let readMessageDate = self.viewModel?.stringToDateD(date: (status?.readMessageDate)!)
                for i in (0...((self.allMessages?.array!.count)! - 1)) {
                    let index = (self.allMessages?.array!.count)! - i - 1
                    let createdAt = self.allMessages!.array![index].createdAt
                    if self.allMessages!.array![(self.allMessages?.array!.count)! - i - 1].senderId != SharedConfigs.shared.signedUser?.id {
                        let date = self.viewModel!.stringToDateD(date: self.allMessages!.array![(self.allMessages?.array!.count)! - i - 1].createdAt!)!
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
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        tabbar?.videoVC?.isCallHandled = false
        if !tabbar!.onCall {
            tabbar!.handleCallClick(id: id!, name: name ?? username ?? "", mode: .videoCall)
            tabbar!.callsVC?.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: id!)
        } else {
            tabbar!.handleClickOnSamePerson()
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
                        self.viewModel?.setLabel(text: "there_is_no_messages_yet".localized(), view: self.view, superView: self.tableView)
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

}

//MARK: Extension
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (allMessages?.array?.count ?? 0)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return viewConfigurator.heightForRowAt(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        viewConfigurator.configureTableView(indexPath: indexPath)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == 0 && self.allMessages?.array![indexPath.row] != nil && (self.allMessages?.array!.count)! > 1 {
            self.getChatMessages(dateUntil: self.allMessages?.array![0].createdAt)
        }
    }
}


