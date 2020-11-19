//
//  Router.swift
//
//  Created by sargis on 03/02/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import UIKit

typealias NetworkRouterCompletion = (_ data: Data?,_ response: URLResponse?,_ error: NetworkResponse?)->()

protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

class Router<EndPoint: EndPointType>: NetworkRouter {
    private var task: URLSessionTask?
    
    func request(_ route: EndPoint, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 80
        do {
            let request = try self.buildRequest(from: route)
            NetworkLogger.log(request: request)
            task = session.dataTask(with: request, completionHandler: { data, response, error in
                if error != nil {
                    completion(data, response, NetworkResponse.failed)
                } else {
                    completion(data, response, nil)
                }
            })
        } catch {
            completion(nil, nil, NetworkResponse.badRequest)
        }
        self.task?.resume()
    }
    
    func uploadImageRequest(_ route: EndPoint, boundary: String, completion: @escaping NetworkRouterCompletion) {
        let session = URLSession.shared
        session.configuration.timeoutIntervalForRequest = 80
        let request = self.buildUploadImageRequest(from: route, boundary: boundary)
        NetworkLogger.log(request: request)
        task = session.dataTask(with: request)  { data, response, error in
            if error != nil {
                completion(data, response, NetworkResponse.failed)
            } else {
                completion(data, response, nil)
            }
        }
        self.task?.resume()
    }
    
    func cancel() {
        self.task?.cancel()
    }
    
    fileprivate func configureFormDataBody(_ bodyParameters: Parameters?, _ boundary: String) -> Data {
        let body = NSMutableData()
        for parameter in bodyParameters! {
            if let stringValue = (parameter.value as? String) {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition:form-data; name=\"\(parameter.key)\"\r\n")
                body.appendString("\r\n\(stringValue)\r\n")
            } else if parameter.key == "image" {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition:form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
                body.appendString("Content-Type: image/jpg\r\n\r\n")
                body.append(parameter.value as! Data)
                body.appendString("\r\n")
            } else if parameter.key == "video" {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition:form-data; name=\"video\"; filename=\"video.mp4\"\r\n")
                body.appendString("Content-Type: video/mp4\r\n\r\n")
                body.append(parameter.value as! Data)
                body.appendString("\r\n")
            }
        }
        body.appendString("--\(boundary)--\r\n")
        return body as Data
    }
    
    fileprivate func buildUploadImageRequest(from route: EndPoint, boundary: String) -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60.0)
        request.httpMethod = route.httpMethod.rawValue
        switch route.task {
        case .request:
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
        case .requestParameters(let bodyParameters, _, _):
            request.httpBody = configureFormDataBody(bodyParameters, boundary)
        case .requestParametersAndHeaders(let bodyParameters, _, _, let additionalHeaders):
            request.httpBody = configureFormDataBody(bodyParameters, boundary)
            addAdditionalHeaders(additionalHeaders, request: &request)
        }
        return request
    }
    
   
    
    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {
        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 60.0)
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):
                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }
    
    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest,
                                         encrypted: Bool = false) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters, encrypted:encrypted )
        } catch {
            throw error
        }
    }
    
    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
}

