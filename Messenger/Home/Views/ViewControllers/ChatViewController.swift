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
    var viewonCell = UIView()
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
    var sendImage: UIImage?
    var sendAsset: AVURLAsset?
    var player = AVPlayer()
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        mode = .main
        player.preventsDisplaySleepDuringVideoPlayback = true
        getChatMessages(dateUntil: nil)
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
//        HomeNetworkManager().getVideo(url: "https://192.168.0.105:3000/message/video/userf@13368073233206895fa3dd9ee969141597bb52d1.mp4")
        view.endEditing(true)
        if !(tabBarController?.tabBar.isHidden)! {
            tabBarController?.tabBar.isHidden = true
        }
        if (navigationController?.navigationBar.isHidden)! {
            navigationController?.navigationBar.isHidden = false
        }
        checkAndSendReadEvent()
        setupInputComponents()
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
                HomeNetworkManager().sendImageInChat(tmpImage: sendImage, userId: self.id ?? "", text: inputTextField.text!) { (error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.removeSendImageView()
                            self.inputTextField.text = ""
                        }
                        
                    }
                }
            } else if sendAsset != nil {
                self.viewModel?.encodeVideo(at: sendAsset?.url.absoluteURL ?? URL(fileURLWithPath: "")) { (url, error) in
                    if let url = url {
                        do {
                            let data = try Data(contentsOf: url)
                            DispatchQueue.main.async {
                                HomeNetworkManager().sendVideoInChat(data: data, id: self.id!, text: self.inputTextField.text!)
                            }
                        } catch {
                            print(error.localizedDescription)
                        }
                    }
                }
            } else if inputTextField.text != "" {
                let text = inputTextField.text
                inputTextField.text = ""
                SocketTaskManager.shared.send(message: text!, id: id!)
                self.allMessages?.array?.append(Message(call: nil, type: "text", _id: nil, reciever: id, text: text, createdAt: nil, updatedAt: nil, owner: nil, senderId: SharedConfigs.shared.signedUser?.id, image: nil, video: nil))
                self.tableView.insertRows(at: [IndexPath(row: allMessages!.array!.count - 1, section: 0)], with: .automatic)
                let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                self.removeLabel()
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
    
    
    
//    func getnewMessage(callHistory: CallHistory?, message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
//        if (message.reciever == self.id || message.senderId == self.id) &&  message.senderId != message.reciever && self.id != SharedConfigs.shared.signedUser?.id {
//            if message.senderId != SharedConfigs.shared.signedUser?.id {
//                self.allMessages?.array!.append(message)
//                self.removeLabel()
//                if (navigationController?.viewControllers.count == 2) || (tabBarController?.selectedIndex == 2 && navigationController?.viewControllers.count == 6)  {
//                    SocketTaskManager.shared.messageRead(chatId: id!, messageId: message._id!)
//                }
//            } else {
//                if message.type == "text" {
//                    for i in 0..<allMessages!.array!.count {
//                        if message.text  == allMessages!.array![i].text {
//                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell)?.readMessage.text = "sent"
//                            self.allMessages!.array![i] = message
//                        }
//                    }
//                } else if message.type == "image" {
//                    DispatchQueue.main.async {
//                        self.allMessages?.array!.append(message)
//                        let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
//                        self.tableView.insertRows(at: [indexPath], with: .automatic)
//                        let cell = self.tableView.cellForRow(at: indexPath) as? SentMediaMessageTableViewCell
//                        cell?.snedImageView.image = self.sendImage
//                        self.sendImage = nil
//                        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                    }
//                }
//            }
//        } else if self.id == SharedConfigs.shared.signedUser?.id && message.senderId == message.reciever  {
//            DispatchQueue.main.async {
//                self.inputTextField.text = ""
//            }
//            self.allMessages?.array!.append(message)
//            self.removeLabel()
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
//                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
//        } else {
//            if message.senderId != SharedConfigs.shared.signedUser?.id {
//                if (callHistory != nil && callHistory?.status == CallStatus.missed.rawValue) {
//                    if callHistory?.caller != SharedConfigs.shared.signedUser?.id {
//                        self.scheduleNotification(center: MainTabBarController.center, callHistory, message: message, name, lastname, username)
//                    }
//                } else if callHistory == nil {
//                    self.scheduleNotification(center: MainTabBarController.center, callHistory, message: message, name, lastname, username)
//                }
//            }
//        }
//    }
    

    
    func getnewMessage(callHistory: CallHistory?, message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
        if (message.reciever == self.id || message.senderId == self.id) &&  message.senderId != message.reciever && self.id != SharedConfigs.shared.signedUser?.id {
            if message.senderId != SharedConfigs.shared.signedUser?.id {
                self.allMessages?.array!.append(message)
                self.removeLabel()
                if (navigationController?.viewControllers.count == 2) || (tabBarController?.selectedIndex == 2 && navigationController?.viewControllers.count == 6)  {
                    SocketTaskManager.shared.messageRead(chatId: id!, messageId: message._id!)
                }
            } else {
                if message.type == "text" {
                    for i in 0..<allMessages!.array!.count {
                        if message.text  == allMessages!.array![i].text {
                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell)?.readMessage.text = "sent"
                            self.allMessages!.array![i] = message
                        }
                    }
                } else if message.type == "image" || message.type == "video" {
                    self.allMessages?.array!.append(message)
                }
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
                if let cell = tableView.cellForRow(at: IndexPath(row: count, section: 0)) as? RecievedMessageTableViewCell {
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
    
    
    
    func addConstraints() {
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        bottomConstraint?.isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        messageInputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        messageInputContainerView.isUserInteractionEnabled = true
        messageInputContainerView.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    @objc func handleUploadTap() {
        let imagePickerController = UIImagePickerController()
//        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func setSendImageView(image: UIImage) {
        let viewOfImage = UIView()
        tableView.addSubview(viewOfImage)
        viewOfImage.tag = 14
        viewOfImage.translatesAutoresizingMaskIntoConstraints = false
        viewOfImage.leftAnchor.constraint(equalTo: self.tableView.leftAnchor, constant: 10).isActive = true
        viewOfImage.bottomAnchor.constraint(equalTo: messageInputContainerView.topAnchor, constant: -5).isActive = true
        viewOfImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        viewOfImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let sendingImage = UIImageView()
        viewOfImage.addSubview(sendingImage)
        sendingImage.translatesAutoresizingMaskIntoConstraints = false
        sendingImage.leftAnchor.constraint(equalTo: self.tableView.leftAnchor, constant: 10).isActive = true
        sendingImage.bottomAnchor.constraint(equalTo: viewOfImage.bottomAnchor, constant: 0).isActive = true
        sendingImage.topAnchor.constraint(equalTo: viewOfImage.topAnchor, constant: 0).isActive = true
        sendingImage.rightAnchor.constraint(equalTo: viewOfImage.rightAnchor, constant: 0).isActive = true
        sendingImage.clipsToBounds = true
        sendingImage.image = image
        sendingImage.layer.cornerRadius = 20
    }
    
    func removeSendImageView() {
        self.view.viewWithTag(14)?.removeFromSuperview()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            setSendImageView(image: selectedImage)
            sendImage = selectedImage
            dismiss(animated: true, completion: nil)
            return
        }
        if let videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL {
            print(videoURL)
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
                if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                    print("creating 2")
                    do {
                        self.sendAsset = AVURLAsset(url: videoURL as URL , options: nil)
                        _ = AVAsset(url: videoURL as URL)
                        let imgGenerator = AVAssetImageGenerator(asset: self.sendAsset!)
                        imgGenerator.appliesPreferredTrackTransform = true
                        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                        let thumbnail = UIImage(cgImage: cgImage)
                        DispatchQueue.main.async {
                            self.setSendImageView(image: thumbnail)
                        }
                    } catch let error {
                        print("*** Error: \(error.localizedDescription)")
                    }
                }
                
            })
        }
        dismiss(animated: true, completion: nil)
    }

    func setupInputComponents() {
        messageInputContainerView.layer.borderWidth = 1
        messageInputContainerView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
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
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
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
    
    @objc func handleTapOnImage(gestureReconizer: CustomTapGesture) {
        self.navigationController?.navigationBar.isHidden = true
        let viewUnderImageView = UIView()
        viewUnderImageView.tag = 23
        viewUnderImageView.backgroundColor = UIColor.white
        self.view.addSubview(viewUnderImageView)
        viewUnderImageView.translatesAutoresizingMaskIntoConstraints = false
        viewUnderImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        viewUnderImageView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.view.trailingAnchor, multiplier: 1).isActive = true
        viewUnderImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
        viewUnderImageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0).isActive = true
        let imageView = UIImageView()
        viewUnderImageView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.view.trailingAnchor, multiplier: 1).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 80).isActive = true
        ImageCache.shared.getImage(url: allMessages?.array?[gestureReconizer.indexPath.row].image?.imageURL ?? "", id: allMessages?.array?[gestureReconizer.indexPath.row]._id ?? "", isChannel: true) { (image) in
            imageView.image = image
        }
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "closeColor"), for: .normal)
        closeButton.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
        viewUnderImageView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 30).isActive = true
    }
    
    @objc func handleCloseAction() {
        self.view.viewWithTag(23)?.removeFromSuperview()
        self.navigationController?.navigationBar.isHidden = false
    }
    
    @objc func handleTapOnVideo(gestureReconizer: CustomTapGesture) {
        print("tapped video")
        print(gestureReconizer.indexPath.row)
        VideoCache.shared.getVideo(videoUrl: allMessages?.array?[gestureReconizer.indexPath.row].video ?? "") { (videoURL) in
            if let videoURL = videoURL {
                DispatchQueue.main.async {
                    try! AVAudioSession.sharedInstance().setCategory(.playback)
                    let player = AVPlayer(url: videoURL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: "please_try_later".localized())
                }
            }
        }
    }
    
    func tappedSendMessageCell(_ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SentMessageTableViewCell
        self.showAlert(title: nil, message: nil, buttonTitle1: "delete".localized(), buttonTitle2: "edit".localized(), buttonTitle3: "cancel".localized(), completion1: {
            self.viewModel?.deleteChatMessages(arrayMessageIds: [cell?.id ?? ""], completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                }
            })
        }, completion2: {
            self.mode = .edit
            self.indexPath = indexPath
            self.inputTextField.text = cell?.messageLabel.text
        }, completion3: nil)
    }
    
    func configureSendMessageTableViewCell(_ cell: SentMessageTableViewCell, _ indexPath: IndexPath, _ tap: UILongPressGestureRecognizer) {
        cell.messageLabel.text = allMessages?.array![indexPath.row].text
        cell.messageLabel.backgroundColor =  UIColor(red: 135/255, green: 192/255, blue: 237/255, alpha: 1)
        cell.id = allMessages!.array![indexPath.row]._id
        cell.messageLabel.textColor = .black
        cell.messageLabel.sizeToFit()
        DispatchQueue.main.async {
            cell.addGestureRecognizer(tap)
        }
        if allMessages?.array![indexPath.row]._id != nil {
            let date = viewModel?.stringToDateD(date: allMessages!.array![indexPath.row].createdAt!)
            let status = allMessages?.statuses![0].userId == SharedConfigs.shared.signedUser?.id ? allMessages?.statuses![1] : allMessages?.statuses![0]
            if date! < viewModel!.stringToDateD(date: status!.receivedMessageDate!)! {
                if date! < viewModel!.stringToDateD(date: status!.readMessageDate!)! || date! == viewModel?.stringToDateD(date: status!.readMessageDate!)! {
                    cell.readMessage.text = "seen".localized()
                } else {
                    cell.readMessage.text = "delivered".localized()
                }
            } else if date! > viewModel!.stringToDateD(date: status!.receivedMessageDate!)! {
                cell.readMessage.text = "sent".localized()
            } else {
                if date! == viewModel?.stringToDateD(date: status!.readMessageDate!)! || date! < viewModel!.stringToDateD(date: status!.readMessageDate!)! {
                    cell.readMessage.text = "seen".localized()
                } else {
                    cell.readMessage.text = "delivered".localized()
                }
            }
        } else {
            cell.readMessage.text = "waiting".localized()
        }
    }
    
    func configureSendCallTableViewCell(_ cell: SentCallTableViewCell, _ indexPath: IndexPath) {
        let tapSendCallTableViewCell = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        cell.callMessageView.addGestureRecognizer(tapSendCallTableViewCell)
        cell.id = allMessages!.array![indexPath.row]._id
        if allMessages?.array![indexPath.row].call?.status == CallStatus.accepted.rawValue {
            cell.ststusLabel.text = CallStatus.outgoing.rawValue.localized()
            cell.durationAndStartTimeLabel.text =  "\(viewModel?.stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!) ?? ""), \(Int(allMessages?.array![indexPath.row].call?.duration ?? 0).secondsToHoursMinutesSeconds())"
        } else if allMessages?.array![indexPath.row].call?.status == CallStatus.missed.rawValue.lowercased() {
            cell.ststusLabel.text = "\(CallStatus.outgoing.rawValue)".localized()
            cell.durationAndStartTimeLabel.text = "\(viewModel?.stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!) ?? "")"
        } else {
            cell.ststusLabel.text = "\(CallStatus.outgoing.rawValue)".localized()
            cell.durationAndStartTimeLabel.text = "\(viewModel?.stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!) ?? "")"
        }
    }
    
    func configureSendImageMessageTableViewCell(_ cell: SentMediaMessageTableViewCell, _ indexPath: IndexPath, _ tap: UILongPressGestureRecognizer) {
        cell.id = allMessages!.array![indexPath.row]._id
        ImageCache.shared.getImage(url: allMessages?.array?[indexPath.row].image?.imageURL ?? "", id: allMessages?.array?[indexPath.row]._id ?? "", isChannel: false) { (image) in
            DispatchQueue.main.async {
                cell.messageLabel.text = self.allMessages?.array?[indexPath.row].text
                cell.addGestureRecognizer(tap)
                cell.snedImageView.image = image
            }
        }
    }
    
    func configureSendVideoMessageTableViewCell(_ cell: SentMediaMessageTableViewCell, _ indexPath: IndexPath, _ tap: UILongPressGestureRecognizer) {
        cell.id = allMessages!.array![indexPath.row]._id
        ImageCache.shared.getThumbnail(videoUrl: allMessages?.array?[indexPath.row].video ?? "", messageId: allMessages?.array?[indexPath.row]._id ?? "") { (image) in
            DispatchQueue.main.async {
                cell.messageLabel.text = self.allMessages?.array?[indexPath.row].text
                cell.addGestureRecognizer(tap)
                cell.snedImageView.image = image
            }
        }
    }
    
    func configureRecieveVideoMessageTableViewCell(_ indexPath: IndexPath, _ cell: RecievedMediaMessageTableViewCell, _ tap: UILongPressGestureRecognizer) {
        ImageCache.shared.getThumbnail(videoUrl: allMessages?.array?[indexPath.row].video ?? "", messageId: allMessages?.array?[indexPath.row]._id ?? "") { (image) in
            DispatchQueue.main.async {
                cell.messageLabel.text = self.allMessages?.array?[indexPath.row].text
                cell.addGestureRecognizer(tap)
                cell.sendImageView.image = image
            }
        }
    }
    
    func configureRecieveCallTableViewCell(_ cell: RecievedCallTableViewCell, _ indexPath: IndexPath) {
        let tapSendCallTableViewCell = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        cell.cellMessageView.addGestureRecognizer(tapSendCallTableViewCell)
        cell.userImageView.image = image
        if allMessages?.array![indexPath.row].call?.status == CallStatus.accepted.rawValue {
            cell.arrowImageView.tintColor = UIColor(red: 48/255, green: 121/255, blue: 255/255, alpha: 1)
            cell.statusLabel.text = CallStatus.incoming.rawValue.localized()
            cell.durationAndStartCallLabel.text = "\(viewModel?.stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!) ?? ""), \(Int(allMessages?.array![indexPath.row].call?.duration ?? 0).secondsToHoursMinutesSeconds())"
        } else if allMessages?.array![indexPath.row].call?.status == CallStatus.missed.rawValue.lowercased() {
            cell.arrowImageView.tintColor = .red
            cell.statusLabel.text = "\(CallStatus.missed.rawValue)_call".localized()
            cell.durationAndStartCallLabel.text = "\(viewModel?.stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!) ?? "")"
        } else  {
            cell.arrowImageView.tintColor = .red
            cell.statusLabel.text = "\(CallStatus.cancelled.rawValue)_call".localized()
            cell.durationAndStartCallLabel.text = "\(viewModel?.stringToDate(date: (allMessages?.array![indexPath.row].call?.callSuggestTime)!) ?? "")"
        }
    }
    
    func configureRecieveImageMessageTableViewCell(_ indexPath: IndexPath, _ cell: RecievedMediaMessageTableViewCell, _ tap: UILongPressGestureRecognizer) {
        ImageCache.shared.getImage(url: allMessages?.array?[indexPath.row].image?.imageURL ?? "", id: allMessages?.array?[indexPath.row]._id ?? "", isChannel: false) { (image) in
            DispatchQueue.main.async {
                cell.messageLabel.text = self.allMessages?.array?[indexPath.row].text
                cell.addGestureRecognizer(tap)
                cell.sendImageView.image = image
            }
        }
    }
    
    func configureRecieveMessageTableViewCell(_ cell: RecievedMessageTableViewCell, _ tap: UILongPressGestureRecognizer, _ indexPath: IndexPath) {
        DispatchQueue.main.async {
            cell.addGestureRecognizer(tap)
        }
        cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
        cell.userImageView.image = image
        cell.messageLabel.text = allMessages?.array![indexPath.row].text
        cell.messageLabel.sizeToFit()
    }
    
    func tappedSendImageMessageCell(_ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SentMediaMessageTableViewCell
        self.showAlert(title: nil, message: nil, buttonTitle1: "delete".localized(), buttonTitle2: "cancel".localized(), buttonTitle3: nil, completion1: {
            self.viewModel?.deleteChatMessages(arrayMessageIds: [cell?.id ?? ""], completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                }
            })
        }, completion2: nil, completion3: nil)
    }
    
    func tappedSendCallCell(_ indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as? SentCallTableViewCell
        self.showAlert(title: nil, message: nil, buttonTitle1: "delete".localized(), buttonTitle2: "cancel".localized(), buttonTitle3: nil, completion1: {
            self.viewModel?.deleteChatMessages(arrayMessageIds: [cell?.id ?? ""], completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                }
            })
        }, completion2: nil, completion3: nil)
    }
    
    @objc func handleTap1(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureReconizer.location(in: tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                if allMessages!.array![indexPath.row].type == "text" {
                    tappedSendMessageCell(indexPath)
                } else if allMessages!.array![indexPath.row].type == "image" {
                    tappedSendImageMessageCell(indexPath)
                } else {
                    tappedSendCallCell(indexPath)
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
        let size: CGSize?
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if (allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id) {
            size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: allMessages?.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            if allMessages?.array![indexPath.row].type == "text" {
                return frame.height + 30 + 22
            }  else if allMessages?.array![indexPath.row].type == "call" {
                return 80
            } else if allMessages?.array![indexPath.row].type == "image" || allMessages?.array![indexPath.row].type == "video" {
                return frame.height + 230
            }
        } else {
            size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: allMessages?.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            if allMessages?.array![indexPath.row].type == "text" {
                return frame.height + 30
            } else if allMessages?.array![indexPath.row].type == "call" {
                return 80
            } else if allMessages?.array![indexPath.row].type == "image" || allMessages?.array![indexPath.row].type == "video" {
                return frame.height  + 30 + 200//UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap1(gestureReconizer:)))
        let tapOnImage = CustomTapGesture(target: self, action: #selector(handleTapOnImage), indexPath: indexPath)
        let tapOnVideo = CustomTapGesture(target: self, action: #selector(handleTapOnVideo), indexPath: indexPath)
        if allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            if allMessages?.array![indexPath.row].type == "text" {
                let cell = tableView.dequeueReusableCell(withIdentifier: Self.sendMessageCellIdentifier, for: indexPath) as! SentMessageTableViewCell
                configureSendMessageTableViewCell(cell, indexPath, tap)
                return cell
            } else if allMessages?.array![indexPath.row].type == "call" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendCallCell", for: indexPath) as! SentCallTableViewCell
                configureSendCallTableViewCell(cell, indexPath)
                return cell
            } else if allMessages?.array![indexPath.row].type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SentMediaMessageTableViewCell
                cell.snedImageView.addGestureRecognizer(tapOnImage)
                cell.snedImageView.isUserInteractionEnabled = true
                configureSendImageMessageTableViewCell(cell, indexPath, tap)
                return cell
            } else if allMessages?.array![indexPath.row].type == "video" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SentMediaMessageTableViewCell
                cell.snedImageView.image = nil
                cell.setStartVideoImage(type: "video")
                configureSendVideoMessageTableViewCell(cell, indexPath, tap)
                cell.snedImageView.isUserInteractionEnabled = true
                cell.snedImageView.addGestureRecognizer(tapOnVideo)
                return cell
            }
        } else {
            if allMessages?.array![indexPath.row].type == "text" {
                let cell = tableView.dequeueReusableCell(withIdentifier: Self.receiveMessageCellIdentifier, for: indexPath) as! RecievedMessageTableViewCell
                configureRecieveMessageTableViewCell(cell, tap, indexPath)
                return cell
            }  else if allMessages?.array![indexPath.row].type == "call" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveCallCell", for: indexPath) as! RecievedCallTableViewCell
                configureRecieveCallTableViewCell(cell, indexPath)
                return cell
            } else if allMessages?.array![indexPath.row].type == "image" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveImageMessage", for: indexPath) as! RecievedMediaMessageTableViewCell
                configureRecieveImageMessageTableViewCell(indexPath, cell, tap)
                cell.setStartVideoImage(type: (self.allMessages?.array![indexPath.row].type) ?? "")
                cell.sendImageView.isUserInteractionEnabled = true
                cell.sendImageView.addGestureRecognizer(tapOnImage)
                return cell
            } else if allMessages?.array![indexPath.row].type == "video" {
                let cell = tableView.dequeueReusableCell(withIdentifier: "receiveImageMessage", for: indexPath) as! RecievedMediaMessageTableViewCell
                cell.sendImageView.image = nil
                cell.setStartVideoImage(type: "video")
                configureRecieveVideoMessageTableViewCell(indexPath, cell, tap)
                cell.sendImageView.addGestureRecognizer(tapOnVideo)
                cell.sendImageView.isUserInteractionEnabled = true
                return cell
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

fileprivate func convertToOptionalNSAttributedStringKeyDictionary(_ input: [String: Any]?) -> [NSAttributedString.Key: Any]? {
    guard let input = input else { return nil }
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (NSAttributedString.Key(rawValue: key), value)})
}

fileprivate func convertFromNSAttributedStringKey(_ input: NSAttributedString.Key) -> String {
    return input.rawValue
}
