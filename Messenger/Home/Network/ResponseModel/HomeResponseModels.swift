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

struct AdminMessage: Codable {
    var _id: String
    var body: String
    var title: String
    var category: String
    var expiredAt: String
}

struct Request: Codable {
    var _id: String
    var sender: String
    var receiver: String
    var createdAt: String
    var updatedAt: String
}

struct Channel: Codable {
    var _id: String
    var name: String
    var creator: String?
    var admin: String?
    var subscribers: [Subscriber]?
    var avatarURL: String?
    var createdAt: String
    var subscribersCount: Int?
    var statuses: [ChannelStatus]?
    var description: String?
    var publicUrl: String?
    var openMode: Bool?
}

struct ChannelInfo: Codable, Equatable {
    static func == (lhs: ChannelInfo, rhs: ChannelInfo) -> Bool {
        return lhs.channel?._id == rhs.channel?._id
    }
    var channel: Channel?
    var role: Int?
}
 
struct ChannelSubscriber: Codable {
    var _id: String?
    var user: User?
}

struct ChannelMessages: Codable {
    var array: [Message]?
    var statuses: [ChannelStatus]?
}

struct ChannelStatus: Codable {
    var userId: String?
    var receivedMessageDate: String?
    var readMessageDate: String?
}

struct CheckChannelName: Codable {
    var channelNameExists: Bool?
}

struct SubscribedResponse: Codable {
    var subscribed: Bool?
}

struct Admin: Codable {
    var admin: String
}

struct Subscriber: Codable {
    var _id: String?
    var user: String?
    var avatarURL: String?
    var name: String?
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
    let image: Image?
}

struct Image: Codable {
    let imageName: String?
    let imageURL: String?
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

