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
    
    enum CodingKeys: String, CodingKey {
        case name
        case lastname
        case username
        case email
        case university
        case token
        case id = "_id"
        case avatarURL
    }
}
