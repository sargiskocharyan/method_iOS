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
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var type: CellType?
    var tabbar: MainTabBarController?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tabbar = tabBarController as? MainTabBarController
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        configureNavigationBar()
    }
    
    //MARK: Helper methods
    func getUser(call: CallHistory, _ cell: CallTableViewCell, _ indexPath: Int) {
        mainRouter?.callListViewController?.viewModel!.getuserById(id: cell.calleId!) { (user, error) in
            DispatchQueue.main.async {
                if error != nil {
                    cell.configureCell(contact: User(name: nil, lastname: nil, _id: cell.calleId!, username: nil, avaterURL: nil, email: nil, info: nil, phoneNumber: nil, birthday: nil, address: nil, gender: nil, missedCallHistory: nil, channels: nil), call: call, count: 0)
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
    
    func configureNavigationBar() {
        switch type {
        case .adminMessage:
            self.title = "admin_messages".localized()
        case .contactRequest:
            self.title = "contact_requests".localized()
        case .message:
            self.title = "unread_messages".localized()
        default:
            self.title = "missed_calls".localized()
        }
        if (SharedConfigs.shared.unreadMessages.count == 0 && type == CellType.message) || (SharedConfigs.shared.missedCalls.count == 0 && type == CellType.missedCall) || (SharedConfigs.shared.contactRequests.count == 0 && type == CellType.contactRequest) || (SharedConfigs.shared.adminMessages.count == 0 && type == CellType.adminMessage){
            navigationController?.popViewController(animated: false)
        }
    }
    
    func getUserById(id: String, _ cell: ContactRequestTableViewCell, _ row: Int, request: Request) {
        mainRouter?.callListViewController?.viewModel!.getuserById(id: id) { (user, error) in
            DispatchQueue.main.async {
                if error == nil && user != nil {
                    cell.configure(user: user!, request: request, number: row)
                    var newArray = self.mainRouter?.mainTabBarController?.contactsViewModel?.otherContacts
                    newArray?.append(user!)
                    self.mainRouter?.mainTabBarController?.viewModel?.saveOtherContacts(otherContacts: newArray!, completion: { (users, error) in
                        self.mainRouter?.mainTabBarController?.contactsViewModel?.otherContacts = users ?? []
                    })
                }
            }
        }
    }
    
}

//MARK: Extensions
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
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .contactRequest:
            let ourContactRequests = SharedConfigs.shared.contactRequests.filter { (request) -> Bool in
                return request.receiver == SharedConfigs.shared.signedUser?.id
            }
            return ourContactRequests.count
        case .missedCall:
            return SharedConfigs.shared.missedCalls.count
        case .message:
            return SharedConfigs.shared.unreadMessages.count
        default:
            return SharedConfigs.shared.adminMessages.count
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch type {
        case .contactRequest:
            let ourContactRequests = SharedConfigs.shared.contactRequests.filter { (request) -> Bool in
                           return request.receiver == SharedConfigs.shared.signedUser?.id
                       }
            mainRouter?.showContactProfileViewControllerFromNotificationDetail(id: ourContactRequests[indexPath.row].sender)
        case .missedCall:
            let cell = tableView.cellForRow(at: indexPath) as? CallTableViewCell
            tabbar?.handleCallClick(id: (cell?.contact?._id)!, name: cell?.contact?.username ?? "", mode: cell?.call?.type == "audio" ? VideoVCMode.audioCall : VideoVCMode.videoCall)
            tabbar?.viewModel?.checkCallAsSeen(callId: SharedConfigs.shared.missedCalls[indexPath.row], readOne: true, completion: { (error) in
                if error == nil {
                    SharedConfigs.shared.missedCalls.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        tableView.beginUpdates()
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                        tableView.endUpdates()
                    }
                }
            })
        case .message:
            let user = SharedConfigs.shared.unreadMessages[indexPath.row]
            mainRouter?.showChatViewControllerFromNotificationDetail(name: user.name, id: user.id, avatarURL: user.recipientAvatarURL, username: user.username)
            SharedConfigs.shared.unreadMessages.remove(at: indexPath.row)
            DispatchQueue.main.async {
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .automatic)
                tableView.endUpdates()
            }
        default:
            let vc = CustomAlertViewController.instantiate(fromAppStoryboard: .profile)
            vc.adminMessage = SharedConfigs.shared.adminMessages[indexPath.row]
            vc.row = indexPath.row
            vc.mainRouter = mainRouter
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
            alertController.setValue(vc, forKey: "contentViewController")
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch type {
        case .contactRequest:
            let ourContactRequests = SharedConfigs.shared.contactRequests.filter { (request) -> Bool in
                return request.receiver == SharedConfigs.shared.signedUser?.id
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! ContactRequestTableViewCell
            var existsInContactList = false
            let otherContactsCount = mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts.count
            for i in 0..<otherContactsCount {
                if mainRouter!.mainTabBarController!.contactsViewModel!.otherContacts[i]._id == ourContactRequests[indexPath.row].sender {
                    existsInContactList = true
                    cell.configure(user: mainRouter?.mainTabBarController?.contactsViewModel?.otherContacts[i] ?? User(), request: ourContactRequests[indexPath.row], number: indexPath.row)
                    break
                }
            }
            if existsInContactList == false {
                getUserById(id: SharedConfigs.shared.contactRequests[indexPath.row].sender, cell, indexPath.row, request: ourContactRequests[indexPath.row])
            }
            cell.delegate = self
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
            cell.isOnline = false
            cell.configure(chat: SharedConfigs.shared.unreadMessages[indexPath.row])
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: "adminMessageCell", for: indexPath) as! AdminMessageTableViewCell
            cell.configure(adminMessage: SharedConfigs.shared.adminMessages[indexPath.row])
            return cell
        }
    }
    
}

extension NotificationDetailViewController: CallTableViewDelegate {
    func callSelected(id: String, duration: String, callStartTime: Date?, callStatus: String, type: String, name: String, avatarURL: String, isReceiverWe: Bool) {
        var status: CallStatus?
        if callStatus == "missed" {
            status = CallStatus.missed
        } else if callStatus == "accepted" {
            status = CallStatus.accepted
        } else {
            status = CallStatus.cancelled
        }
        mainRouter?.showCallDetailViewController(id: id, name: name, duration: duration, time: callStartTime, callMode: status!, avatarURL: avatarURL, isReceiverWe: true)
    }
}

extension NotificationDetailViewController: ContactRequestTableViewCellDelegate {
    func requestRemoved(number: Int) {
        self.tableView.deleteRows(at: [IndexPath(row: number, section: 0)], with: .automatic)
        mainRouter?.notificationListViewController?.reloadData()
        mainRouter?.notificationDetailViewController?.viewWillAppear(false)
    }
    
    func showAlert(error: NetworkResponse) {
        self.showErrorAlert(title: "error".localized(), errorMessage: error.rawValue)
    }
}
