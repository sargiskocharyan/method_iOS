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
    case getChatMessages(id: String, dateUntil: String?)
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
    case removeCall(id: [String])
    case changeEmail(email: String)
    case verifyEmail(email: String, code: String)
    case changePhone(phone: String)
    case verifyPhone(number: String, code: String)
    case registerDevice(token: String, voipToken: String)
    case readCalls(id: String, readOne: Bool)
    case confirmRequest(id: String, confirm: Bool)
    case deleteRequest(id: String)
    case getRequests
    case getAdminMessage
    case createChannel(name: String, openMode: Bool)
    case getChannelInfo(ids: [String])
    case getChannelMessages(id: String, dateUntil: String?)
    case checkChannelName(name: String)
    case subscribe(id: String)
    case findChannels(term: String)
    case leaveChannel(id: String)
    case addModerator(id: String, userId: String)
    case getModerators(id: String)
    case getSubcribers(id: String)
    case removeModerator(id: String, userId: String)
    case updateChannelInfo(id: String, name: String?, description: String?)
    case changeAdmin(id: String, userId: String)
    case deleteChannelLogo(id: String)
    case deleteChannel(id: String)
    case rejectBeModerator(id: String)
    case deleteChannelMessages(id: String, ids: [String])
    case blockSubscribers(id: String, subscribers: [String])
    case deleteChannelMessageBySender(ids: [String])
    case editChannelMessageBySender(id: String, text: String)
    case editChatMessage(messageId: String, text: String)
    case deleteChatMessages(arrayMessageIds: [String])
    case sendImageInChat(tmpImage: UIImage?, userId: String, text: String, boundary: String, tempUUID: String)
    case sendVideoInChat(videoData: Data, userId: String, text: String, boundary: String, tempUUID: String)
    case sendImageInChannel(tmpImage: UIImage?, channelId: String, text: String, boundary: String, tempUUID: String)
    case sendVideoInChannel(videoData: Data, channelId: String, text: String, boundary: String, tempUUID: String)
    case uploadChannelLogo(tmpImage: UIImage, channelId: String, boundary: String)
    case uploadAvatar(tmpImage: UIImage, boundary: String)
}

extension HomeApi: EndPointType {
    
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
        case .getChats:
            return HomeUrls.GetChats
        case .getChatMessages(let id,_):
            return  "\(HomeUrls.GetChatMessages)\(id)"
        case .getUserById(let id):
            return  "\(HomeUrls.GetUserById)\(id)"
        case .getImage(let avatar):
            return "\(HomeUrls.GetImage)/\(avatar)"
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
        case .onlineUsers(_):
            return HomeUrls.OnlineUsers
        case .hideData(_):
            return HomeUrls.HideData
        case .getCallHistory:
            return HomeUrls.GetCallHistory
        case .removeCall(_):
            return HomeUrls.RemoveCall
        case .changeEmail(_):
            return HomeUrls.ChangeEmail
        case .verifyEmail(_,_):
            return HomeUrls.VerifyEmail
        case .changePhone(_):
            return HomeUrls.ChangePhone
        case .verifyPhone(_,_):
            return HomeUrls.VerifyPhone
        case .registerDevice(_,_):
            return AUTHUrls.RegisterDevice
        case .readCalls(_,_):
            return HomeUrls.ReadCalls
        case .confirmRequest(_, _):
            return HomeUrls.confirmRequest
        case .deleteRequest(_):
            return HomeUrls.DeleteRequest
        case .getRequests:
            return HomeUrls.GetRequests
        case .getAdminMessage:
            return HomeUrls.GetAdminMessage
        case .createChannel(_,_):
            return HomeUrls.CreateChannel
        case .getChannelInfo(_):
            return "\(HomeUrls.GetChannelInfo)"
        case .getChannelMessages(let id, _):
            return "\(HomeUrls.CreateChannel)/\(id)/messages"
        case .checkChannelName(_):
            return HomeUrls.CheckChannelName
        case .subscribe(let id):
            return "\(HomeUrls.CreateChannel)/\(id)/subscribe"
        case .findChannels(_):
            return HomeUrls.FindChannels
        case .leaveChannel(let id):
            return "\(HomeUrls.CreateChannel)/\(id)/leave"
        case .addModerator(let id,_):
            return "\(HomeUrls.CreateChannel)/\(id)/addModerator"
        case .getModerators(id: let id):
            return "\(HomeUrls.CreateChannel)/\(id)/moderators"
        case .getSubcribers(let id):
            return "\(HomeUrls.CreateChannel)/\(id)/subscribers"
        case .removeModerator(id: let id, _):
            return "\(HomeUrls.CreateChannel)/\(id)/removeModerator"
        case .updateChannelInfo(id: let id, _, _):
            return "\(HomeUrls.CreateChannel)/\(id)/update"
        case .changeAdmin(id: let id,_):
            return "\(HomeUrls.CreateChannel)/\(id)/changeAdmin"
        case .deleteChannelLogo(id: let id):
            return "\(HomeUrls.CreateChannel)/\(id)/avatar"
        case .deleteChannel(id: let id):
            return "\(HomeUrls.CreateChannel)/\(id)"
        case .rejectBeModerator(id: let id):
            return "\(HomeUrls.CreateChannel)/\(id)/moderator/me"
        case .deleteChannelMessages(id: let id,_):
            return "\(HomeUrls.CreateChannel)/\(id)/deleteMessages"
        case .blockSubscribers(id: let id, _):
            return "\(HomeUrls.CreateChannel)/\(id)/blockSubscribers"
        case .deleteChannelMessageBySender(_):
            return HomeUrls.DeleteChannelMessageBySender
        case .editChannelMessageBySender(_,_):
            return HomeUrls.EditChannelMessageBySender
        case .editChatMessage(_,_):
            return HomeUrls.EditChatMessage
        case .deleteChatMessages(_):
            return HomeUrls.DeleteChatMessages
        case .sendImageInChat(_, let userId, _,_,_):
            return "\(HomeUrls.SendImageInChat)/\(userId)/imageMessage"
        case .sendVideoInChat(_, let userId, _,_,_):
            return "\(HomeUrls.SendImageInChat)/\(userId)/videoMessage"
        case .sendImageInChannel(_, let channelId, _,_,_):
            return "\(HomeUrls.SendImageInChannel)/\(channelId)/imageMessage"
        case .sendVideoInChannel(_, let channelId, _,_,_):
            return "\(HomeUrls.SendImageInChannel)/\(channelId)/videoMessage"
        case .uploadChannelLogo(_, channelId: let channelId, _):
            return "\(HomeUrls.CreateChannel)/\(channelId)/avatar"
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
        case .getChats:
            return .get
        case .getChatMessages(_,_):
            return .post
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
        case .readCalls(_,_):
            return .post
        case .confirmRequest(_, _):
            return .post
        case .deleteRequest(_):
            return .delete
        case .getRequests:
            return .get
        case .getAdminMessage:
            return .get
        case .createChannel(_,_):
            return .post
        case .getChannelInfo(_):
            return .post
        case .getChannelMessages(_,_):
            return .post
        case .checkChannelName(_):
            return .post
        case .subscribe(_):
            return .post
        case .findChannels(_):
            return .post
        case .leaveChannel(_):
            return .post
        case .addModerator(_,_):
            return .post
        case .getModerators(_):
            return .get
        case .getSubcribers(_):
            return .get
        case .removeModerator(_,_):
            return .post
        case .updateChannelInfo(_,_,_):
            return .post
        case .changeAdmin(_,_):
            return .post
        case .deleteChannelLogo(_):
            return .delete
        case .deleteChannel(_):
            return .delete
        case .rejectBeModerator(_):
            return .delete
        case .deleteChannelMessages(_,_):
            return .post
        case .blockSubscribers(_,_):
            return .post
        case .deleteChannelMessageBySender(_):
            return .post
        case .editChannelMessageBySender(_,_):
            return .post
        case .editChatMessage(_,_):
            return .post
        case .deleteChatMessages(_):
            return .post
        case .sendImageInChat(_,_,_,_,_):
            return .post
        case .sendVideoInChat(_,_,_,_,_):
            return .post
        case .sendImageInChannel(_,_,_,_,_):
            return .post
        case .sendVideoInChannel(_,_,_,_,_):
            return .post
        case .uploadChannelLogo(_,_,_):
            return .post
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
        case .getChats:
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getChatMessages(_, let dateUntil):
            var parameters: Parameters? = ["dateUntil" : dateUntil]
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            if dateUntil == nil {
                parameters = nil
            }
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
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
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .removeContact(id: let id):
            let parameters:Parameters = ["userId": id]
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
            let parameters:Parameters = ["calls": id]
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
        case .readCalls(id: let id, readOne: let readOne):
            let parameters:Parameters = ["callId": id, "readOne": readOne]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
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
        case .createChannel(name: let name, openMode: let openMode):
            let parameters:Parameters = ["name": name, "openMode": openMode]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getChannelInfo(ids: let ids):
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            let parameters:Parameters = ["ids": ids]
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getChannelMessages(_, let dateUntil):
            var parameters: Parameters? = ["dateUntil" : dateUntil]
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            if dateUntil == nil {
                parameters = nil
            }
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .checkChannelName(name: let name):
            let parameters:Parameters = ["name": name]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .subscribe(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .findChannels(term: let term):
            let parameters: Parameters = ["term": term]
            let headers: HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .leaveChannel(_):
            let headers: HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .addModerator(_, userId: let userId):
            let parameters: Parameters = ["userId": userId]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getModerators(_):
            let headers: HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getSubcribers(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .removeModerator(_, userId: let userId):
            let parameters: Parameters = ["userId": userId]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .updateChannelInfo(_, name: let name, description: let description):
            var parameters: Parameters = [:]
            parameters["name"] = name
            parameters["description"] = description
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .changeAdmin(_, userId: let userId):
            let parameters: Parameters = ["userId": userId]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteChannelLogo(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteChannel(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .rejectBeModerator(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteChannelMessages(_,ids: let arrayMessageIds):
              let parameters: Parameters = ["arrayMessageIds": arrayMessageIds]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .blockSubscribers(_, subscribers: let subscribers):
            let parameters: Parameters = ["subscribers": subscribers]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteChannelMessageBySender(ids: let ids):
            let parameters:Parameters = ["arrayMessageIds": ids]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .editChannelMessageBySender(id: let id, text: let text):
            let parameters:Parameters = ["messageId": id, "text": text]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .editChatMessage(messageId: let messageId, text: let text):
            let parameters:Parameters = ["messageId": messageId, "text" : text]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteChatMessages(arrayMessageIds: let arrayMessageIds):
            let parameters:Parameters = ["arrayMessageIds": arrayMessageIds]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .sendImageInChat(tmpImage: let image, userId: _, text: let text, boundary: let boundary, tempUUID: let tempUUID):
            let parameters:Parameters = ["tempUUID": tempUUID, "text" : text, "image": image?.jpegData(compressionQuality: 1)]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .sendVideoInChat(videoData: let videoData, userId: _, text: let text, boundary: let boundary, tempUUID: let tempUUID):
            let parameters:Parameters = ["tempUUID": tempUUID, "text" : text, "video": videoData]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .sendImageInChannel(tmpImage: let image, channelId: _, text: let text, boundary: let boundary, tempUUID: let tempUUID):
            let parameters:Parameters = ["tempUUID": tempUUID, "text" : text, "image": image?.jpegData(compressionQuality: 1)]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .sendVideoInChannel(videoData: let videoData, channelId: _, text: let text, boundary: let boundary, tempUUID: let tempUUID):
            let parameters:Parameters = ["tempUUID": tempUUID, "text" : text, "video": videoData]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .uploadChannelLogo(tmpImage: let image, channelId: _, boundary: let boundary):
            let parameters:Parameters = [ "image": image.jpegData(compressionQuality: 1)]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
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


