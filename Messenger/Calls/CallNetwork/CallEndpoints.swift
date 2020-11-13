//
//  CallEndpoints.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

public enum CallApi {
    case readCalls(id: String, readOne: Bool)
    case getCallHistory
    case removeCall(id: [String])
}

extension CallApi: EndPointType {
    var baseURL: URL {
        guard let url = URL(string: Environment.baseURL) else { fatalError("baseURL could not be configured.")}
        return url
    }
    
    var path: String {
        switch self {
        case .readCalls(_,_):
            return HomeUrls.ReadCalls
        case .getCallHistory:
            return HomeUrls.GetCallHistory
        case .removeCall(_):
            return HomeUrls.RemoveCall
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .readCalls(_,_):
            return .post
        case .getCallHistory:
            return .get
        case .removeCall(_):
            return .delete
        }
    }
    
    var task: HTTPTask {
        let user = SharedConfigs.shared.signedUser
        let endPointManager = EndPointManager()
        let token = user?.token
        switch self {
        case .readCalls(id: let id, readOne: let readOne):
            let parameters:Parameters = ["callId": id, "readOne": readOne]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  SharedConfigs.shared.signedUser?.token ?? "")
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .getCallHistory:
            let headers:HTTPHeaders = endPointManager.createHeaders(token: token)
            return .requestParametersAndHeaders(bodyParameters: nil, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        case .removeCall(id: let id):
            let parameters:Parameters = ["calls": id]
            let headers:HTTPHeaders = endPointManager.createHeaders(token:  token)
            return .requestParametersAndHeaders(bodyParameters: parameters, bodyEncoding: .jsonEncoding, urlParameters: nil, additionHeaders: headers)
        }
    }
    
    var headers: HTTPHeaders? {
        return nil
    }
}
