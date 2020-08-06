//
//  RecieveCallTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 8/6/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class RecieveCallTableViewCell: UITableViewCell {

    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var cellMessageView: UIView!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var durationAndStartCallLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfImageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func changeShapeOfImageView() {
           userImageView.clipsToBounds = true
           userImageView.layer.cornerRadius = 15
           cellMessageView.clipsToBounds = true
           cellMessageView.layer.cornerRadius = 10
       }
    
}
