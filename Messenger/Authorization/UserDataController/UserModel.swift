//
//  UserModel.swift
//  Messenger
//
//  Created by Sargis Kocharyan on 6/17/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
struct UserModel: Codable {
    var name: String?
    var lastname: String?
    var username: String?
    var email: String?
    var university: University?
    var token: String?
    var id: String
    var avatarURL: String?
    var address: String?
    var phoneNumber: String?
    var birthDate: String?
    var gender: String?
    var info: String?
    var tokenExpire: Date?
    
    enum CodingKeys: String, CodingKey {
        case name
        case lastname
        case username
        case email
        case university
        case token
        case id = "_id"
        case avatarURL
        case address
        case phoneNumber
        case birthDate = "birthday"
        case gender
        case info
        case tokenExpire
    }
}
