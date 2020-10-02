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
    
}
