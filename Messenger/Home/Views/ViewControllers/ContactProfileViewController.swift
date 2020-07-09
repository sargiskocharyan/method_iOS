//
//  ContactProfileViewController.swift
//  Messenger
//
//  Created by Employee1 on 7/7/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ContactProfileViewController: UIViewController {
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.contentMode = . scaleAspectFill
        userImageView.layer.cornerRadius = 40
        userImageView.clipsToBounds = true
        infoView.layer.borderColor = UIColor.lightGray.cgColor
        infoView.layer.borderWidth = 1.0
        infoView.layer.masksToBounds = true
    }
}
