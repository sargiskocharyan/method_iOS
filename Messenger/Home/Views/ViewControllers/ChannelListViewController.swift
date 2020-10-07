//
//  ChannelViewController.swift
//  Messenger
//
//  Created by Employee3 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelListViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARk: Properties
    var channels: [ChannelInfo] = []
    var viewModel: ChannelListViewModel?
    var mainRouter: MainRouter?
    var foundChannels: [ChannelInfo] = []
    var channelsInfo: [ChannelInfo] = []
    var text = ""
    var activity = UIActivityIndicatorView(style: .medium)
    
    //MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        searchBar.delegate = self
        self.navigationItem.title = "channels".localized()
        getChannels()
        setActivity()
        activity.startAnimating()
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (tabBarController?.tabBar.isHidden)! {
            tabBarController?.tabBar.isHidden = false
        }
        if (navigationController?.navigationBar.isHidden)! {
            navigationController?.navigationBar.isHidden = false
        }
    }
    
    //MARK: Helper methods
    @objc func handleAlertChange(sender: Any?) {
         let textField = sender as! UITextField
        text = textField.text!
    }
    
    func setActivity() {
          self.tableView.addSubview(self.activity)
          self.activity.tag = 33
          self.activity.translatesAutoresizingMaskIntoConstraints = false
          self.activity.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
          self.activity.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
          self.activity.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 1).isActive = true
          self.activity.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 1).isActive = true
      }
    
    @objc func addButtonTapped() {
        let alert = UIAlertController(title: "create_channel".localized()
            , message: "enter_channel_name".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
           textField.addTarget(self, action: #selector(self.handleAlertChange(sender:)), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "create".localized(), style: .default, handler: { (action) in
            self.activity.startAnimating()
            self.viewModel!.createChannel(name: self.text, completion: { (channel, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    print("Channel created")
                    SharedConfigs.shared.signedUser?.channels?.append(channel!._id)
                   
                    self.channels.insert(ChannelInfo(channel: channel, role: 0), at: 0)
                    self.channelsInfo = self.channels
                    DispatchQueue.main.async {
                        self.activity.stopAnimating()
                        self.tableView.reloadData()
                    }
                }
            })
            
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
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
                    self.activity.stopAnimating()
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

//MARK: Extensions
extension ChannelListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelsInfo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as! ChannelListTableViewCell
        if channelsInfo.count > indexPath.row {
            cell.configureCell(avatar: channelsInfo[indexPath.row].channel?.avatarURL, name: channelsInfo[indexPath.row].channel!.name, id: channelsInfo[indexPath.row].channel!._id)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            print(self.channelsInfo[indexPath.row])
            self.mainRouter?.showChannelMessagesViewController(channelInfo: self.channelsInfo[indexPath.row])
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
