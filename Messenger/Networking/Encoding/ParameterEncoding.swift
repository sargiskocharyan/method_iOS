//
//  ParameterEncoding.swift
//
//  Created by sargis on 3/02/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation

public typealias Parameters = [String:Any?]

public protocol ParameterEncoder {
    func encode(urlRequest: inout URLRequest, with parameters: Parameters, encrypted:Bool) throws
}

public enum ParameterEncoding {
    
    case urlEncoding
    case jsonEncoding
    case jsonEncodingEncrypted
    case urlAndJsonEncoding
    case bodyUrlEncoding
    
    public func encode(urlRequest: inout URLRequest,
                       bodyParameters: Parameters?,
                       urlParameters: Parameters?,
                       encrypted:Bool) throws {
        do {
            switch self {
            case .urlEncoding:
                guard let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                
            case .jsonEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters, encrypted: false)
            case .jsonEncodingEncrypted:
                guard let bodyParameters = bodyParameters else { return }
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters, encrypted: true)
            case .urlAndJsonEncoding:
                guard let bodyParameters = bodyParameters,
                    let urlParameters = urlParameters else { return }
                try URLParameterEncoder().encode(urlRequest: &urlRequest, with: urlParameters)
                try JSONParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters, encrypted: false)
            case .bodyUrlEncoding:
                guard let bodyParameters = bodyParameters else { return }
                try BodyURLParameterEncoder().encode(urlRequest: &urlRequest, with: bodyParameters)
            }
        }catch {
            throw error
        }
    }
}


public enum NetworkError : String, Error {
    case parametersNil = "Parameters were nil."
    case encodingFailed = "Parameter encoding failed."
    case missingURL = "URL is nil."
}
