//
//  CustomAlertViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/18/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class CustomAlertViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var gifImageView: UIImageView!
    @IBOutlet weak var bodyLabel: UILabel!
    
    var adminMessage: AdminMessage?
    var mainRouter: MainRouter?
    var row: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = adminMessage?.title
        bodyLabel.text = adminMessage?.body
        gifImageView.image = UIImage(named: "English")
       
    }

    @IBAction func okButtonAction(_ sender: Any) {
        parent?.dismiss(animated: true, completion: {
            SharedConfigs.shared.adminMessages.remove(at: self.row!)
            self.mainRouter?.notificationDetailViewController?.tableView.deleteRows(at: [IndexPath(row: self.row!, section: 0)], with: .automatic)
            self.mainRouter?.notificationDetailViewController?.viewWillAppear(false)
            self.mainRouter?.notificationListViewController?.reloadData()
        })
    }
    
}
