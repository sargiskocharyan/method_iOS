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
    static let baseURL = "https://messenger-dynamic.herokuapp.com" //"https://192.168.0.105:3000"
    static let socketUrl = "wss://messenger-dynamic.herokuapp.com" //messenger-dynamic.herokuapp.com
    #else
    static let baseURL = "https://messenger-dynamic.herokuapp.com" //"https://192.168.0.105:3000"
    static let socketUrl = "wss://messenger-dynamic.herokuapp.com" //messenger-dynamic.herokuapp.com
    #endif
}

struct AUTHUrls {
    static let MailisExist       = "/mailExists"
    static let Login             = "/login"
    static let Register          = "/register"
    static let UpdateUser        = "/updateuser"
    static let VerifyToken       = "/tokenExists"
    static let GetUniversities   = "/university/all"
    static let GetUserContacts   = "/contacts"
    static let FindUsers         = "/findusers"
    static let AddContact        = "/addcontact"
    static let Logout            = "/user/logout"
    static let GetChats          = "/chats"
    static let GetChatMessages   = "/chats/"
    static let GetUserById       = "/user/"
    static let GetImage          = "/avatars"
    static let DeleteAccount     = "/users/me"
    static let DeactivateAccount = "/deactivate/me"
    static let DeleteAvatar      = "/users/me/avatar"
    static let RemoveContact     = "/removecontact"
    static let OnlineUsers       = "/onlineusers"
    static let HideData          = "/hidedata"
    static let CheckUsername     = "/usernameExists"
    static let GetCallHistory    = "/callhistory"
    static let RemoveCall        = "/call"
    static let ChangeEmail       = "/updatemail"
    static let VerifyEmail       = "/verifyemail"
    static let ChangePhone       = "/updatephonenumber"
    static let VerifyPhone       = "/verifyphonenumber"
    static let RegisterDevice    = "/registerdevice"
    static let ReadCalls         = "/readcallhistory"
    static let confirmRequest    = "/confirmContactRequest"
    static let DeleteRequest     = "/deleteContactRequest"
    static let GetRequests       = "/contactRequests"
    static let GetAdminMessage   = "/adminmessages"
    static let CreateChannel     = "/channel"
    static let GetChannelInfo    = "/channelsInfo"
    static let CheckChannelName  = "/checkChannelName"
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
}
