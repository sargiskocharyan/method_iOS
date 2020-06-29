//
//  ResponseModels.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

struct ContactResponseWithId: Codable {
    let _id: String
    var name: String?
    let lastname: String?
    let email: String?
    let username: String
    let avatar: String?
}

struct User: Codable {
    var name: String?
    let lastname: String?
    let university: String?
    let _id: String
    let username: String
    let avatar: String?
}

struct FoundUsers: Codable {
    let users: [User]
}

//struct ContactInformation {
//    let username: String?
//    let name: String?
//    let lastname: String?
//    let _id: String
//}

struct Sender: Codable{
    let id: String?
    let name: String?
}

struct Message: Codable {
    let _id: String?
    let reciever: String?
    var text: String?
    let createdAt: String?
    let updatedAt: String?
    let owner: String?
    let sender: Sender?
}

struct Chat: Codable {
    let id: String
    let name: String?
    let lastname: String?
    let username: String
    var message: Message?
    var recipientAvatarURL: String?
}

struct UserById: Codable {
    let name: String?
    let username: String
    let lastname: String?
    let id: String
}
