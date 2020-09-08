//
//  ResponseModels.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation


struct Users: Codable { 
    let users: [User]
}

//struct Sender: Codable{
//    let id: String?
//    let name: String?
//}

struct MessageCall: Codable {
    var callSuggestTime: String?
    var type: String?
    var status: String?
    var duration: Float?
}

struct Messages: Codable {
    var array: [Message]?
    var statuses: [MessageStatus]?
}

struct Request: Codable {
    var _id: String
    var sender: String
    var receiver: String
    var createdAt: String
    var updatedAt: String
}

struct Message: Codable {
    var call: MessageCall?
    var type: String?
    let _id: String?
    let reciever: String?
    var text: String?
    let createdAt: String?
    let updatedAt: String?
    let owner: String?
    let senderId: String?
    
}

struct OnlineUsers: Codable {
    let usersOnline: [String]
}

struct Chat: Codable {
    let id: String
    let name: String?
    let lastname: String?
    let username: String?
    var message: Message?
    var recipientAvatarURL: String?
    var online: Bool?
    let statuses: [MessageStatus]?
    var unreadMessageExists: Bool
    var isAddedOne: Bool?
}

struct Chats :Codable {
    let array: [Chat]?
    let badge: Int
}

struct MessageStatus: Codable {
    var receivedMessageDate: String?
    var readMessageDate: String?
    let _id: String?
    let userId: String?
}

struct UserById: Codable {
    let name: String?
    let username: String?
    let lastname: String?
    let id: String
    let avatarURL: String?
}

