//
//  ProfileEndpoints.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

public enum ProfileApi {
    case getUserContacts
    case findUsers(term: String)
    case addContact(id: String)
    case logout(deviceUUID: String)
    case deleteAccount
    case deactivateAccount
    case deleteAvatar
    case editInformation(name: String?, lastname: String?, username: String?, info: String?, gender: String?, birthDate: String?)
    case removeContact(id: String)
    case hideData(isHideData: Bool)
    case changeEmail(email: String)
    case verifyEmail(email: String, code: String)
    case changePhone(phone: String)
    case verifyPhone(number: String, code: String)
    case confirmRequest(id: String, confirm: Bool)
    case deleteRequest(id: String)
    case getRequests
    case getAdminMessage
    case getImage(avatar: String)
    case uploadAvatar(tmpImage: UIImage, boundary: String)
}

extension ProfileApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: Environment.baseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .getUserContacts:
            return HomeUrls.GetUserContacts
        case .findUsers(_):
            return HomeUrls.FindUsers
        case .addContact(_):
            return HomeUrls.AddContact
        case .logout(_):
            return HomeUrls.Logout
        case .deleteAccount:
            return HomeUrls.DeleteAccount
        case .deactivateAccount:
            return HomeUrls.DeactivateAccount
        case .deleteAvatar:
            return HomeUrls.DeleteAvatar
        case .editInformation(_, _, _, _, _, _):
            return AUTHUrls.UpdateUser
        case .removeContact(_):
            return HomeUrls.RemoveContact
        case .hideData(_):
            return HomeUrls.HideData
        case .changeEmail(_):
            return HomeUrls.ChangeEmail
        case .verifyEmail(_,_):
            return HomeUrls.VerifyEmail
        case .changePhone(_):
            return HomeUrls.ChangePhone
        case .verifyPhone(_,_):
            return HomeUrls.VerifyPhone
        case .confirmRequest(_, _):
            return HomeUrls.confirmRequest
        case .deleteRequest(_):
            return HomeUrls.DeleteRequest
        case .getRequests:
            return HomeUrls.GetRequests
        case .getAdminMessage:
            return HomeUrls.GetAdminMessage
        case .getImage(let avatar):
            return "\(HomeUrls.GetImage)/\(avatar)"
        case .uploadAvatar(_,_):
            return HomeUrls.UploadAvatar
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
        case .hideData(_):
            return .post
        case .changeEmail(_):
            return .post
        case .verifyEmail(_,_):
            return .post
        case .changePhone(_):
            return .post
        case .verifyPhone(_,_):
            return .post
        case .confirmRequest(_, _):
            return .post
        case .deleteRequest(_):
            return .delete
        case .getRequests:
            return .get
        case .getAdminMessage:
            return .get
        case .getImage(_):
            return .get
        case .uploadAvatar(_,_):
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
            let parameters:Parameters = ["userId": id]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .hideData(isHideData: let isHideData):
            let parameters:Parameters = ["hide": isHideData]
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
        case .confirmRequest(id: let id, confirm: let confirm):
            let parameters:Parameters = ["userId": id, "confirm" : confirm]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteRequest(id: let id):
            let parameters:Parameters = ["contactId": id]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getRequests:
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getAdminMessage:
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getImage(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .uploadAvatar(tmpImage: let image, boundary: let boundary):
            let parameters:Parameters = [ "image": image.jpegData(compressionQuality: 1)]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
