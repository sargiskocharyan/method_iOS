//
//  ChannelEndpoints.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

public enum ChannelApi {
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
}

extension ChannelApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: Environment.baseURL) else { fatalError("baseURL could not be configured.")}
        return url
        
    }
    var path: String {
        switch self {
        case .createChannel(_,_):
            return ChannelUrls.CreateChannel
        case .getChannelInfo(_):
            return "\(ChannelUrls.GetChannelInfo)"
        case .getChannelMessages(let id, _):
            return "\(ChannelUrls.CreateChannel)/\(id)/messages"
        case .checkChannelName(_):
            return ChannelUrls.CheckChannelName
        case .subscribe(let id):
            return "\(ChannelUrls.CreateChannel)/\(id)/subscribe"
        case .findChannels(_):
            return ChannelUrls.FindChannels
        case .leaveChannel(let id):
            return "\(ChannelUrls.CreateChannel)/\(id)/leave"
        case .addModerator(let id,_):
            return "\(ChannelUrls.CreateChannel)/\(id)/addModerator"
        case .getModerators(id: let id):
            return "\(ChannelUrls.CreateChannel)/\(id)/moderators"
        case .getSubcribers(let id):
            return "\(ChannelUrls.CreateChannel)/\(id)/subscribers"
        case .removeModerator(id: let id, _):
            return "\(ChannelUrls.CreateChannel)/\(id)/removeModerator"
        case .updateChannelInfo(id: let id, _, _):
            return "\(ChannelUrls.CreateChannel)/\(id)/update"
        case .changeAdmin(id: let id,_):
            return "\(ChannelUrls.CreateChannel)/\(id)/changeAdmin"
        case .deleteChannelLogo(id: let id):
            return "\(ChannelUrls.CreateChannel)/\(id)/avatar"
        case .deleteChannel(id: let id):
            return "\(ChannelUrls.CreateChannel)/\(id)"
        case .rejectBeModerator(id: let id):
            return "\(ChannelUrls.CreateChannel)/\(id)/moderator/me"
        case .deleteChannelMessages(id: let id,_):
            return "\(ChannelUrls.CreateChannel)/\(id)/deleteMessages"
        case .blockSubscribers(id: let id, _):
            return "\(ChannelUrls.CreateChannel)/\(id)/blockSubscribers"
        case .deleteChannelMessageBySender(_):
            return ChannelUrls.DeleteChannelMessageBySender
        case .editChannelMessageBySender(_,_):
            return ChannelUrls.EditChannelMessageBySender
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
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
        }
    }
    
    var task: HTTPTask {
        let user = SharedConfigs.shared.signedUser
        let endPointManager = EndPointManager()
        let token = user?.token
        switch self {
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
            
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
    
    
    
    
}
