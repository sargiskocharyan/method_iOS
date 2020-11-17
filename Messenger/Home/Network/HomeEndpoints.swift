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
    case getUserById(id: String)
    case registerDevice(token: String, voipToken: String)
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
        case .getUserById(let id):
            return  "\(HomeUrls.GetUserById)\(id)"
        case .registerDevice(_,_):
            return AUTHUrls.RegisterDevice
            
        case .sendImageInChat(_, let userId, _,_,_):
            return "\(HomeUrls.SendImageInChat)/\(userId)/imageMessage"
        case .sendVideoInChat(_, let userId, _,_,_):
            return "\(HomeUrls.SendImageInChat)/\(userId)/videoMessage"
        case .sendImageInChannel(_, let channelId, _,_,_):
            return "\(HomeUrls.SendImageInChannel)/\(channelId)/imageMessage"
        case .sendVideoInChannel(_, let channelId, _,_,_):
            return "\(HomeUrls.SendImageInChannel)/\(channelId)/videoMessage"
        case .uploadChannelLogo(_, channelId: let channelId, _):
            return "\(ChannelUrls.CreateChannel)/\(channelId)/avatar"
        case .uploadAvatar(_,_):
            return HomeUrls.UploadAvatar
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getUserById(_):
            return .get
        case .registerDevice(_,_):
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
        case .getUserById(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .registerDevice(token: let token, voipToken: let voipToken):
            let parameters:Parameters = ["deviceUUID": UIDevice.current.identifierForVendor?.uuidString, "token": token, "voIPToken": voipToken, "platform": "ios"]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
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


