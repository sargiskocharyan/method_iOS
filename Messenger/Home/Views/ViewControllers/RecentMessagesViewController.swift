//
//  RecentMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class RecentMessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    static let cellID = "messageCell"
    var chats: [Chat] = []
    var isLoaded: Bool = false
    let viewModel = RecentMessagesViewModel()
    let socketTaskManager = SocketTaskManager.shared
    
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getChats()
        self.navigationController?.navigationBar.topItem?.title = "chats".localized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: Helper methods
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<chats.count {
            for j in i..<chats.count {
                guard chats[i].message != nil, chats[j].message != nil else {
                    break
                }
                let firstDate = formatter.date(from: chats[i].message!.createdAt)
                let secondDate = formatter.date(from: chats[j].message!.createdAt)
                if firstDate?.compare(secondDate!).rawValue == -1 {
                    let temp = chats[i]
                    chats[i] = chats[j]
                    chats[j] = temp
                }
            }
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
    
    func getChats() {
        isLoaded = true
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        viewModel.getChats { (messages, error, code) in
            if (error != nil) {
                if code == 401 {
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
                    let alert = UIAlertController(title: "error_message".localized(), message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.activityIndicator.stopAnimating()
                }
            }
            else {
                if (messages != nil) {
                    self.chats = messages!.filter({ (chat) -> Bool in
                        return chat.message != nil
                    })
                    self.sort()
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func getnewMessage(message: Message) {
        var id = ""
        if message.sender.id == SharedConfigs.shared.signedUser?.id {
            id = message.reciever
        } else {
            id = message.sender.id
        }
        self.viewModel.getuserById(id: id) { (user, error, code) in
            if (error != nil) {
                if code == 401 {
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
                    let alert = UIAlertController(title: "error_message".localized(), message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.activityIndicator.stopAnimating()
                }
            } else if user != nil {
                //Ero trial
                DispatchQueue.main.async {
                    let visibleViewController = self.navigationController?.visibleViewController
                    if visibleViewController is ChatViewController {
                        let chatViewController = visibleViewController as! ChatViewController
//                        if chatViewController.id == message.sender.id || chatViewController.id == message.reciever {
                            chatViewController.getnewMessage( message: message)
//                        }
                    }
                }
                for i in 0..<self.chats.count {
                    if self.chats[i].id == id {
                        print(self.chats[i])
                        self.chats[i] = Chat(id: id, name: user!.name, lastname: user!.lastname, username: user!.username, message: message)
                        self.sort()
                        DispatchQueue.main.async {
                            self.tableView?.reloadData()
                        }
                        return
                    }
                }
                self.chats.append(Chat(id: id, name: user!.name, lastname: user!.lastname, username: user!.username, message: message))
                self.sort()
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                    }
                
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
        vc.id = chats[indexPath.row].id
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellID, for: indexPath) as! RecentMessageTableViewCell
        if chats[indexPath.row].name != nil && chats[indexPath.row].lastname != nil {
            cell.nameLabel.text = "\(chats[indexPath.row].name!) \(chats[indexPath.row].lastname!)"
        } else {
            cell.nameLabel.text = chats[indexPath.row].username
        }
        if chats[indexPath.row].message != nil {
            cell.timeLabel.text = stringToDate(date: chats[indexPath.row].message!.createdAt )
        }
        
        cell.lastMessageLabel.text = chats[indexPath.row].message?.text
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
