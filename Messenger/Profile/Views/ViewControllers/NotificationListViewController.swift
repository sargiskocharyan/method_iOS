//
//  NavigationListViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/16/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class NotificationListViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var mainRouter: MainRouter?
    var isSetTextOnContactRequests: Bool?
    var isSetTextOnUnreadMessages: Bool?
    var isSetTextOnMissedCalls: Bool?
    var isSetTextOnAdminMessages: Bool?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "notifications".localized()
        if SharedConfigs.shared.getNumberOfNotifications() == 0 {
            navigationController?.popViewController(animated: false)
        }
    }
    
    //MARK: Helper methods
    func reloadData() {
        isSetTextOnContactRequests  = false
        isSetTextOnUnreadMessages = false
        isSetTextOnMissedCalls = false
        isSetTextOnAdminMessages = false
        tableView?.reloadData()
    }
}

//MARK: Extensions
extension NotificationListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = 0
        if SharedConfigs.shared.missedCalls.count > 0 {
            count += 1
        }
        if SharedConfigs.shared.unreadMessages.count > 0 {
            count += 1
        }
        let receivedRequests = SharedConfigs.shared.contactRequests.filter { (request) -> Bool in
            return SharedConfigs.shared.signedUser?.id == request.receiver
        }
        if receivedRequests.count > 0 {
            count += 1
        }
        if SharedConfigs.shared.adminMessages.count > 0 {
            count += 1
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! NotificationListTableViewCell
        mainRouter?.showNotificationDetailViewController(type: cell.type!)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationListTableViewCell", for: indexPath) as! NotificationListTableViewCell
        let receivedRequests = SharedConfigs.shared.contactRequests.filter { (request) -> Bool in
            return SharedConfigs.shared.signedUser?.id == request.receiver
        }
        if receivedRequests.count > 0 && isSetTextOnContactRequests != true {
            isSetTextOnContactRequests = true
            cell.cellTextLabel.text = "contact_requests".localized()
            cell.notificationCountLabel.text = "\(receivedRequests.count)"
            cell.type = CellType.contactRequest
            return cell
        }
        if SharedConfigs.shared.unreadMessages.count > 0 && isSetTextOnUnreadMessages != true {
            isSetTextOnUnreadMessages = true
            cell.cellTextLabel.text = "unread_messages".localized()
            cell.notificationCountLabel.text = "\(SharedConfigs.shared.unreadMessages.count)"
            cell.type = CellType.message
            return cell
        }
        if SharedConfigs.shared.missedCalls.count > 0 && isSetTextOnMissedCalls != true {
            isSetTextOnMissedCalls = true
            cell.cellTextLabel.text = "missed_calls".localized()
            cell.notificationCountLabel.text = "\(SharedConfigs.shared.missedCalls.count)"
            cell.type = CellType.missedCall
            return cell
        }
        if SharedConfigs.shared.adminMessages.count > 0 && isSetTextOnAdminMessages != true {
            isSetTextOnAdminMessages = true
            cell.type = CellType.adminMessage
            cell.notificationCountLabel.text = "\(SharedConfigs.shared.adminMessages.count)"
            cell.cellTextLabel.text = "admin_messages".localized()
            return cell
        }
        return UITableViewCell()
    }
}
