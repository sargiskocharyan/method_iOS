//
//  SubscribersListViewController.swift
//  Messenger
//
//  Created by Employee1 on 10/2/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SubscribersListViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var viewModel: ChannelInfoViewModel?
    var subscribers: [ChannelSubscriber] = []
    var id: String?
    var isFromModeratorList: Bool?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        getSubscribers()
    }
    
    //MARK: Helper methods
    func getSubscribers() {
        viewModel?.getSubscribers(id: id ?? "", completion: { (subscribers, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if subscribers != nil {
                self.subscribers = subscribers!
                if self.isFromModeratorList == true {
                    self.subscribers = self.subscribers.filter { (channelSubscriber) -> Bool in
                        return channelSubscriber.user?._id != SharedConfigs.shared.signedUser?.id
                    }
                    var i = 0
                    var isModerator = false
                    while i < self.subscribers.count {
                        isModerator = false
                        var j = 0
                        while j < (self.mainRouter?.moderatorListViewController?.moderators.count)! {
                            if i < self.subscribers.count && self.subscribers[i].user?._id == self.mainRouter?.moderatorListViewController?.moderators[j].user?._id {
                                isModerator = true
                                self.subscribers.remove(at: i)
                            }
                            j += 1
                        }
                        if !isModerator {
                            i += 1
                        }
                    }
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
}

//MARK: Extensions
extension SubscribersListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return subscribers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        cell.configure(contact: subscribers[indexPath.row].user!)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isFromModeratorList == true {
            viewModel?.addModerator(id: id!, userId: subscribers[indexPath.row].user?._id ?? "", completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.mainRouter?.moderatorListViewController?.moderators.append(self.subscribers[indexPath.row])
                        self.mainRouter?.moderatorListViewController?.tableView.insertRows(at: [IndexPath(row: (self.mainRouter?.moderatorListViewController?.moderators.count)! - 1, section: 0)], with: .automatic)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let alert = UIAlertController(title: "attention".localized(), message: "are_you_sure_you_want_to_block_subscriber".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
//            self.viewModel?.rejectBeModerator(id: self.channelInfo!.channel!._id, completion: { (error) in
//                if error != nil {
//                    DispatchQueue.main.async {
//                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
//                    }
//                } else {
//                    DispatchQueue.main.async {
//                        self.navigationController?.popToRootViewController(animated: true)
//                        for i in 0..<(self.mainRouter?.channelListViewController?.channelsInfo.count)! {
//                            if self.channelInfo?.channel?._id == self.mainRouter?.channelListViewController?.channelsInfo[i].channel!._id {
//                                self.mainRouter?.channelListViewController?.channelsInfo[i].role = 2
//                                break
//                            }
//                        }
//                        self.mainRouter?.channelListViewController?.channels = (self.mainRouter?.channelListViewController?.channelsInfo)!
//                    }
//                }
//            })
            self.viewModel?.blockSubscribers(id: self.id!, subscribers: [self.subscribers[indexPath.row].user?._id ?? ""], completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    self.subscribers.remove(at: indexPath.row)
                    DispatchQueue.main.async {
                        self.tableView.beginUpdates()
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                        self.tableView.endUpdates()
                    }
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: "block".localized()) { (action, indexPath) in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        }
        deleteButton.backgroundColor = UIColor.red
        return [deleteButton]
    }
    
}
