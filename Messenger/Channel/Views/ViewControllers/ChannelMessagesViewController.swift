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
    @IBOutlet weak var universalButton: UIButton!
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
    var arrayOfSelectedMesssgae: [Message] = []
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
        isPreview = true
        addConstraints()
        setupInputComponents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        nameOfChannelButton.setTitle(channelInfo?.channel?.name, for: .normal)
        if SharedConfigs.shared.signedUser?.channels?.contains(channelInfo!.channel!._id) == true {
            //joinButton.isHidden = true
            if channelInfo?.role == 0 || channelInfo?.role == 1 {
                check = true
                universalButton.isHidden = false
                universalButton.setTitle("edit".localized(), for: .normal)
                
            } else {
                check = false
                universalButton.isHidden = true
            }
        } else {
            universalButton.setTitle("join".localized(), for: .normal)
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
        inputTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
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
        messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        messageInputContainerView.isUserInteractionEnabled = true
        view.addConstraintsWithFormat("H:|[v0]|", views: messageInputContainerView)
        view.addConstraintsWithFormat("V:[v0(48)]", views: messageInputContainerView)
        tableViewBottomConstraint.constant = 55
        sendButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
    }
    
    func getnewMessage(message: Message, _ name: String?, _ lastname: String?, _ username: String?, isSenderMe: Bool) {
        DispatchQueue.main.async {
            self.channelMessages.array!.append(message)
            self.tableView.insertRows(at: [IndexPath(row: self.channelMessages.array!.count - 1, section: 0)], with: .automatic)
            let indexPath = IndexPath(item: self.channelMessages.array!.count - 1, section: 0)
            self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
            print(self.channelInfo?.role)
            switch self.channelInfo?.role {
            case 0:
                self.mainRouter?.showAdminInfoViewController(channelInfo: self.channelInfo!)
            case 1:
                self.mainRouter?.showModeratorInfoViewController(channelInfo: self.channelInfo!)
            default:
                self.mainRouter?.showChannelInfoViewController(channelInfo: self.channelInfo!)
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

//        viewModel?.subscribeToChannel(id: channelInfo!.channel!._id, completion: { (subResponse, error) in
    @IBAction func universalButtonAction(_ sender: Any) {
        if channelInfo?.role == 3 {
            viewModel?.subscribeToChannel(id: channelInfo!.channel!._id, completion: { (subResponse, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.universalButton.isHidden = true
                        self.mainRouter?.channelListViewController?.channels.append(self.channelInfo!)
                        self.mainRouter?.channelListViewController?.tableView.reloadData()
                    }
                    
                }
            })
        } else if channelInfo?.role == 0 || channelInfo?.role == 1 {
            check = !check
            isPreview = check
            DispatchQueue.main.async {
                       UIView.setAnimationsEnabled(false)
                       //self.tableView.reloadRows(at: arrayOfIndexPath, with: .automatic)
                       self.tableView.beginUpdates()
                       self.tableView.reloadData()
                       self.tableView.endUpdates()
                   }
        }
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
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.joinButton.isHidden = true
//                }
//                SharedConfigs.shared.signedUser?.channels?.append(self.channelInfo!.channel!._id)
//            }
//        })
//        for i in arrayOfIndexPath {
//          let cell = tableView.cellForRow(at: i) as? RecieveMessageTableViewCell
//            cell?.editPage(isPreview: !isPreview!)
//        }
       
    
    
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
                    if self.channelMessages.array!.count > 0 {
                        self.tableView.scrollToRow(at: IndexPath(row: self.channelMessages.array!.count - 1, section: 0), at: .top, animated: false)
                    }
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
          var size: CGSize?
         let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        size = CGSize(width: self.view.frame.width * 0.6 - 100, height: 1500)
        let frame = NSString(string: channelMessages.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
        return frame.height + 30
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.cellForRow(at: indexPath) as? SendMessageTableViewCell
            if cell!.isSelected {
                arrayOfSelectedMesssgae.append(channelMessages.array![indexPath.row])
                cell!.button?.setImage(UIImage.init(systemName: "heckmark.circle.fill"), for: .normal)
            } else {
                arrayOfSelectedMesssgae = arrayOfSelectedMesssgae.filter({ (message) -> Bool in
                    return  message._id != channelMessages.array![indexPath.row]._id
                })
                 cell!.button?.setImage(UIImage.init(systemName: "checkmark.circle"), for: .normal)
            }
        } else {
            let cell = tableView.cellForRow(at: indexPath) as? RecieveMessageTableViewCell
            if cell!.isSelected {
                 arrayOfSelectedMesssgae.append(channelMessages.array![indexPath.row])
                 cell!.button?.setImage(UIImage.init(systemName: "heckmark.circle.fill"), for: .normal)
            } else {
                arrayOfSelectedMesssgae = arrayOfSelectedMesssgae.filter({ (message) -> Bool in
                    return  message._id != channelMessages.array![indexPath.row]._id
                })
                 cell!.button?.setImage(UIImage.init(systemName: "checkmark.circle"), for: .normal)
            }
        }
        print("arrayOfSelectedMesssgae:  \(arrayOfSelectedMesssgae)")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendMessageCell", for: indexPath) as! SendMessageTableViewCell
            // cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor(red: 126/255, green: 192/255, blue: 235/255, alpha: 1)
//            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2) checkmark.circle.fill
            cell.messageLabel.text = channelMessages.array![indexPath.row].text
            cell.messageLabel.sizeToFit()
            if  (channelInfo?.role == 0 || channelInfo?.role == 1) {
                if isPreview == true {
                    cell.leadingConstraintOfButton!.constant = -10
                    tableView.allowsMultipleSelection = false
                    cell.button?.isHidden = true
                } else if isPreview == false {
                    cell.leadingConstraintOfButton!.constant = 10
                    tableView.allowsMultipleSelection = true
                    cell.button?.isHidden = false
                }
            } else {
                 cell.button?.isHidden = true
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
            // cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            
            cell.messageLabel.text = channelMessages.array![indexPath.row].text
            cell.messageLabel.sizeToFit()
            if (channelInfo?.role == 0 || channelInfo?.role == 1) {
                if isPreview == true {
                    cell.leadingConstraintOfButton!.constant = -10
                    cell.leadingConstraintOfImageView!.constant = -5
                    cell.button.isHidden = true
                } else if isPreview == false {
                    cell.leadingConstraintOfButton!.constant = 10
                    cell.leadingConstraintOfImageView!.constant = 15
                    cell.button.isHidden = false
                }
            } else {
                cell.button.isHidden = true
            }
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
