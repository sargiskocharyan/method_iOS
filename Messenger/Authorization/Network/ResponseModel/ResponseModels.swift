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
    var user: UserModel
}

struct MailExistsResponse: Codable {
    var mailExist: Bool
    var code: String
}

struct ErrorResponse: Codable {
    var Error: String?
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

