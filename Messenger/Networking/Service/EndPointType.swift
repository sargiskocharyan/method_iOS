//
//  EndPoint.swift
//
//  Created by sargis on 03/02/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation

protocol EndPointType {
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

class EndPointManager {
    
    func createHeaders(token: String?) -> HTTPHeaders {
        var headers:HTTPHeaders = [String: String]()
        
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "application/json"
      
        
        //headers["Cache-Control"] = "no-cache"
        if token != nil {
            headers["Authorization"] =  "\(token!)"
        }
        
        return headers
    }
    
    func createUploadTaskHeaders(token: String?, boundary: String) -> HTTPHeaders {
        var headers:HTTPHeaders = [String: String]()
        headers["Accept"] = "application/json"
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
      
        
        //headers["Cache-Control"] = "no-cache"
        if token != nil {
            headers["Authorization"] =  "\(token!)"
        }
        
        return headers
    }
    
    func isRequestEncrypable(tail:String, method: HTTPMethod) -> Bool {
        if method == .post {
//            if  tail == AuthURLs.Register || tail == AuthURLs.LoginUser {
//                return false
//            }
//            else {
//                return true
//            }
        }
        return false
    }

   
}
