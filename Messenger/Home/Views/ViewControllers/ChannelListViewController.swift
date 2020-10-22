//
//  ChannelViewController.swift
//  Messenger
//
//  Created by Employee3 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

enum ChannelListMode {
    case search
    case main
}

class ChannelListViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak var tableView: UITableView!
    //    @IBOutlet weak var searchBar: UISearchBar!
    
    //MARk: Properties
    var channels: [ChannelInfo] = []
    var isLoaded: Bool!
    var viewModel: ChannelListViewModel?
    var mainRouter: MainRouter?
    var foundChannels: [ChannelInfo] = []
    var channelsInfo: [ChannelInfo] = []
    var text = ""
    var mode = ChannelListMode.main
    var activity = UIActivityIndicatorView(style: .medium)
    let refreshControl = UIRefreshControl()
    let searchController = UISearchController(searchResultsController: nil)
    
    //MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        isLoaded = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
        self.navigationItem.title = "channels".localized()
        getChannels{ }
        addResfreshControl()
        setActivity()
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "search".localized()
        navigationItem.searchController = searchController
        definesPresentationContext = true
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
    
    @objc func refreshCallHistory() {
        if self.mode == .main {
            getChannels {
                DispatchQueue.main.async {
                    self.refreshControl.endRefreshing()
                }
            }
        } else {
            refreshControl.endRefreshing()
        }
    }
    
    func addResfreshControl() {
        tableView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(refreshCallHistory), for: .valueChanged)
    }
    
    func handleSubscriberUpdate(user: String, name: String, avatarUrl: String?) {
        if mode == .main {
            for i in 0..<channels.count {
                for j in 0..<(channels[i].channel?.subscribers?.count ?? 0) {
                    if channels[i].channel?.subscribers?[j].user == user {
                        channels[i].channel?.subscribers?[j].name = name
                        channels[i].channel?.subscribers?[j].avatarURL = avatarUrl
                        break
                    }
                }
            }
            self.channelsInfo = self.channels
        }
        else {
            for i in 0..<channels.count {
                for j in 0..<(channels[i].channel?.subscribers?.count ?? 0) {
                    if channels[i].channel?.subscribers?[j].user == user {
                        channels[i].channel?.subscribers?[j].name = name
                        channels[i].channel?.subscribers?[j].avatarURL = avatarUrl
                        break
                    }
                }
            }
            for i in 0..<foundChannels.count {
                for j in 0..<(foundChannels[i].channel?.subscribers?.count ?? 0) {
                    if foundChannels[i].channel?.subscribers?[j].user == user {
                        foundChannels[i].channel?.subscribers?[j].name = name
                        foundChannels[i].channel?.subscribers?[j].avatarURL = avatarUrl
                        break
                    }
                }
            }
            self.channelsInfo = self.foundChannels
        }
        if self.tabBarController?.selectedIndex == 2 && self.navigationController?.viewControllers.count == 2 {
            for i in 0..<self.channels.count {
                if channels[i].channel?._id == self.mainRouter?.channelMessagesViewController?.channelInfo.channel?._id {
                    self.mainRouter?.channelMessagesViewController?.channelInfo.channel?.subscribers = channels[i].channel?.subscribers
                    self.mainRouter?.channelMessagesViewController?.tableView?.reloadData()
                    break
                }
            }
        }
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
    
    func createChannel(name: String, mode: Bool, completion: @escaping () -> ()) {
        self.activity.startAnimating()
        self.viewModel!.createChannel(name: name, openMode: mode, completion: { (channel, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.activity.startAnimating()
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
                completion()
            } else {
                SharedConfigs.shared.signedUser?.channels?.append(channel!._id)
               
                if self.mode == .main {
                    self.channels.append(ChannelInfo(channel: channel, role: 0))
                    self.channelsInfo = self.channels
                } //else {
//                    self.channels.append(ChannelInfo(channel: channel, role: 0))
//                    for i in 0..<self.foundChannels.count {
//                        if self.foundChannels[i].channel?._id == channel?._id {
//                            self.foundChannels[i].role = 2
//                            break
//                        }
//                    }
//                    self.channelsInfo = self.foundChannels
                
                DispatchQueue.main.async {
                    self.activity.stopAnimating()
                    self.tableView.reloadData()
                }
                DispatchQueue.main.async {
                    self.removeView()
                    self.mainRouter?.showChannelMessagesViewController(channelInfo: ChannelInfo(channel: channel, role: 0))
                    completion()
                }
            }
        })
    }
    
 func setView(_ str: String) {
        if channels.count == 0 {
            DispatchQueue.main.async {
                let noResultView = UIView(frame: self.view.frame)
                self.tableView.addSubview(noResultView)
                noResultView.tag = 26
                noResultView.backgroundColor = UIColor(named: "imputColor")
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: 50))
                noResultView.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
                label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
                label.center = self.view.center
                label.text = str
                label.textColor = .lightGray
                label.textAlignment = .center
                
                
            }
        } else {
            removeView()
        }
    }
    
    func removeView() {
          DispatchQueue.main.async {
              let resultView = self.view.viewWithTag(26)
              resultView?.removeFromSuperview()
          }
      }
    
    @objc func addButtonTapped() {
        let vc = CreateAccountAlertViewController.instantiate(fromAppStoryboard: .channel)
        vc.mainRouter = mainRouter
        vc.viewModel = viewModel
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alertController.setValue(vc, forKey: "contentViewController")
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    func getChannels(completion: @escaping () -> ()) {
        viewModel?.getChannels(ids: SharedConfigs.shared.signedUser?.channels ?? [], completion: { (retrievedChannels, error) in
            self.isLoaded = true
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
                completion()
            } else if let channels = retrievedChannels {
                if channels.count != 0 {
                    self.channels = channels
                    self.channelsInfo = channels
                    DispatchQueue.main.async {
                        self.activity.stopAnimating()
                        self.tableView.reloadData()
                    }
                    completion()
                } else {
                    DispatchQueue.main.async {
                        self.setView("no_channels".localized())
                        self.activity.stopAnimating()
                    }
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
            } else if let foundchannels = channels {
                DispatchQueue.main.async {
                    if self.searchController.searchBar.text!.count > 0 {
                        self.mode = .search
                        self.foundChannels = foundchannels
                        self.channelsInfo = foundchannels
                        if self.channelsInfo.elementsEqual(self.foundChannels) {
                            self.removeView()
                            self.tableView.reloadData()
                        }
                    }
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

extension ChannelListViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        if searchController.searchBar.text!.count > 0 {
            findChannels(term: searchController.searchBar.text!)
        } else if searchController.searchBar.text!.count == 0 {
            self.mode = .main
            channelsInfo = channels
            DispatchQueue.main.async {
                self.tableView.reloadData()
                if self.channelsInfo.count == 0 {
                    self.setView("no_channels".localized())
                }
            }
        }
    }
}
