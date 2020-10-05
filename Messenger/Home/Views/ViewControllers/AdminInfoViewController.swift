//
//  AdminInfoViewController.swift
//  Messenger
//
//  Created by Employee3 on 10/2/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class AdminInfoViewController: UIViewController {
    
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscribersTextLabel: UILabel!
    @IBOutlet weak var moderatorsTextLabel: UILabel!
    @IBOutlet weak var changeAdminTextLabel: UILabel!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    @IBOutlet weak var moderatorsView: UIView!
    @IBOutlet weak var subscribersView: UIView!
    @IBOutlet weak var changeAdminView: UIView!
    
    var channel: Channel?
    var mainRouter: MainRouter?
    var viewModel: ChannelInfoViewModel?
    var moderators: [ChannelSubscriber] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
        addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
    }
    
    @IBAction func editNameButtonAction(_ sender: Any) {
        
    }
    
    @IBAction func editDescriptionButtonAction(_ sender: Any) {
        
    }
    
    func addGestures() {
        let tapSubscribers = UITapGestureRecognizer(target: self, action: #selector(self.handleSubscribersTap(_:)))
        subscribersView.addGestureRecognizer(tapSubscribers)
        let tapModerators = UITapGestureRecognizer(target: self, action: #selector(self.handleModeratorsTap(_:)))
        moderatorsView.addGestureRecognizer(tapModerators)
        let tapChangeAdmin = UITapGestureRecognizer(target: self, action: #selector(self.handleChangeAdminTab(_:)))
        changeAdminView.addGestureRecognizer(tapChangeAdmin)
    }
    
    @objc func handleSubscribersTap(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showSubscribersListViewControllerFromAdminInfo(id: channel?._id ?? "")
    }
    
    @objc func handleModeratorsTap(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showModeratorListViewController(id: channel!._id, isChangeAdmin: false)
    }
    
    @objc func handleChangeAdminTab(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showModeratorListViewController(id: channel!._id, isChangeAdmin: true)
    }
    
    func configureView() {
        setBorder(view: urlView)
        setBorder(view: headerView)
        setBorder(view: descriptionView)
        setBorder(view: subscribersView)
        setBorder(view: moderatorsView)
        setBorder(view: changeAdminView)
        setCornerRadius(view: channelLogoImageView)
        setCornerRadius(view: cameraView)
    }
    
    func setInfo() {
        nameLabel.text = channel?.name
        descriptionLabel.text = channel?.description ?? "description_not_set".localized()
        urlLabel.text = channel?.publicUrl
        descriptionTextLabel.text = "description".localized()
        urlTextLabel.text = "URL"
    }
    
    func setCornerRadius(view: UIView) {
        view.layer.cornerRadius = view.frame.height / 2
        view.clipsToBounds = true
    }
    
    func setBorder(view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }
    
}
