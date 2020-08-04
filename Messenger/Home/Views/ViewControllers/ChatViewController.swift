//
//  ChatViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import SocketIO

class ChatViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var viewModel: ChatMessagesViewModel?
    var id: String?
    var allMessages: [Message] = []
    var bottomConstraint: NSLayoutConstraint?
    var socketTaskManager: SocketTaskManager!
    let center = UNUserNotificationCenter.current()
    var name: String?
    var username: String?
    var avatar: String?
    static let sendMessageCellIdentifier = "sendMessageCell"
    static let receiveMessageCellIdentifier = "receiveMessageCell"
    var image = UIImage(named: "noPhoto")
    var tabbar: MainTabBarController?
    var mainRouter: MainRouter?
    let messageInputContainerView: UIView = {
        let view = UIView()
        if SharedConfigs.shared.mode == "light" {
            view.backgroundColor = .white
        } else {
            view.backgroundColor = .black
        }
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
        socketTaskManager = SocketTaskManager.shared
        inputTextField.placeholder = "enter_message".localized()
        sendButton.setTitle("send".localized(), for: .normal)
        self.navigationItem.rightBarButtonItem = .init(UIBarButtonItem(image: UIImage(systemName: "info.circle"), style: .done, target: self, action: #selector(infoButtonAction)))
        setTitle()
        getImage()
        setObservers()
        activity.tag = 5
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    //MARK: Helper methods
    @objc func infoButtonAction() {
//        let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .main)
//        vc.id = id
//        vc.onContactPage = false
//        vc.fromChat = true
//        for i in 0..<tabbar!.contactsViewModel!.contacts.count {
//            if tabbar!.contactsViewModel!.contacts[i]._id == id {
//                vc.onContactPage = true
//                break
//            }
//        }
        mainRouter?.showContactProfileViewControllerFromChat(id: id!, fromChat: true)
    }
    
    @objc func sendMessage() {
        if inputTextField.text != "" {
            print(socketTaskManager.manager.status)
            socketTaskManager.send(message: inputTextField.text!, id: id!)
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
                    if self.allMessages.count > 0 {
                        let indexPath = IndexPath(item: self.allMessages.count - 1, section: 0)
                        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    
    func getnewMessage(message: Message) {
        if (message.reciever == self.id || message.sender?.id == self.id) &&  message.sender?.id != message.reciever && self.id != SharedConfigs.shared.signedUser?.id {
            if message.reciever == self.id {
                DispatchQueue.main.async {
                    self.inputTextField.text = ""
                }
            }
            self.allMessages.append(message)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = IndexPath(item: self.allMessages.count - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else if self.id == SharedConfigs.shared.signedUser?.id && message.sender?.id == message.reciever  {
            DispatchQueue.main.async {
                self.inputTextField.text = ""
            }
            self.allMessages.append(message)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = IndexPath(item: self.allMessages.count - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
        } else {
            if message.sender?.id != SharedConfigs.shared.signedUser?.id {
                self.scheduleNotification(center: MainTabBarController.center, message: message)
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
        inputTextField.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor, constant: 5).isActive = true
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
    
    func getChatMessages() {
        self.activity.startAnimating()
        viewModel!.getChatMessages(id: id!) { (messages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.view.viewWithTag(5)?.removeFromSuperview()
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if messages != nil {
                self.allMessages = messages!
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.view.viewWithTag(5)?.removeFromSuperview()
                    self.tableView.reloadData()
                    if self.allMessages.count > 0 {
                        let indexPath = IndexPath(item: self.allMessages.count - 1, section: 0)
                        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                }
            }
        }
    }
}

//MARK: Extension
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size: CGSize?
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if (allMessages[indexPath.row].sender?.id == SharedConfigs.shared.signedUser?.id) {
            size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: allMessages[indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            return frame.height + 30
        } else {
            size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: allMessages[indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            return frame.height + 30
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if allMessages[indexPath.row].sender?.id == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.sendMessageCellIdentifier, for: indexPath) as! SendMessageTableViewCell
            cell.messageLabel.text = allMessages[indexPath.row].text
            cell.messageLabel.backgroundColor =  UIColor.blue.withAlphaComponent(0.8)
            cell.messageLabel.textColor = .white
            cell.messageLabel.sizeToFit()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: Self.receiveMessageCellIdentifier, for: indexPath) as! RecieveMessageTableViewCell
            cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.userImageView.image = image
            cell.messageLabel.text = allMessages[indexPath.row].text
            cell.messageLabel.sizeToFit()
            return cell
        }
    }
}
