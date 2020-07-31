//
//  BodyURLParameterEncoding.swift
//
//  Created by sargis on 03/02/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation

public struct BodyURLParameterEncoder: ParameterEncoder {
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters, encrypted: Bool = false) throws {
        
        var bodyString = ""
        for (key,value)in parameters {
            let item = "\(key)=\(value ?? "")&"
            bodyString += item
        }
        
        let bodyStr = String(bodyString.dropLast())
        let bodyData = bodyStr.data(using: .utf8)
        urlRequest.httpBody = bodyData
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
    }
}
