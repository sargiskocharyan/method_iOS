//
//  ChannelMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelMessagesViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak var nameOfChannelButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var viewModel: ChannelMessagesViewModel?
    var channelMessages: ChannelMessages?
    var channel: Channel?
    
    //MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        getChannelMessages()
        nameOfChannelButton.setTitle(channel?.name, for: .normal)
        joinButton.setTitle("join".localized(), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        if SharedConfigs.shared.signedUser?.channels?.contains(channel!._id) == true {
            joinButton.isHidden = true
        }
    }
    
    //MARK: Helper methods
    @IBAction func nameOfChannelButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.mainRouter?.showAdminInfoViewController(channel: self.channel!)
        }
    }

    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func joinChannelButtonAction(_ sender: Any) {
        viewModel?.subscribeToChannel(id: channel!._id, completion: { (subResponse, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else {
                DispatchQueue.main.async {
                    self.joinButton.isHidden = true
                }
                SharedConfigs.shared.signedUser?.channels?.append(self.channel!._id)
            }
        })
    }

    func getChannelMessages() {
        viewModel?.getChannelMessages(id: channel!._id, dateUntil: "", completion: { (messages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
                
            } else if messages != nil {
                self.channelMessages = messages
            }
        })
    }
    
}

//MARK: Extensions
extension ChannelMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if channelMessages != nil && channelMessages!.array != nil {
            return channelMessages!.array!.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if channelMessages!.array![0].reciever == SharedConfigs.shared.signedUser?.id {
            let cell = tableView.dequeueReusableCell(withIdentifier: "sendMessageCell", for: indexPath) as! SendMessageTableViewCell
            cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.messageLabel.text = channelMessages!.array![indexPath.row].text
            cell.messageLabel.sizeToFit()
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as! RecieveMessageTableViewCell
            cell.messageLabel.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
            cell.messageLabel.backgroundColor = UIColor.lightGray.withAlphaComponent(0.2)
            cell.messageLabel.text = channelMessages!.array![indexPath.row].text
            cell.messageLabel.sizeToFit()
            return cell
        }
    }
    
    
}

