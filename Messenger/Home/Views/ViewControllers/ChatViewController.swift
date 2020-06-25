//
//  ChatViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import SocketIO

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UNUserNotificationCenterDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    //MARK: Properties
    var viewModel = ChatMessagesViewModel()
    var id: String?
    var allMessages: [Message] = []
    var bottomConstraint: NSLayoutConstraint?
    var bottomConstraintOnTableView: NSLayoutConstraint?
    var socketTaskManager: SocketTaskManager!
    let center = UNUserNotificationCenter.current()
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
        addConstraints()
        setupInputComponents()
        setObservers()
        socketTaskManager = SocketTaskManager.shared
        inputTextField.placeholder = "enter_message".localized()
        sendButton.setTitle("send".localized(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
          super.viewWillAppear(animated)
          tabBarController?.tabBar.isHidden = true
      }
    
    //MARK: Helper methods
    @objc func sendMessage() {
        socketTaskManager.send(message: inputTextField.text!, id: id!)
    }
    
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height : 0
            bottomConstraintOnTableView?.constant = isKeyboardShowing ? -keyboardFrame!.height - 48 : 20
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    if self.allMessages.count > 0 {
                        let indexPath = NSIndexPath(item: self.allMessages.count - 1, section: 0)
                        self.tableView?.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    
    func getnewMessage(message: Message) {
        if (message.reciever == self.id || message.sender.id == self.id) &&  message.sender.id != message.reciever && self.id != SharedConfigs.shared.signedUser?.id {
                print(message)
                if message.reciever == self.id {
                    DispatchQueue.main.async {
                        self.inputTextField.text = ""
                    }
                }
                self.allMessages.append(message)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    let indexPath = NSIndexPath(item: self.allMessages.count - 1, section: 0)
                    self.tableView?.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
                }
        } else if self.id == SharedConfigs.shared.signedUser?.id && message.sender.id == message.reciever  {
            DispatchQueue.main.async {
                self.inputTextField.text = ""
            }
            self.allMessages.append(message)
            DispatchQueue.main.async {
                self.tableView.reloadData()
                let indexPath = NSIndexPath(item: self.allMessages.count - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: true)
            }
        } else {
            self.scheduleNotification(center: MainTabBarController.center, message: message)
        }
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }//++
    
    func addConstraints() {
        view.addSubview(messageInputContainerView)
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        bottomConstraint = NSLayoutConstraint(item: messageInputContainerView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -20)
        bottomConstraintOnTableView = NSLayoutConstraint(item: tableView!, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1, constant: -68)
        view.addConstraint(bottomConstraint!)
        view.addConstraint(bottomConstraintOnTableView!)
    }
    
    private func setupInputComponents() {
        let topBorderView = UIView()
        topBorderView.backgroundColor = UIColor(white: 0.5, alpha: 0.5)
        messageInputContainerView.addSubview(inputTextField)
        messageInputContainerView.addSubview(sendButton)
        messageInputContainerView.addSubview(topBorderView)
        messageInputContainerView.addConstraintsWithFormat("H:|-8-[v0][v1(30)]|", views: inputTextField, sendButton)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0]|", views: inputTextField)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(30)]|", views: sendButton)
        messageInputContainerView.addConstraintsWithFormat("H:|[v0]|", views: topBorderView)
        messageInputContainerView.addConstraintsWithFormat("V:|[v0(0.5)]", views: topBorderView)
        view.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .trailing, relatedBy: .equal, toItem: messageInputContainerView, attribute: .trailing, multiplier: 1, constant: -10))
        view.addConstraint(NSLayoutConstraint(item: sendButton, attribute: .centerY, relatedBy: .equal, toItem: messageInputContainerView, attribute: .centerY, multiplier: 1, constant: 0))
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func getChatMessages() {
        self.activity.startAnimating()
        viewModel.getChatMessages(id: id!) { (messages, error) in
            if error != nil {
                if error == NetworkResponse.authenticationError {
                    UserDataController().logOutUser()
                    DispatchQueue.main.async {
                        let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                        let nav = UINavigationController(rootViewController: vc)
                        let window: UIWindow? = UIApplication.shared.windows[0]
                        window?.rootViewController = nav
                        window?.makeKeyAndVisible()
                    }
                }
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else if messages != nil {
                self.allMessages = messages!
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.tableView.reloadData()
                    if self.allMessages.count > 0 {
                        let indexPath = IndexPath(item: self.allMessages.count - 1, section: 0)
                        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allMessages.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var size: CGSize?
        
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if (allMessages[indexPath.row].sender.id == SharedConfigs.shared.signedUser?.id) {
            size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: allMessages[indexPath.row].text).boundingRect(with: size!, options: options, attributes: nil, context: nil)
            return frame.height + 30
        } else {
            size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: allMessages[indexPath.row].text).boundingRect(with: size!, options: options, attributes: nil, context: nil)
            return frame.height + 30
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if allMessages[indexPath.row].sender.id == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendMessageCell", for: indexPath) as! SendMessageTableViewCell
            cell.messageLabel.text = allMessages[indexPath.row].text
            cell.messageLabel.backgroundColor =  UIColor.blue.withAlphaComponent(0.8)
            cell.messageLabel.textColor = .white
            cell.messageLabel.sizeToFit()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
            cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.userImageView.image = UIImage(named: "noPhoto")
            cell.messageLabel.text = allMessages[indexPath.row].text
            cell.messageLabel.sizeToFit()
            return cell
        }
    }
}


