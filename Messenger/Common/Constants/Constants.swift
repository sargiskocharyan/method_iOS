//
//  Constants.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

struct Environment {
    static let baseURL = "https://messenger-dynamic.herokuapp.com" //"https://192.168.0.105:3000"
    static let socketUrl = "wss://messenger-dynamic.herokuapp.com"
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
}

struct AppLangKeys {
     
     static let Rus = "ru"
     static let Eng = "en"
     static let Arm = "hy"
}

struct Keys {
    static let TOKEN_KEYCHAIN_ID_KEY = "token"
    static let APP_Language = "appLanguage"
}
