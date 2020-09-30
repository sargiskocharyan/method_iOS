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
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var viewModel: ChannelMessagesViewModel?
    var channelMessages: ChannelMessages?
    var id: String?
    
    
    //MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    //MARK: Helper methods
    @IBAction func nameOfChannelButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func joinChannelButtonAction(_ sender: Any) {
        viewModel?.subscribeToChannel(id: id!, completion: { (subResponse, error) in
            if error != nil {
                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
            } else {
                self.joinButton.setTitle("", for: .normal)
            }
        })
    }
    
    func getChannelMessages() {
        viewModel?.getChannelMessages(id: id!, dateUntil: "", completion: { (messages, error) in
            if error != nil {
                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
            } else if messages != nil {
                self.channelMessages = messages
            }
        })
    }
    
}

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

