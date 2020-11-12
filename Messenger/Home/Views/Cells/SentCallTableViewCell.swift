//
//  SendCallTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 8/6/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class SentCallTableViewCell: UITableViewCell {

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

    func changeShapeOfCallMessageView() {
        callMessageView.clipsToBounds = true
        callMessageView.layer.cornerRadius = 8
    }

}
