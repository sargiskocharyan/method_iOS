//
//  ModeratorListViewController.swift
//  Messenger
//
//  Created by Employee3 on 10/2/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ModeratorListViewController: UIViewController {

    var viewModel: ChannelInfoViewModel?
    var mainRouter: MainRouter?
    var id: String?
    var moderators: [ChannelSubscriber] = []
    var isChangeAdmin: Bool?
    var isLoaded = false
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        getModerators()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isChangeAdmin == false {
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        }
        if self.moderators.count > 0 && self.isLoaded {
            self.removeLabel()
        }
    }
       
    @objc func addButtonTapped() {
        mainRouter?.showSubscribersListViewControllerFromModeratorList(id: id!)
    }
    
    func getModerators() {
        viewModel?.getModerators(id: id!, completion: { (moderators, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if moderators != nil {
                self.isLoaded = true
                self.moderators = moderators!.filter({ (channelSubscriber) -> Bool in
                    return channelSubscriber.user?._id != SharedConfigs.shared.signedUser?.id
                })
                DispatchQueue.main.async {
                    if self.moderators.count == 0 {
                        self.setLabel(text: "no_moderator".localized())
                    } else {
                        self.tableView.reloadData()
                    }
                }
            }
        })
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

extension ModeratorListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moderators.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isChangeAdmin == true {
            let alert = UIAlertController(title: "you_are_going_to_change_admin".localized(), message: "are_you_sure".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action) in
                self.viewModel?.changeAdmin(id: self.id!, userId: (self.moderators[indexPath.row].user?._id)!, completion: { (error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.navigationController?.popToRootViewController(animated: true)
                            for i in 0..<(self.mainRouter?.channelListViewController?.channelsInfo.count)! {
                                if self.id == self.mainRouter?.channelListViewController?.channelsInfo[i].channel!._id {
                                    self.mainRouter?.channelListViewController?.channelsInfo[i].role = 2
                                    break
                                }
                            }
                            self.mainRouter?.channelListViewController?.channels = (self.mainRouter?.channelListViewController?.channelsInfo)!
                        }
                    }
                })
            }))
            self.present(alert, animated: true)
        } else {
            DispatchQueue.main.async {
                self.mainRouter?.showUserProfileFromModeratorList(id: (self.moderators[indexPath.row].user?._id)!)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        if let user = moderators[indexPath.row].user {
            cell.configure(contact: user)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
//    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        tabbar?.viewModel?.removeCall(id: removedCalls, completion: { (error) in
//            if error != nil {
//                DispatchQueue.main.async {
//                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
//                }
//            } else {
//                DispatchQueue.main.async {
//                    self.viewModel!.deleteItem(id: self.removedCalls, completion: { (error)   in
//                        self.sortedDictionary.remove(at: indexPath.row)
//                        tableView.deleteRows(at: [indexPath], with: .automatic)
//                         tableView.endUpdates()
//                        if self.viewModel!.calls.count == 0 {
//                           self.addNoCallView()
//                        } else {
//                            self.view.viewWithTag(20)?.removeFromSuperview()
//                        }
//                    })
//                }
//            }
//        })
//        viewModel?.removeModerator(id: id!, userId: (moderators[indexPath.row].user?._id)!, completion: { (error) in
//            if error == nil {
//                DispatchQueue.main.async {
//                    self.tableView.beginUpdates()
//                    self.moderators.remove(at: indexPath.row)
//
//                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
//                    self.tableView.endUpdates()
//                    if self.moderators.count == 0 {
//                        self.setLabel(text: "no_moderator".localized())
//                    }
//                }
//            }
//        })
//    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let contextItem = UIContextualAction(style: .destructive, title: "delete".localized()) {  (action, view, boolValue) in
                self.viewModel?.removeModerator(id: self.id!, userId: (self.moderators[indexPath.row].user?._id)!, completion: { (error) in
                    if error == nil {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            self.moderators.remove(at: indexPath.row)
                            self.tableView.deleteRows(at: [indexPath], with: .automatic)
                            self.tableView.endUpdates()
                            if self.moderators.count == 0 {
                                self.setLabel(text: "no_moderator".localized())
                            }
//                            self.tableView.dataSource?.tableView!(self.tableView, commit: .delete, forRowAt: indexPath)
//                            return
                        }
                    }
                })
                
            }
             let swipeActions = UISwipeActionsConfiguration(actions: [contextItem])
            return swipeActions
        }
}
