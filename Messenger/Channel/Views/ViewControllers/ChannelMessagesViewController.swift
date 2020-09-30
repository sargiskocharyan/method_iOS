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
//        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #(addButtonTapped))
        
        joinButton.setTitle("join".localized(), for: .normal)
    }
    
    //MARK: Helper methods
    @IBAction func nameOfChannelButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            self.mainRouter?.showChannelInfoViewController(channel: self.channel!)
        }
    }
    


    @IBAction func joinChannelButtonAction(_ sender: Any) {
        viewModel?.subscribeToChannel(id: channel!._id, completion: { (subResponse, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else {
                self.joinButton.setTitle("", for: .normal)
            }
        })
    }
//
//    func setView(_ str: String) {
//         DispatchQueue.main.async {
//             let noResultView = UIView()
//            self.view.addSubview(noResultView)
//            noResultView.translatesAutoresizingMaskIntoConstraints = false
//            noResultView.topAnchor.constraint(equalTo: self.headerView.bottomAnchor, constant: 100).isActive = true
//            noResultView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 0).isActive = true
//            noResultView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: 0).isActive = true
//            noResultView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0).isActive = true
//             noResultView.tag = 24
//             noResultView.backgroundColor = UIColor(named: "imputColor")
//             let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height))
//             label.center = noResultView.center
//             label.text = str
//             label.textColor = .lightGray
//             label.textAlignment = .center
//             noResultView.addSubview(label)
//
//         }
//     }
    
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

