//
//  Endpoints.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation
import UIKit.UIDevice

public enum HomeApi {
    case getUserContacts
    case findUsers(term: String)
    case addContact(id: String)
    case logout(deviceUUID: String)
    case getChats
    case getChatMessages(id: String)
    case getUserById(id: String)
    case getImage(avatar: String)
    case deleteAccount
    case deactivateAccount
    case deleteAvatar
    case editInformation(name: String?, lastname: String?, username: String?, info: String?, gender: String?, birthDate: String?)
    case removeContact(id: String)
    case onlineUsers(arrayOfId: [String])
    case hideData(isHideData: Bool)
    case getCallHistory
    case removeCall(id: String)
    case changeEmail(email: String)
    case verifyEmail(email: String, code: String)
    case changePhone(phone: String)
    case verifyPhone(number: String, code: String)
    case registerDevice(token: String, voipToken: String)
    case readCalls(id: String)
    case confirmRequest(id: String, confirm: Bool)
}

extension HomeApi: EndPointType {
    
    var baseURL: URL {
        guard let url = URL(string: Environment.baseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .getUserContacts:
            return AUTHUrls.GetUserContacts
        case .findUsers(_):
            return AUTHUrls.FindUsers
        case .addContact(_):
            return AUTHUrls.AddContact
        case .logout(_):
            return AUTHUrls.Logout
        case .getChats:
            return AUTHUrls.GetChats
        case .getChatMessages(let id):
            return  "\(AUTHUrls.GetChatMessages)\(id)"
        case .getUserById(let id):
            return  "\(AUTHUrls.GetUserById)\(id)"
        case .getImage(let avatar):
            return "\(AUTHUrls.GetImage)/\(avatar)"
        case .deleteAccount:
            return AUTHUrls.DeleteAccount
        case .deactivateAccount:
            return AUTHUrls.DeactivateAccount
        case .deleteAvatar:
            return AUTHUrls.DeleteAvatar
        case .editInformation(_, _, _, _, _, _):
            return AUTHUrls.UpdateUser
        case .removeContact(_):
            return AUTHUrls.RemoveContact
        case .onlineUsers(_):
            return AUTHUrls.OnlineUsers
        case .hideData(_):
            return AUTHUrls.HideData
        case .getCallHistory:
            return AUTHUrls.GetCallHistory
        case .removeCall(_):
            return AUTHUrls.RemoveCall
        case .changeEmail(_):
            return AUTHUrls.ChangeEmail
        case .verifyEmail(_,_):
            return AUTHUrls.VerifyEmail
        case .changePhone(_):
            return AUTHUrls.ChangePhone
        case .verifyPhone(_,_):
            return AUTHUrls.VerifyPhone
        case .registerDevice(_,_):
            return AUTHUrls.RegisterDevice
        case .readCalls(_):
            return AUTHUrls.ReadCalls
        case .confirmRequest(_, _):
            return AUTHUrls.confirmRequest
        }
    }
    
    var httpMethod: HTTPMethod {
        
        switch self {
        case .getUserContacts:
            return .get
        case .findUsers(_):
            return .post
        case .addContact(_):
            return .post
        case .logout(_):
            return .post
        case .getChats:
            return .get
        case .getChatMessages(_):
            return .get
        case .getUserById(_):
            return .get
        case .getImage(_):
            return .get
        case .deleteAccount:
            return .delete
        case .deactivateAccount:
            return .post
        case .deleteAvatar:
            return .delete
        case .editInformation(_, _, _, _, _, _):
            return .post
        case .removeContact(_):
            return .post
        case .onlineUsers(_):
            return .post
        case .hideData(_):
            return .post
        case .getCallHistory:
            return .get
        case .removeCall(_):
            return .delete
        case .changeEmail(_):
            return .post
        case .verifyEmail(_,_):
            return .post
        case .changePhone(_):
            return .post
        case .verifyPhone(_,_):
            return .post
        case .registerDevice(_,_):
            return .post
        case .readCalls(_):
            return .post
        case .confirmRequest(_, _):
            return .post
        }
    }
    
    var task: HTTPTask {
        let user = SharedConfigs.shared.signedUser
        let endPointManager = EndPointManager()
        let token = user?.token
        switch self {
        case .getUserContacts:
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .findUsers(term: let term):
            let parameters:Parameters = ["term": term]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .addContact(id: let id):
            let parameters:Parameters = ["contactId": id]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .logout(deviceUUID: let deviceUUID):
            let parameters:Parameters = ["deviceUUID" : deviceUUID]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getChats:
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getChatMessages(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getUserById(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getImage(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteAccount:
            let parameters:Parameters = [:]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deactivateAccount:
            let parameters:Parameters = [:]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteAvatar:
            let parameters:Parameters = [:]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .editInformation(name: let name, lastname: let lastname, username: let username, info: let info, gender: let gender, birthDate: let birthDate):
            let allParameters: Parameters = ["name": name, "lastname": lastname, "username": username, "info": info, "gender": gender, "birthday": birthDate]
            var parameters:Parameters = [:]
            for (key, value) in allParameters {
                if (value as? String) != nil {
                    if value as? String == "" {
                        parameters[key] = nil as Any?
                    } else {
                        parameters[key] = value
                    }
                }
            }
            print(allParameters)
            print(parameters)
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .removeContact(id: let id):
            let parameters:Parameters = ["userId": id ]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .onlineUsers(arrayOfId: let arrayOfId):
            let parameters:Parameters = ["usersArray": arrayOfId]
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .hideData(isHideData: let isHideData):
            let parameters:Parameters = ["hide": isHideData]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getCallHistory:
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .removeCall(id: let id):
            let parameters:Parameters = ["callId": id]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .changeEmail(email: let email):
            let parameters:Parameters = ["mail": email]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .verifyEmail(email: let email, code: let code):
            let parameters:Parameters = ["mail": email, "code": code]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .changePhone(phone: let phone):
            let parameters:Parameters = ["number": phone]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .verifyPhone(number: let number, code: let code):
            let parameters:Parameters = ["number": number, "code": code]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .registerDevice(token: let token, voipToken: let voipToken):
            let parameters:Parameters = ["deviceUUID": UIDevice.current.identifierForVendor?.uuidString, "token": token, "voIPToken": voipToken, "platform": "ios"]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .readCalls(id: let id):
            let parameters:Parameters = ["callId": id]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .confirmRequest(id: let id, confirm: let confirm):
            let parameters:Parameters = ["userId": id, "confirm" : confirm]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}


