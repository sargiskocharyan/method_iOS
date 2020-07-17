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
        let border = UIView()
        self.addSubview(border)
        border.topAnchor.constraint(equalTo: topAnchor, constant: frame.height).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.tag = 1
        border.backgroundColor = .lightGray
        border.anchor(top: self.topAnchor, paddingTop: self.frame.height, bottom: self.bottomAnchor, paddingBottom: 0, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: frame.width, height: 1)
    }
    
    func underlinedUniversityTextField() {
        let border = UIView()
        self.addSubview(border)
        border.topAnchor.constraint(equalTo: topAnchor, constant: frame.height).isActive = true
        border.leftAnchor.constraint(equalTo: leftAnchor, constant: 0).isActive = true
        border.rightAnchor.constraint(equalTo: rightAnchor, constant: 0).isActive = true
        border.heightAnchor.constraint(equalToConstant: 1).isActive = true
        border.tag = 1
        border.backgroundColor = .lightGray
        border.anchor(top: self.topAnchor, paddingTop: self.frame.height - 20, bottom: self.bottomAnchor, paddingBottom: 20, left: leftAnchor, paddingLeft: 0, right: rightAnchor, paddingRight: 0, width: frame.width, height: 1)
        
    }
    
}


