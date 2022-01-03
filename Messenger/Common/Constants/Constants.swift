//
//  Constants.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

struct Environment {
    #if DEVELOPMENT
    static let baseURL = "https://method.dynamic.am"
    static let socketUrl = "wss://method.dynamic.am"
    #else
    static let baseURL = "https://method.dynamic.am"
    static let socketUrl = "wss://method.dynamic.am"
    #endif
}

enum CallStatus: String {
    case accepted  = "accepted"
    case missed    = "missed"
    case cancelled = "cancelled"
    case incoming  = "incoming_call"
    case outgoing  = "outgoing_call"
    case ongoing   = "ongoing"
}

struct AUTHUrls {
    static let MailisExist          = "/mailExists"
    static let Login                = "/login"
    static let Register             = "/register"
    static let UpdateUser           = "/updateuser"
    static let VerifyToken          = "/tokenExists"
    static let RegisterDevice       = "/registerdevice"
    static let CheckUsername        = "/usernameExists"
    static let LoginWithFacebook    = "/loginFacebook"
    static let LoginWithPhoneNumber = "/loginPhone"
}

struct HomeUrls {
    static let GetUserContacts              = "/contacts"
    static let FindUsers                    = "/findusers"
    static let AddContact                   = "/addcontact"
    static let Logout                       = "/user/logout"
    static let GetChats                     = "/chats"
    static let GetChatMessages              = "/chats/"
    static let GetUserById                  = "/user/"
    static let GetImage                     = "/avatars"
    static let DeleteAccount                = "/users/me"
    static let DeactivateAccount            = "/deactivate/me"
    static let DeleteAvatar                 = "/users/me/avatar"
    static let RemoveContact                = "/removecontact"
    static let OnlineUsers                  = "/onlineusers"
    static let HideData                     = "/hidedata"
    static let GetCallHistory               = "/callhistory"
    static let RemoveCall                   = "/call"
    static let ChangeEmail                  = "/updatemail"
    static let VerifyEmail                  = "/verifyemail"
    static let ChangePhone                  = "/updatephonenumber"
    static let VerifyPhone                  = "/verifyphonenumber"
    static let ReadCalls                    = "/readcallhistory"
    static let confirmRequest               = "/confirmContactRequest"
    static let DeleteRequest                = "/deleteContactRequest"
    static let GetRequests                  = "/contactRequests"
    static let GetAdminMessage              = "/adminmessages"
    static let EditChatMessage              = "/message/edit"
    static let DeleteChatMessages           = "/messages/delete"
    static let SendImageInChat              = "/chatMessages"
    static let SendImageInChannel           = "/chnMessages"
    static let UploadAvatar                 = "/users/me/avatar"
}

struct ChannelUrls {
    static let CreateChannel                = "/channel"
    static let GetChannelInfo               = "/channelsInfo"
    static let CheckChannelName             = "/checkChannelName"
    static let FindChannels                 = "/findChannels"
    static let DeleteChannelMessageBySender = "/chnMessages/delete"
    static let EditChannelMessageBySender   = "/chnMessages/edit"
}

struct AppLangKeys {
     static let Rus = "ru"
     static let Eng = "en"
     static let Arm = "hy"
}

struct Keys {
    static let PUSH_DEVICE_TOKEN = "device_token"
    static let VOIP_DEVICE_TOKEN = "voip_device_token"
    static let TOKEN_KEYCHAIN_ID_KEY = "token"
    static let APP_Language = "appLanguage"
    static let IS_REGISTERED = "isRegistered"
    static let IS_LOGIN_FROM_FACEBOOK = "isLoginFromFacebook"
}

enum MessageType: String {
    case video = "video"
    case call = "call"
    case text = "text"
    case image = "image"
}

struct CallModelConstants {
    static let contactsEntity = "ContactsEntity"
    static let otherContactsEntity = "OtherContactEntity"
    static let callEntity = "CallEntity"
    static let contacts = "contacts"
    static let otherContacts = "otherContacts"
}

enum AppMode: String {
    case dark
    case light
}


struct Languages {
    static let english = "English"
    static let russian = "Russian"
    static let armenian = "Armenian"
}
