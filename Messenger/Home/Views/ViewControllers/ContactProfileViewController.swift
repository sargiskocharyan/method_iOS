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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        userImageView.contentMode = . scaleAspectFill
        userImageView.layer.cornerRadius = 40
        userImageView.clipsToBounds = true
        headerView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
    }
}
