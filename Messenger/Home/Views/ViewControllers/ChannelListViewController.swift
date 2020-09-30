//
//  ChannelViewController.swift
//  Messenger
//
//  Created by Employee3 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var channels: [Channel] = []
    var viewModel: ChannelListViewModel?
    var mainRouter: MainRouter?
    var foundChannels: [Channel] = []
    var channelsInfo: [Channel] = []
    var text = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
        self.navigationItem.title = "channels".localized()
        getChannels()
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    @objc func handleAlertChange(sender: Any?) {
         let textField = sender as! UITextField
        text = textField.text!
    }
    
    @objc func addButtonTapped() {
        let alert = UIAlertController(title: "create_channel".localized()
            , message: "enet_channel_name".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
           textField.addTarget(self, action: #selector(self.handleAlertChange(sender:)), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "create".localized(), style: .default, handler: { (action) in
            self.viewModel!.createChannel(name: self.text, completion: { (channel, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    print("Channel created")
                    SharedConfigs.shared.signedUser?.channels?.append(channel!._id)
                    self.getChannels()
                }
            })
            
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func getChannels() {
        viewModel?.getChannels(ids: SharedConfigs.shared.signedUser?.channels ?? [], completion: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if let channels = channels {
                self.channels = channels
                self.channelsInfo = channels
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    func findChannels(term: String) {
        viewModel?.findChannels(term: term, completion: { (channels, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if let channels = channels {
                self.foundChannels = channels
                self.channelsInfo = channels
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        })
    }
}

extension ChannelListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as! ChannelListTableViewCell
        cell.configureCell(avatar: channelsInfo[indexPath.row].avatar, name: channelsInfo[indexPath.row].name, id: channelsInfo[indexPath.row]._id)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.mainRouter?.showChannelMessagesViewController(channel: self.channelsInfo[indexPath.row])
        }
        
    }
    
    
}

extension ChannelListViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        print("searchtext is \(searchText)")
        if searchText.count > 2 {
            findChannels(term: searchText)
        } else if searchText.count == 0 {
            channelsInfo = channels
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
}
