//
//  CallDetailTableViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/10/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class CallDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
}
