//
//  ChannelMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelMessagesViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak var nameOfChannelButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var viewModel: ChannelMessagesViewModel?
    var channelMessages: ChannelMessages = ChannelMessages(array: [], statuses: [])
    var channelInfo: ChannelInfo?
    var isPreview: Bool?
    var check: Bool!
    var bottomConstraint: NSLayoutConstraint?
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
    
    //MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.getChannelMessages()
        setObservers()
        addConstraints()
        setupInputComponents()
        check = true
        joinButton.setTitle("join".localized(), for: .normal)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        nameOfChannelButton.setTitle(channelInfo?.channel?.name, for: .normal)
        if SharedConfigs.shared.signedUser?.channels?.contains(channelInfo!.channel!._id) == true {
            joinButton.isHidden = true
        }
    }
    
    //MARK: Helper methods
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        inputTextField.translatesAutoresizingMaskIntoConstraints = false
        inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 30).isActive = true
        inputTextField.leftAnchor.constraint(equalTo: messageInputContainerView.leftAnchor, constant: 5).isActive = true
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
    }
    
    func addConstraints() {
        view.addSubview(messageInputContainerView)
        messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        bottomConstraint = messageInputContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0)
        bottomConstraint?.isActive = true
        messageInputContainerView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        messageInputContainerView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        //        messageInputContainerView.addConstraint(bottomConstraint!)
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        messageInputContainerView.isUserInteractionEnabled = true
        
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        tableViewBottomConstraint.constant = 55
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        //        view.addConstraint(bottomConstraint!)
    }
    
    func getnewMessage(message: Message, _ name: String?, _ lastname: String?, _ username: String?, isSenderMe: Bool) {
//        if (message.reciever == self.id || message.senderId == self.id) &&  message.senderId != message.reciever && self.id != SharedConfigs.shared.signedUser?.id {
//            if message.senderId != SharedConfigs.shared.signedUser?.id {
//        if isSenderMe != false {
//                self.channelMessages?.array!.append(message)
//        }
//                if navigationController?.viewControllers.count == 2 {
//                    SocketTaskManager.shared.messageRead(chatId: channel?._id!, messageId: message._id!)
//                }
//            } else {
//                for i in 0..<channelMessages!.array!.count {
//                    if message.text  == allMessages!.array![i].text {
//                        (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SendMessageTableViewCell)?.readMessage.text = "sent"
//                        self.allMessages!.array![i] = message
//                    }
//                }
            //            }
            DispatchQueue.main.async {
              //  self.tableView.reloadData()
                self.channelMessages.array!.append(message)
                self.tableView.insertRows(at: [IndexPath(row: self.channelMessages.array!.count - 1, section: 0)], with: .automatic)
                let indexPath = IndexPath(item: self.channelMessages.array!.count - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            }
//        }
         if message.senderId == SharedConfigs.shared.signedUser?.id  {
//            DispatchQueue.main.async {
//                self.inputTextField.text = ""
//            }
            
//            self.channelMessages?.array!.append(message)
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//                let indexPath = IndexPath(item: (self.channelMessages?.array!.count)! - 1, section: 0)
//                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
//            }
//        } else {
//            if message.senderId != SharedConfigs.shared.signedUser?.id {
//                self.scheduleNotification(center: MainTabBarController.center, nil, message: message, name, lastname, username)
//            }
        }
    }
    
    @objc func sendMessage() {
         if inputTextField.text != "" {
             let text = inputTextField.text
             inputTextField.text = ""
            SocketTaskManager.shared.sendChanMessage(message: text!, channelId: channelInfo!.channel!._id)
             
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
//                  if isKeyboardShowing {
//                      if (self.allMessages?.array != nil && (self.allMessages?.array!.count)! > 1) {
//                          let indexPath = IndexPath(item: (self.allMessages?.array!.count)! - 1, section: 0)
//                          self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
//                      }
//                  }
              })
          }
      }
    
    @IBAction func nameOfChannelButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.mainRouter?.showAdminInfoViewController(channelInfo: self.channelInfo!)
            //            self.mainRouter?.showChannelInfoViewController(channel: self.channel!)
//            self.mainRouter?.showModeratorInfoViewController(channel: self.channel!)
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func joinChannelButtonAction(_ sender: Any) {
        viewModel?.subscribeToChannel(id: channelInfo!.channel!._id, completion: { (subResponse, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else {
                DispatchQueue.main.async {
                    self.joinButton.isHidden = true
                }
                SharedConfigs.shared.signedUser?.channels?.append(self.channelInfo!.channel!._id)
            }
        })
    }
    
//    func getChannelMessages() {
//        viewModel?.getChannelMessages(id: channelInfo!.channel!._id, dateUntil: "", completion: { (messages, error) in
//            //
//            //        check = !check
//            //        isPreview = check
//            DispatchQueue.main.async {
//                if !self.joinButton.isHidden {
//                    self.viewModel?.subscribeToChannel(id: self.channelInfo!.channel!._id, completion: { (subResponse, error) in
//                        if error != nil {
//                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
//                        } else {
//                            self.joinButton.isHidden = true
//                            SharedConfigs.shared.signedUser?.channels?.append(self.channelInfo!.channel!._id)
//                        }
//                    })
//                }
//            }
//
//        })
//    }
    
//    func getMessages(completion: @escaping () -> ()) {
//        viewModel?.getChatMessages(id: "5f3a7cb9e6d394087cb701e7", dateUntil: nil, completion: { (messages, error) in
//            if error != nil {
//                DispatchQueue.main.async {
//                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
//                    completion()
//                }
//            } else if messages != nil {
//                //                self.channelMessages?.array = messages?.array
//                self.messages = messages!
//                completion()
//            }
//        })
//    }
    
    func getChannelMessages() {
        viewModel?.getChannelMessages(id: self.channelInfo!.channel!._id, dateUntil: "", completion: { (messages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }

            } else if messages != nil {
                self.channelMessages = messages!
                self.channelMessages.array!.reverse()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
}

//MARK: Extensions
extension ChannelMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //        if channelMessages != nil && channelMessages!.array != nil {
        //            return channelMessages!.array!.count
        //        } else {
        //            return 0
        //        }
        return channelMessages.array!.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendMessageCell", for: indexPath) as! SendMessageTableViewCell
            // cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.messageLabel.text = channelMessages.array![indexPath.row].text
            cell.messageLabel.sizeToFit()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
            // cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.messageLabel.text = channelMessages.array![indexPath.row].text
            cell.messageLabel.sizeToFit()
            //            if check! {
            //            cell.editPage(isPreview: isPreview)
            //            if isPreview == true {
            //                cell.leadingConstraintOfButton.constant = -10
            //                cell.leadingConstraintOfImageView.constant = -5
            //                cell.button.isHidden = true
            //            } else if isPreview == false {
            //                cell.leadingConstraintOfButton.constant = 10
            //                cell.leadingConstraintOfImageView.constant = 15
            //                cell.button.isHidden = false
            //            }
            //            if indexPath.row == self.messages!.array!.count - 1 {
            //                isPreview = nil
            //            }
            //              print("isperview:------   \(self.isPreview)")
            //            }
            return cell
        }
    }
}

extension UITableView {
    func reloadData(completion:@escaping ()->()) {
        UIView.animate(withDuration: 0, animations: { self.reloadData() })
        { _ in completion() }
    }
}
