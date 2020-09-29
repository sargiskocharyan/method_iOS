//
//  ChannelMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ChannelMessagesViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak var nameOfChannelButton: UIButton!
    @IBOutlet weak var joinButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Properties
    var channelRouter: ChannelRouter?
    
    //MARK: LifeCycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self

    }
    
    //MARK: Helper methods
    @IBAction func nameOfChannelButtonAction(_ sender: Any) {
    }
    
    @IBAction func joinChannelButtonAction(_ sender: Any) {
    }
}

extension ChannelMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
}

