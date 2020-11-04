//
//  ResponseModels.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/5/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    var token: String
    var tokenExpire: String
    var user: UserModel
}

struct ChangeEmailResponse: Codable {
    var user: UserModel
}

struct CheckUsername: Codable {
    let usernameExists: Bool
}

struct MailExistsResponse: Codable {
    var mailExist: Bool
    var code: String?
}

struct PhoneExistsResponse: Codable {
    var phonenumberExists: Bool
    var code: String
}

struct ErrorResponse: Codable {
    var Error: String?
}

struct CallHistory: Codable, Hashable {
    var type: String?
    var receiver: String?
    var status: String?
    var participants: [String?]?
    var callSuggestTime: String?
    var _id: String?
    var createdAt: String?
    var caller: String?
    var callEndTime: String?
    var callStartTime: String?
}

struct VerifyTokenResponse: Codable {
    let tokenExists: Bool
}

struct UpdateUserModel: Codable {
    let _id: String
    let name: String
    let email: String
    let lastname: String
    let username: String
    let university: University
}

struct UniversityResponse: Codable {
    let universites: [University]
}

struct University: Codable {
    let _id: String
    let name: String
    let city: String
    let nameRU: String
    let nameEN: String
}

