//
//  CustomTapGesture.swift
//  Messenger
//
//  Created by Employee3 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class CustomTapGesture: UITapGestureRecognizer {
    var indexPath: IndexPath
    init(target: AnyObject, action: Selector, indexPath: IndexPath) {
        self.indexPath = indexPath
        super.init(target: target, action: action)
    }
}
