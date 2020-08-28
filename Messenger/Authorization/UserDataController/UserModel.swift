//
//  UserModel.swift
//  Messenger
//
//  Created by Sargis Kocharyan on 6/17/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

protocol PropertyReflectable: Equatable { }

extension PropertyReflectable {
    subscript(key: String) -> Any? {
        let m = Mirror(reflecting: self)
        for child in m.children {
            if child.label == key { return child.value }
        }
        return nil
    }
}

struct UserModel: Codable, PropertyReflectable {
    static func == (lhs: UserModel, rhs: UserModel) -> Bool {
        return lhs.id == rhs.id
    }

    var name: String?
    var lastname: String?
    var username: String?
    var email: String?
    var token: String?
    var id: String
    var avatarURL: String?
    var phoneNumber: String?
    var birthDate: String?
    var gender: String?
    var info: String?
    var tokenExpire: Date?
    var deactivated: Bool?
    var blocked: Bool?
    var missedCallHistory: [String]?
    
    
    enum CodingKeys: String, CodingKey {
        case name
        case lastname
        case username
        case email
        case token
        case id = "_id"
        case avatarURL
        case phoneNumber
        case birthDate = "birthday"
        case gender
        case info
        case tokenExpire
        case deactivated
        case blocked
        case missedCallHistory
    }
}


