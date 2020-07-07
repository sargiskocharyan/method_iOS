//
//  CustomCell.swift
//  Messenger
//
//  Created by Employee1 on 6/5/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown

class CustomCell: DropDownCell {

    @IBOutlet weak var countryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if SharedConfigs.shared.mode == "dark" {
            optionLabel.textColor = UIColor.white
        } else {
            optionLabel.textColor = UIColor.black
        }
    }
    
}
