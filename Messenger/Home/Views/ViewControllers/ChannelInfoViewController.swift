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
    //@IBOutlet weak var leaveButton: UIButton!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var channel: Channel?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if (tabBarController?.tabBar.isHidden)! {
            tabBarController?.tabBar.isHidden = false
        }
        if (navigationController?.navigationBar.isHidden)! {
            navigationController?.navigationBar.isHidden = false
        }
//        if SharedConfigs.shared.signedUser?.channels?.contains(channel!._id) == true {
//            leaveButton.isHidden = false
//        } else {
//            leaveButton.isHidden = true
//        }
        setInfo()
    }
    
    //Helper methods
    @IBAction func leaveButtonAction(_ sender: Any) {
        
    }
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
        urlLabel.text = channel?.publicUrl
        descriptionTextLabel.text = "description".localized()
        urlTextLabel.text = "URL"
    }
    
    func setBorder(view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }

}
