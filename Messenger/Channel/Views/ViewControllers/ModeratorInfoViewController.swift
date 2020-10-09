//
//  ModeratorInfoViewController.swift
//  Messenger
//
//  Created by Employee1 on 10/2/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ModeratorInfoViewController: UIViewController {

    //MARK: IBOutlets
    @IBOutlet weak var leaveView: UIView!
    @IBOutlet weak var leaveLabel: UILabel!
    @IBOutlet weak var rejectView: UIView!
    @IBOutlet weak var subscribersView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var urlView: UIView!
    //@IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var channelInfo: ChannelInfo?
    var viewModel: ChannelInfoViewModel?
    var subscribers: [ChannelSubscriber] = []
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setInfo()
        addGestures()
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }

    //MARK: Helper methods
    func configureView() {
        setBorder(view: subscribersView)
        setBorder(view: urlView)
        setBorder(view: rejectView)
        setBorder(view: descriptionView)
        channelLogoImageView.layer.cornerRadius = channelLogoImageView.frame.height / 2
        channelLogoImageView.clipsToBounds = true
    }
    
    func setInfo() {
        nameLabel.text = channelInfo?.channel?.name
        descriptionLabel.text = channelInfo?.channel?.description?.count ?? 0 > 0 ? channelInfo?.channel?.description : "description_not_set".localized()
        urlLabel.text = "URL"
        descriptionTextLabel.text = "description".localized()
        urlTextLabel.text = channelInfo?.channel?.publicUrl
        ImageCache.shared.getImage(url: channelInfo?.channel?.avatarURL ?? "", id: channelInfo?.channel?._id ?? "") { (image) in
            DispatchQueue.main.async {
                self.channelLogoImageView.image = image
            }
        }
    }
    
    func addGestures() {
        let tapSubsribersView = UITapGestureRecognizer(target: self, action: #selector(self.handleSubscribersTap(_:)))
        subscribersView.addGestureRecognizer(tapSubsribersView)
        let tapRejectView = UITapGestureRecognizer(target: self, action: #selector(self.handleRejectViewTap(_:)))
        rejectView.addGestureRecognizer(tapRejectView)
        let tapLeaveView = UITapGestureRecognizer(target: self, action: #selector(self.handleLeaveViewTap(_:)))
        leaveView.addGestureRecognizer(tapLeaveView)
    }
    
    @objc func handleSubscribersTap(_ sender: UITapGestureRecognizer? = nil) {
        DispatchQueue.main.async {
            self.mainRouter?.showSubscribersListViewController(id: self.channelInfo?.channel?._id ?? "")
        }
    }
    
    @objc func handleRejectViewTap(_ sender: UITapGestureRecognizer? = nil) {
        let alert = UIAlertController(title: "attention".localized(), message: "are_you_sure_you_want_reject_be_moderator".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
            self.viewModel?.rejectBeModerator(id: self.channelInfo!.channel!._id, completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    DispatchQueue.main.async {
                        self.navigationController?.popToRootViewController(animated: true)
                        for i in 0..<(self.mainRouter?.channelListViewController?.channelsInfo.count)! {
                            if self.channelInfo?.channel?._id == self.mainRouter?.channelListViewController?.channelsInfo[i].channel!._id {
                                self.mainRouter?.channelListViewController?.channelsInfo[i].role = 2
                                break
                            }
                        }
                        self.mainRouter?.channelListViewController?.channels = (self.mainRouter?.channelListViewController?.channelsInfo)!
                    }
                }
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    @objc func handleLeaveViewTap(_ sender: UITapGestureRecognizer? = nil) {
        viewModel?.leaveChannel(id: channelInfo!.channel!._id, completion: { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else {
                DispatchQueue.main.async {
                    self.mainRouter?.channelListViewController?.channelsInfo = self.mainRouter!.channelListViewController!.channelsInfo.filter({ (channelInfo) -> Bool in
                        return self.channelInfo?.channel?._id != channelInfo.channel?._id
                    })
                    self.mainRouter?.channelListViewController?.channels = (self.mainRouter?.channelListViewController?.channelsInfo)!
                    self.mainRouter?.channelListViewController?.tableView.reloadData()
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        })
    }
    
       func setBorder(view: UIView) {
           view.layer.borderColor = UIColor.lightGray.cgColor
           view.layer.borderWidth = 1
       }
    
    
}
