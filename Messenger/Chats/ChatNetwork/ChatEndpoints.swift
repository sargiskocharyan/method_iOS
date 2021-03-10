//
//  ChatEndpoints.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

public enum ChatApi {
    case getChats
    case getChatMessages(id: String, dateUntil: String?)
    case editChatMessage(messageId: String, text: String)
    case deleteChatMessages(arrayMessageIds: [String])
    case onlineUsers(arrayOfId: [String])
    case sendImageInChat(tmpImage: UIImage?, userId: String, text: String, boundary: String, tempUUID: String)
    case sendVideoInChat(videoData: Data, userId: String, text: String, boundary: String, tempUUID: String)
}

extension ChatApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: Environment.baseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .getChats:
            return HomeUrls.GetChats
        case .getChatMessages(let id,_):
            return  "\(HomeUrls.GetChatMessages)\(id)"
        case .editChatMessage(_,_):
            return HomeUrls.EditChatMessage
        case .deleteChatMessages(_):
            return HomeUrls.DeleteChatMessages
        case .onlineUsers(_):
            return HomeUrls.OnlineUsers
        case .sendImageInChat(_, let userId, _,_,_):
            return "\(HomeUrls.SendImageInChat)/\(userId)/imageMessage"
        case .sendVideoInChat(_, let userId, _,_,_):
            return "\(HomeUrls.SendImageInChat)/\(userId)/videoMessage"
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getChats:
            return .get
        case .getChatMessages(_,_):
            return .post
        case .editChatMessage(_,_):
            return .post
        case .deleteChatMessages(_):
            return .post
        case .onlineUsers(_):
            return .post
        case .sendImageInChat(_,_,_,_,_):
            return .post
        case .sendVideoInChat(_,_,_,_,_):
            return .post
        }
    }
    
    var task: HTTPTask {
        let user = SharedConfigs.shared.signedUser
        let endPointManager = EndPointManager()
        let token = user?.token
        switch self {
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
        case .editChatMessage(messageId: let messageId, text: let text):
            let parameters:Parameters = ["messageId": messageId, "text" : text]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .deleteChatMessages(arrayMessageIds: let arrayMessageIds):
            let parameters:Parameters = ["arrayMessageIds": arrayMessageIds]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .onlineUsers(arrayOfId: let arrayOfId):
            let parameters:Parameters = ["usersArray": arrayOfId]
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .sendImageInChat(tmpImage: let image, userId: _, text: let text, boundary: let boundary, tempUUID: let tempUUID):
            let parameters:Parameters = ["tempUUID": tempUUID, "text" : text, "image": image?.jpegData(compressionQuality: 1)]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .sendVideoInChat(videoData: let videoData, userId: _, text: let text, boundary: let boundary, tempUUID: let tempUUID):
            let parameters:Parameters = ["tempUUID": tempUUID, "text" : text, "video": videoData]
            let headers:HTTPHeaders = endPointManager.createUploadTaskHeaders(token: token, boundary: boundary)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    
}
