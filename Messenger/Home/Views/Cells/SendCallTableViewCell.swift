//
//  SendCallTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 8/6/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SendCallTableViewCell: UITableViewCell {

    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var arrowImageView: UIImageView!
    @IBOutlet weak var durationAndStartTimeLabel: UILabel!
    @IBOutlet weak var callMessageView: UIView!
    @IBOutlet weak var ststusLabel: UILabel!
    
    var id: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        changeShapeOfCallMessageView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func changeShapeOfCallMessageView() {
        callMessageView.clipsToBounds = true
        callMessageView.layer.cornerRadius = 8
    }

}
