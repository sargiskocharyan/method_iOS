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
    var isLoaded = false
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        getSubscribers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.isLoaded && self.subscribers.count > 0 {
            self.removeLabel()
        }
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
                    if self.subscribers.count == 0 {
                        self.setLabel(text: "no_subscriber".localized())
                    } else {
                        self.tableView.reloadData()
                    }
                }
            }
        })
    }
    
    func showAlertWhenModeratorAdded() {
        let alert = UIAlertController(title: nil, message: "Successfully added!", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
            self.navigationController?.popViewController(animated: true)
        }))
                 self.present(alert, animated: true)
    }
    
    func setLabel(text: String) {
        let label = UILabel()
        label.text = text
        label.tag = 12
        label.textAlignment = .center
        label.textColor = .darkGray
        self.tableView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func removeLabel() {
        self.view.viewWithTag(12)?.removeFromSuperview()
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
                        self.showAlertWhenModeratorAdded()
                    }
                }
            })
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if subscribers[indexPath.row].user?._id != SharedConfigs.shared.signedUser?.id {
            return true
        } else {
            return false
        }
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
                        if self.subscribers.count == 0 {
                            self.setLabel(text: "no_subscriber".localized())
                        }
                    }
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if subscribers[indexPath.row].user?._id != SharedConfigs.shared.signedUser?.id {
        let deleteButton = UITableViewRowAction(style: .default, title: "block".localized()) { (action, indexPath) in
            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
            return
        }
        deleteButton.backgroundColor = UIColor.red
        return [deleteButton]
        } else {
            return nil
        }
    }
    
}
