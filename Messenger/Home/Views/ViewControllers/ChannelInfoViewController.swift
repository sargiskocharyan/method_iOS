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
        nameLabel.text = channel?.name
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
    
    //Helper methods
    func configureView() {
        setBorder(view: urlView)
        setBorder(view: headerView)
        setBorder(view: descriptionView)
    }
    
    func setBorder(view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }

}
