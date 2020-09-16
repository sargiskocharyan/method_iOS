//
//  NotificationDetailViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/16/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
enum CellType {
    case contactRequest
    case message
    case missedCall
    case adminMessage
}
class NotificationDetailViewController: UIViewController {
    
    var mainRouter: MainRouter?
    var type: CellType?
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        // Do any additional setup after loading the view.
    }
    

}

extension NotificationDetailViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch type {
        case .contactRequest:
            return 100
        case .missedCall:
            return 76
        case .message:
            return 80
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .contactRequest:
            return SharedConfigs.shared.contactRequests.count
        case .missedCall:
            return SharedConfigs.shared.missedCalls.count
        case .message:
            return SharedConfigs.shared.unreadMessages.count
        default:
            return 0
        }
    }
    
    func getUser(call: CallHistory, _ cell: CallTableViewCell, _ indexPath: Int) {
        mainRouter?.callListViewController?.viewModel!.getuserById(id: cell.calleId!) { (user, error) in
            DispatchQueue.main.async {
                if error != nil {
                    cell.configureCell(contact: User(name: nil, lastname: nil, _id: cell.calleId!, username: nil, avaterURL: nil, email: nil, info: nil, phoneNumber: nil, birthday: nil, address: nil, gender: nil, missedCallHistory: nil), call: call, count: 0)
                } else if user != nil {
                    var newArray = self.mainRouter?.mainTabBarController?.contactsViewModel?.otherContacts
                    newArray?.append(user!)
                    self.mainRouter?.mainTabBarController?.viewModel!.saveOtherContacts(otherContacts: newArray!, completion: { (users, error) in
                        self.mainRouter?.mainTabBarController?.contactsViewModel!.otherContacts = users!
                    })
                    cell.configureCell(contact: user!, call: call, count: 0)
                }
            }
        }
    }
    
    func getUserById(id: String, _ cell: ContactRequestTableViewCell, _ row: Int) {
        mainRouter?.callListViewController?.viewModel!.getuserById(id: id) { (user, error) in
            DispatchQueue.main.async {
                 if error == nil && user != nil {
                    var newArray = self.mainRouter?.mainTabBarController?.contactsViewModel?.otherContacts
                    newArray?.append(user!)
                    self.mainRouter?.mainTabBarController?.viewModel!.saveOtherContacts(otherContacts: newArray!, completion: { (users, error) in
                        self.mainRouter?.mainTabBarController?.contactsViewModel!.otherContacts = users!
                    })
                    cell.configure(user: user!)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .contactRequest:
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! ContactRequestTableViewCell
            var existsInContactList = false
            let otherContactsCount = mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts.count
            
            for i in 0..<otherContactsCount {
                if mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts[i]._id == SharedConfigs.shared.contactRequests[indexPath.row].sender {
                    existsInContactList = true
                    cell.configure(user: mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts[i])
                    break
                }
            }
            if existsInContactList == false {
                getUserById(id: SharedConfigs.shared.contactRequests[indexPath.row].sender, cell, indexPath.row)
            }
            return cell
        case .missedCall:
            let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell
            if let calls = mainRouter?.callListViewController?.viewModel?.calls {
                for call in calls {
                    if call._id == SharedConfigs.shared.missedCalls[indexPath.row] {
                        cell.calleId = call.caller
                        var existsInContactList = false
                        let count = mainRouter!.mainTabBarController!.contactsViewModel!.contacts.count
                        let otherContactsCount = mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts.count
                        for i in 0..<count {
                            if mainRouter!.mainTabBarController!.contactsViewModel!.contacts[i]._id == cell.calleId {
                                existsInContactList = true
                                cell.configureCell(contact: mainRouter!.mainTabBarController!.contactsViewModel!.contacts[i], call: call, count: 0)
                                break
                            }
                        }
                        if existsInContactList == false {
                            for i in 0..<otherContactsCount {
                                if mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts[i]._id == cell.calleId {
                                    existsInContactList = true
                                    cell.configureCell(contact: mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts[i], call: call, count: 0)
                                    break
                                }
                            }
                            if existsInContactList == false {
                                getUser(call: call, cell, indexPath.row)
                            }
                        }
                        cell.delegate = self
                        break
                    }
                }
            }
            return cell
        case .message:
            let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as! RecentMessageTableViewCell
            cell.isOnline = SharedConfigs.shared.unreadMessages[indexPath.row].online
            cell.configure(chat: SharedConfigs.shared.unreadMessages[indexPath.row])
            cell.removeOnlineView()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
}

extension NotificationDetailViewController: CallTableViewDelegate {
    func callSelected(id: String, duration: String, callStartTime: Date?, callStatus: String, type: String, name: String, avatarURL: String, isReceiverWe: Bool) {
        print("exav")
    }
}
