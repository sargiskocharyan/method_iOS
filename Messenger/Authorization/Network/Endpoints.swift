//
//  Endpoints.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation


public enum AuthApi {
    case beforeLogin(email: String)
    case login(email: String, code:String)
    case register(email: String, code: String)
    case updateUser(name: String?, lastname: String?, username: String?, gender: String?)
    case verifyToken(token: String)
    case getUserContacts(token: String)
    case checkUsername(username: String)
    case loginWithFacebook(accessToken: String)
    case loginWithPhoneNumber(number: String)
}

extension AuthApi: EndPointType {
    
    var baseURL: URL {
        guard let url = URL(string: Environment.baseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .beforeLogin(_):
            return AUTHUrls.MailisExist
        case .login(_,_):
            return AUTHUrls.Login
        case .register(_,_):
            return AUTHUrls.Register
        case .updateUser(_,_,_,_):
            return AUTHUrls.UpdateUser
        case .verifyToken(_):
            return AUTHUrls.VerifyToken
        case .getUserContacts(_):
            return HomeUrls.GetUserContacts
        case .checkUsername(_):
            return AUTHUrls.CheckUsername
        case .loginWithFacebook(_):
            return AUTHUrls.LoginWithFacebook
        case .loginWithPhoneNumber(_):
            return AUTHUrls.LoginWithPhoneNumber
        }
    }
    
    var httpMethod: HTTPMethod {
        
        switch self {
        case .beforeLogin(_):
            return .post
        case .login(_,_):
            return .post
        case .register(_,_):
            return .post
        case .updateUser(_,_,_,_):
            return .post
        case .verifyToken(_):
            return .post
        case .getUserContacts(_):
            return .get
        case .checkUsername(_):
            return .post
        case .loginWithFacebook(_):
            return .post
        case .loginWithPhoneNumber(_):
            return .post
        }
    }
    
    var task: HTTPTask {
        let endPointManager = EndPointManager()
        switch self {
        case .beforeLogin(email: let email):
            let parameters:Parameters = ["email": email]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  nil)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .login(email: let email, code: let code):
            let parameters:Parameters = ["email": email, "code": code]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  nil)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .register(email: let email, code: let code):
            let parameters:Parameters = ["email": email, "code": code]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  nil)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .updateUser(name: let name, lastname: let lastname, username: let username, gender: let gender):
            let allParameters:Parameters = ["name": name, "lastname": lastname, "username": username, "gender": gender]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token)
            var parameters: Dictionary<String,Any> = [:]
            for (key, value) in allParameters {
                if value != nil && value as! String != "" {
                    parameters[key] = value
                }
            }
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .verifyToken(token: let token):
            let parameters:Parameters = [:]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getUserContacts(token: let token):
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .checkUsername(username: let username):
            let parameters:Parameters = ["username": username]
            let headers:HTTPHeaders = endPointManager.createHeaders(token: nil)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .loginWithFacebook(accessToken: let accessToken):
            let parameters:Parameters = ["accessToken": accessToken]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .loginWithPhoneNumber(number: let number):
            let parameters:Parameters = ["phoneNumber": number]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: nil)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
}


