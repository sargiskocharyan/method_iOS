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
    var channel: Channel?
    var viewModel: ChannelInfoViewModel?
    var subscribers: [ChannelSubscriber]?
    
    // MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        setInfo()
        addGestures()
        setBorder(view: rejectView)
        setBorder(view: subscribersView)
        setBorder(view: headerView)
        setBorder(view: urlView)
        setBorder(view: leaveView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }

    //MARK: Helper methods
    func configureView() {
           setBorder(view: urlView)
           setBorder(view: headerView)
           setBorder(view: descriptionView)
           channelLogoImageView.layer.cornerRadius = channelLogoImageView.frame.height / 2
           channelLogoImageView.clipsToBounds = true
       }
    
    func setInfo() {
        nameLabel.text = channel?.name
        descriptionLabel.text = channel?.description ?? "description_not_set".localized()
        urlLabel.text = "URL"
        descriptionTextLabel.text = "description".localized()
        urlTextLabel.text = channel?.publicUrl
    }
    
    func addGestures() {
        let tapSubsribersView = UITapGestureRecognizer(target: self, action: #selector(self.handleSubscribersTap(_:)))
        subscribersView.addGestureRecognizer(tapSubsribersView)
        let tapRejectView = UITapGestureRecognizer(target: self, action: #selector(self.handleRejectViewTap(_:)))
        rejectView.addGestureRecognizer(tapRejectView)
        let tapLeaveView = UITapGestureRecognizer(target: self, action: #selector(self.handleLeaveViewTap(_:)))
        leaveView.addGestureRecognizer(tapLeaveView)
        let tapUrlView = UITapGestureRecognizer(target: self, action: #selector(self.handleUrlViewTap(_:)))
        urlView.addGestureRecognizer(tapUrlView)
    }
    
    @objc func handleSubscribersTap(_ sender: UITapGestureRecognizer? = nil) {
        DispatchQueue.main.async {
            self.mainRouter?.showSubscribersListViewController(id: self.channel?._id ?? "")
        }
    }
   
    @objc func handleRejectViewTap(_ sender: UITapGestureRecognizer? = nil) {
            print("Reject tapped")
       }
    
    @objc func handleLeaveViewTap(_ sender: UITapGestureRecognizer? = nil) {
           print("Leave tapped")
       }
    
    @objc func handleUrlViewTap(_ sender: UITapGestureRecognizer? = nil) {
              print("Url tapped")
          }
    
       func setBorder(view: UIView) {
           view.layer.borderColor = UIColor.lightGray.cgColor
           view.layer.borderWidth = 1
       }
    
    
}
