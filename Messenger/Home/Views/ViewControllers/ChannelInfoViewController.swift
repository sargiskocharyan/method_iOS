//
//  ChannelInfoViewController.swift
//  Messenger
//
//  Created by Employee3 on 9/30/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelInfoViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak var urlView: UIView!
    //    @IBOutlet weak var leaveButton: UIButton!
    
    @IBOutlet weak var channelDescriptionLabel: UILabel!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var leaveOrJoinView: UIView!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    @IBOutlet weak var leaveOrJoinTextLabel: UILabel!
    
    //MARK: Properties
    var viewModel: ChannelInfoViewModel?
    var mainRouter: MainRouter?
    var channelInfo: ChannelInfo?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (tabBarController?.tabBar.isHidden)! {
            tabBarController?.tabBar.isHidden = false
        }
        if (navigationController?.navigationBar.isHidden)! {
            navigationController?.navigationBar.isHidden = false
        }
        setInfo()
    }
    
    //Helper methods
    func addGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleLeaveOrJoinTap))
        leaveOrJoinView.addGestureRecognizer(tapGesture)
        let tapUrlView = UILongPressGestureRecognizer(target: self, action: #selector(self.handleUrlViewTap(_:)))
        urlView.addGestureRecognizer(tapUrlView)
    }
    
    @objc func handleUrlViewTap(_ sender: UILongPressGestureRecognizer? = nil) {
        if sender?.state == UIGestureRecognizer.State.began {
            UIPasteboard.general.string = channelInfo?.channel?.publicUrl
            self.showToast(message: "url_copied_in_clipboard", font: .systemFont(ofSize: 15.0))
        }
    }

    func leaveChannel() {
        if self.mainRouter?.channelListViewController?.channelsInfo == self.mainRouter?.channelListViewController?.channels {
            self.mainRouter?.channelListViewController?.channels = self.mainRouter!.channelListViewController!.channels.filter({ (channelInfo) -> Bool in
                return channelInfo.channel?._id != self.channelInfo?.channel?._id
            })
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        } else {
            self.mainRouter?.channelListViewController?.channels = self.mainRouter!.channelListViewController!.channels.filter({ (channelInfo) -> Bool in
                return channelInfo.channel?._id != self.channelInfo?.channel?._id
            })
            for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.foundChannels[i].role = 3
                    break
                }
            }
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        }
    }
    
    func joinToChannel() {
        if self.mainRouter?.channelListViewController?.mode == .main {
            self.mainRouter?.channelListViewController?.channels.append(self.channelInfo!)
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        } else {
            self.mainRouter?.channelListViewController?.channels.append(self.channelInfo!)
            for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.foundChannels[i].role = 2
                    break
                }
            }
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        }
    }
    
    @objc func handleLeaveOrJoinTap() {
        if channelInfo?.role == 2 {
            viewModel?.leaveChannel(id: channelInfo!.channel!._id, completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    self.channelInfo?.role = 3
                    let filterChannels = SharedConfigs.shared.signedUser?.channels?.filter({ (channelId) -> Bool in
                        return channelId != self.channelInfo?.channel?._id
                    })
                    SharedConfigs.shared.signedUser?.channels = filterChannels
                    self.mainRouter?.channelMessagesViewController?.channelInfo = self.channelInfo
                    self.leaveChannel()
                    DispatchQueue.main.async {
                        self.mainRouter?.channelListViewController?.tableView.reloadData()
                        self.leaveOrJoinTextLabel.text = "join".localized()
                        self.leaveOrJoinTextLabel.textAlignment = .center
                        self.leaveOrJoinTextLabel.textColor = UIColor(red: 128/255, green: 94/255, blue: 250/255, alpha: 1)
                    }
                }
            })
        } else {
            viewModel?.subscribeToChannel(id: channelInfo!.channel!._id, completion: { (response, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else if response != nil && response!.subscribed! {
                    self.channelInfo?.role = 2
                    SharedConfigs.shared.signedUser?.channels?.append(self.channelInfo!.channel!._id)
                    self.mainRouter?.channelMessagesViewController?.channelInfo = self.channelInfo
                    self.joinToChannel()
                    DispatchQueue.main.async {
                        self.mainRouter?.channelListViewController?.tableView.reloadData()
                        self.leaveOrJoinTextLabel.text = "leave".localized()
                        self.leaveOrJoinTextLabel.textAlignment = .left
                        self.leaveOrJoinTextLabel.textColor = .red
                    }
                }
            })
        }
    }
    
    func configureView() {
        setBorder(view: urlView)
        setBorder(view: descriptionView)
        channelLogoImageView.layer.cornerRadius = channelLogoImageView.frame.height / 2
        channelLogoImageView.clipsToBounds = true
    }
    
    func setInfo() {
        nameLabel.text = channelInfo?.channel?.name
        descriptionLabel.text = channelInfo?.channel?.description?.count ?? 0 > 0 ? channelInfo?.channel?.description : "description_not_set".localized()
        urlLabel.text = channelInfo?.channel?.publicUrl
        descriptionTextLabel.text = "description".localized()
        urlTextLabel.text = "URL"
        if channelInfo?.channel?.openMode == true {
            channelDescriptionLabel.text = "all_members_can_post".localized()
        } else {
            channelDescriptionLabel.text = "only_admin_can_post".localized()
        }
        if channelInfo?.role == 2 {
            leaveOrJoinTextLabel.text = "leave".localized()
            leaveOrJoinTextLabel.textAlignment = .left
            leaveOrJoinTextLabel.textColor = .red
        } else {
            leaveOrJoinTextLabel.text = "join".localized()
            leaveOrJoinTextLabel.textAlignment = .center
            leaveOrJoinTextLabel.textColor = UIColor(red: 128/255, green: 94/255, blue: 250/255, alpha: 1)
        }
        ImageCache.shared.getImage(url: channelInfo?.channel?.avatarURL ?? "", id: channelInfo?.channel?._id ?? "", isChannel: true) { (image) in
            DispatchQueue.main.async {
                self.channelLogoImageView.image = image
            }
        }
    }
    
    func setBorder(view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }
    
}
