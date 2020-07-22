//
//  Endpoints.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation


public enum HomeApi {
    case getUserContacts
    case findUsers(term: String)
    case addContact(id: String)
    case logout
    case getChats
    case getChatMessages(id: String)
    case getUserById(id: String)
    case getImage(avatar: String)
    case deleteAccount
    case deactivateAccount
    case deleteAvatar
    case editInformation(name: String, lastname: String, username: String, phoneNumber: String, info: String, address: String, gender: String, birthDate: String)
    
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
        case .logout:
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
        case .editInformation(let name, let lastname, let username, let phoneNumber, let info, let address, let gender, let birthDate):
            return AUTHUrls.UpdateUser
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
        case .logout:
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
        case .editInformation(_, _, _, _, _, _, _, _):
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
        case .logout:
            let parameters:Parameters = [:]
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
        case .editInformation(name: let name, lastname: let lastname, username: let username, phoneNumber: let phoneNumber, info: let info, address: let address, gender: let gender, birthDate: let birthDate):
            let parameters:Parameters = ["name": name, "lastname": lastname, "username": username, "phoneNumber": phoneNumber, "info": info, "address": address, "gender": gender, "birthday": birthDate]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}


