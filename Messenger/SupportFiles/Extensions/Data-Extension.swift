//
//  Data-Extension.swift
//  Messenger
//
//  Created by Employee1 on 5/28/20.
//  Copyright © 2020 Employee1. All rights reserved.
//


import Foundation

extension Data {
    
    func toString() -> String {
        let str = String(bytes: self, encoding: .utf8)
        return str!
    }
}
