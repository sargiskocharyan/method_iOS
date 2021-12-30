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
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .getUserById(_):
            return .get
        case .registerDevice(_,_):
            return .post
        }
    }
    
    var task: HTTPTask {
        let user = SharedConfigs.shared.signedUser
        let endPointManager = EndPointManager()
        let _ = user?.token
        switch self {
        case .getUserById(_):
            let headers:HTTPHeaders = endPointManager.createHeaders(token: SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .registerDevice(token: let token, voipToken: let voipToken):
            let parameters:Parameters = ["deviceUUID": UIDevice.current.identifierForVendor?.uuidString, "token": token, "voIPToken": voipToken, "platform": "ios"]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}


