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
         self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
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
                self.moderators = moderators!
//                .filter({ (moderator) -> Bool in
//                    return
//                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
}

extension ModeratorListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return moderators.count
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if isChangeAdmin == true {
            
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
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
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
//                            self.addNoCallView()
//                        } else {
//                            self.view.viewWithTag(20)?.removeFromSuperview()
//                        }
//                    })
//                }
//            }
//        })
        viewModel?.removeModerator(id: id!, userId: (moderators[indexPath.row].user?._id)!, completion: { (channel, error) in
            if error == nil {
                DispatchQueue.main.async {
                    self.tableView.beginUpdates()
                    self.moderators.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    self.tableView.endUpdates()
                }
            }
        })
    }
}
