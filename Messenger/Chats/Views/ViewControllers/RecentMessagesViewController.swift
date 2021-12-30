//
//  RecentMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class RecentMessagesViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    static let cellID = "messageCell"
    var chats: [Chat] = []
    var isLoaded: Bool = false
    var viewModel: RecentMessagesViewModel?
    var isLoadedMessages: Bool = false
    let refreshControl = UIRefreshControl()
    var timer: Timer?
    var mainRouter: MainRouter?
    //    var spinner = UIActivityIndicatorView(style: .medium)
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        let nc = (self.tabBarController?.viewControllers?[3]) as? UINavigationController
        let vc = nc?.viewControllers[0] as! ProfileViewController
        vc.delegate = self
        vc.profileDelegate = self
        getChats(isFromHome: false)
        self.navigationController?.navigationBar.topItem?.title = "chats".localized()
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        timer?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(getOnlineUsers), userInfo: nil, repeats: true)
        navigationController?.navigationBar.isHidden = false
        let tabbar = self.tabBarController as? MainTabBarController
        if let tabItems = tabbar?.tabBar.items {
            let tabItem = tabItems[1]
            let count = SharedConfigs.shared.unreadMessages.count
            tabItem.badgeValue = count > 0 ? "\(count)" : nil
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isLoadedMessages && chats.count == 0 {
            setView("you_have_no_messages".localized())
        }
    }
    
    //MARK: Helper methods
    @objc func refreshData() {
        isLoadedMessages = false
        getChats(isFromHome: false)
    }
    
    func onlineUsers() {
        if isLoadedMessages {
            let ids = self.chats.map { (chat) -> String in
                return chat.id
            }
            self.viewModel!.onlineUsers(arrayOfId: ids) { (onlineUsers, error) in
                if onlineUsers != nil {
                    for i in 0..<self.chats.count {
                        if onlineUsers!.usersOnline.contains(self.chats[i].id) {
                            self.chats[i].online = true
                        } else {
                            self.chats[i].online = false
                        }
                    }
                    self.sort()
                    DispatchQueue.main.async {
                        self.removeView()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    @objc func getOnlineUsers() {
        onlineUsers()
    }
    
    @objc func addButtonTapped() {
        mainRouter?.showContactsViewControllerFromRecent()
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<chats.count {
            for j in i..<chats.count {
                guard chats[i].message != nil, chats[j].message != nil else {
                    break
                }
                let firstDate = formatter.date(from: chats[i].message!.createdAt ?? "")
                let secondDate = formatter.date(from: chats[j].message!.createdAt ?? "")
                if firstDate?.compare(secondDate!).rawValue == -1 {
                    let temp = chats[i]
                    chats[i] = chats[j]
                    chats[j] = temp
                }
            }
        }
    }
    
    func handleMessageEdited(chatId: String, message: Message) {
        for i in 0..<self.chats.count {
            if self.chats[i].id == chatId && chats[i].message?._id == message._id {
                self.chats[i].message = message
                self.tableView.beginUpdates()
                (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? RecentMessageTableViewCell)?.configure(chat: chats[i])
                self.tableView.endUpdates()
            }
        }
    }
    
    func handleRead(id: String) {
        for i in 0..<chats.count {
            if chats[i].id == id {
                chats[i].unreadMessageExists = false
                SharedConfigs.shared.unreadMessages = SharedConfigs.shared.unreadMessages.filter({ (chat) -> Bool in
                    return chat.id != id
                })
                mainRouter?.notificationListViewController?.reloadData()
                if mainRouter?.notificationDetailViewController?.type == CellType.message {
                    mainRouter?.notificationDetailViewController?.tableView?.reloadData()
                }
                tabBarController?.tabBar.items![1].badgeValue = SharedConfigs.shared.unreadMessages.count > 0 ? "\(SharedConfigs.shared.unreadMessages.count)" : nil
                let regularAttribute = [
                    NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14.0)
                ]
                let regularText = NSAttributedString(string: (chats[i].message?.text) ?? "Call", attributes: regularAttribute)
                (tableView?.cellForRow(at: IndexPath(row: i, section: 0)) as? RecentMessageTableViewCell)?.lastMessageLabel.attributedText = regularText
                (tableView?.cellForRow(at: IndexPath(row: i, section: 0)) as? RecentMessageTableViewCell)?.lastMessageLabel.textColor = .darkGray
            }
        }
    }
    
    func setView(_ str: String) {
        DispatchQueue.main.async {
            self.removeView()
            let noResultView = UIView(frame: self.view.frame)
            noResultView.tag = 26
            noResultView.backgroundColor = UIColor.inputColor
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height))
            label.center = noResultView.center
            label.text = str
            label.textColor = .lightGray
            label.textAlignment = .center
            noResultView.addSubview(label)
            self.view.addSubview(noResultView)
        }
    }
    
    func removeView() {
        DispatchQueue.main.async {
            let resultView = self.view.viewWithTag(26)
            resultView?.removeFromSuperview()
        }
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
            return ("\(day).0\(month)")
        }
        let hour = calendar.component(.hour, from: parsedDate!)
        let minutes = calendar.component(.minute, from: parsedDate!)
        return ("\(hour):\(minutes)")
    }
    
    func requestChats(_ isFromHome: Bool) {
        viewModel!.getChats { (messages, error) in
            if messages?.array != nil {
                SharedConfigs.shared.unreadMessages = []
                for chat in messages!.array! {
                    if chat.unreadMessageExists {
                        SharedConfigs.shared.unreadMessages.append(chat)
                    }
                }
            }
            DispatchQueue.main.async {
                let tabbar = self.tabBarController as? MainTabBarController
                let nc = tabbar?.viewControllers?[3] as? UINavigationController
                let profile = nc?.viewControllers[0] as? ProfileViewController
                profile?.changeNotificationNumber()
                if let tabItems = tabbar?.tabBar.items {
                    let tabItem = tabItems[1]
                    let count = SharedConfigs.shared.unreadMessages.count
                    tabItem.badgeValue = count > 0 ? "\(count)" : nil
                }
            }
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else {
                if (messages?.array != nil) {
                    self.isLoadedMessages = true
                    if messages?.array?.count == 0 {
                        self.setView("you_have_no_messages".localized())
                        DispatchQueue.main.async {
                        }
                    } else {
                        self.chats = messages!.array!.filter({ (chat) -> Bool in
                            return chat.message != nil
                        })
                        self.sort()
                        if !isFromHome {
                            DispatchQueue.main.async {
                                self.removeView()
                                self.tableView.reloadData()
                            }
                        }
                    }
                    DispatchQueue.main.async {
                        self.refreshControl.endRefreshing()
                    }
                }
            }
        }
    }
    
    func getChats(isFromHome: Bool) {
        self.isLoaded = true
        if isLoadedMessages == false {
            DispatchQueue.main.async {
            }
        }
        if !isLoadedMessages {
            requestChats(isFromHome)
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
    
    func handleMessageDelete(messages: [Message]) {
        requestChats(false)
        let chatId = messages[0].senderId == SharedConfigs.shared.signedUser?.id ? messages[0].reciever : messages[0].senderId
        viewModel?.getChatMessages(id: chatId!, dateUntil: nil, completion: { [self] (messages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else {
                for i in 0..<self.chats.count {
                    if (messages?.array?.count) ?? 0 > 0 {
                        if chatId == self.chats[i].id   {
                            DispatchQueue.main.async {
                                let lastMessage = messages!.array![messages!.array!.count - 1]
                                let cell = self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? RecentMessageTableViewCell
                                chats[i].message = lastMessage
                                if lastMessage.senderId == SharedConfigs.shared.signedUser?.id {
                                    chats[i].unreadMessageExists = false
                                } else {
                                    let createdAt = stringToDateD(date: lastMessage.createdAt ?? "")
                                    let status = chats[i].statuses?[0].userId == SharedConfigs.shared.signedUser?.id ? chats[i].statuses?[1] : chats[i].statuses?[0]
                                    let readDate = stringToDateD(date: status?.readMessageDate ?? "")
                                    if readDate != nil {
                                        if createdAt! <= readDate! {
                                            chats[i].unreadMessageExists = false
                                        } else {
                                            chats[i].unreadMessageExists = true
                                        }
                                    }
                                }
                                cell?.configure(chat: chats[i])
                            }
                        }
                    }
                    else if messages?.array?.count == 0 && chatId == chats[i].id {
                        DispatchQueue.main.async {
                            self.chats.remove(at: i)
                            if chats.count == 0 {
                                self.setView("you_have_no_messages".localized())
                            }
                            tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                        }
                    }
                }
            }
        })
    }
    
    func getnewMessage(callHistory: CallHistory?, message: Message, _ name: String?, _ lastname: String?, _ username: String?, uuid: String?) {
        var id = ""
        if message.senderId == SharedConfigs.shared.signedUser?.id {
            id = message.reciever ?? ""
        } else {
            id = (message.senderId ?? "") as String
        }
        self.viewModel!.getuserById(id: id) { (user, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if user != nil {
                DispatchQueue.main.async {
                    self.removeView()
                    let visibleViewController = self.navigationController?.visibleViewController
                    if visibleViewController is ChatViewController && message.reciever != SharedConfigs.shared.signedUser?.id {
                        let chatViewController = visibleViewController as! ChatViewController
                        chatViewController.getnewMessage(callHistory: callHistory, message: message, name, lastname, username, uuid: uuid)
                    }
                }
                for i in 0..<self.chats.count {
                    var isUnreadMessage = false
                    if self.chats[i].id == id {
                        if callHistory != nil {
                            isUnreadMessage = self.chats[i].unreadMessageExists
                        } else {
                            isUnreadMessage = true
                        }
                        self.chats[i] = Chat(id: id, name: user!.name, lastname: user!.lastname, username: user!.username, message: message, recipientAvatarURL: user!.avatarURL, online: true, statuses: nil, unreadMessageExists: isUnreadMessage)
                        self.sort()
                        self.onlineUsers()
                        return
                    }
                }
                self.chats.append(Chat(id: id, name: user!.name, lastname: user!.lastname, username: user!.username, message: message, recipientAvatarURL: user?.avatarURL, online: true, statuses: nil, unreadMessageExists: !(callHistory != nil) && message.senderId != SharedConfigs.shared.signedUser?.id))
                self.sort()
                SharedConfigs.shared.unreadMessages = self.chats.filter({ (chat) -> Bool in
                    return chat.unreadMessageExists
                })
                if self.mainRouter?.notificationDetailViewController?.type == CellType.message {
                    DispatchQueue.main.async {
                        self.mainRouter?.notificationDetailViewController?.tableView?.reloadData()
                    }
                }
                self.onlineUsers()
            }
        }
    }
}

//MARK: Extension
extension RecentMessagesViewController: UITableViewDelegate, UITableViewDataSource, ProfileViewControllerDelegate, UNUserNotificationCenterDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainRouter?.showChatViewController(name: chats[indexPath.row].name, id: chats[indexPath.row].id, avatarURL: chats[indexPath.row].recipientAvatarURL, username: chats[indexPath.row].username)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        removeView()
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! RecentMessageTableViewCell
        cell.isOnline = chats[indexPath.row].online
        cell.configure(chat: chats[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func changeLanguage(key: String) {
        self.navigationController?.navigationBar.topItem?.title = "chats".localized()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension RecentMessagesViewController: ProfileViewDelegate {
    func changeMode() {
        tableView?.reloadData()
    }
}
