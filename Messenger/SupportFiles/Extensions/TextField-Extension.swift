//
//  TextField-Extension.swift
//  Messenger
//
//  Created by Employee1 on 5/23/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

extension UITextField {
    
    
    func underlined() {
        viewWithTag(1)?.removeFromSuperview()
        let border = UIView()
        let height = CGFloat(1.0)
        border.tag = 1
        border.backgroundColor = .lightGray
        border.frame = CGRect(x: 0, y: self.frame.size.height - height, width:  self.frame.size.width, height: height)
        self.addSubview(border)
        
    }
    
}


