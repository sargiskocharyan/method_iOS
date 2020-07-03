//
//  k.swift
//  Messenger
//
//  Created by Employee1 on 5/23/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

extension UIButton {
    
    func setGradientBackground(view: UIView, _ gradientColor: CAGradientLayer) {
        gradientColor.frame = frame
        gradientColor.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientColor.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientColor.colors = [UIColor.init(red: 68/255, green: 126/255, blue: 186/255, alpha: 1).cgColor,UIColor.init(red: 102/255, green: 82/255, blue: 169/255, alpha: 1).cgColor]
        gradientColor.cornerRadius = 8
        view.layer.insertSublayer(gradientColor, at: 0)
    }
    
}
