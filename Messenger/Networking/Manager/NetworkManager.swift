//
//  NetworkManager.swift
//
//  Created by sargis on 03/02/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import UIKit

enum NetworkResponse:String {
    case success
    case authenticationError = "You need to be authenticated first."
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
}

enum Result<String>{
    case success
    case failure(String)
}

class NetworkManager: NSObject {
    static let environment : NetworkEnvironment = .production
    
    func downloadImage(imageUrl:String,completion: @escaping (_ data: Data?, _ error: Error?)->()) {
        if let url = URL(string: imageUrl) {
            getDataFromUrl(url: url) { data, response, error in
                guard let data = data, error == nil else {
                    completion(nil, error)
                    return
                }
                completion(data, nil)
            }
        }
    }
    
    func sendImageInChat(tmpImage: UIImage?, userId: String, text: String, uuid: String, completion: @escaping (NetworkResponse?)->()) {
        guard let image = tmpImage else { return }
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(Environment.baseURL)/chatMessages/\(userId)/imageMessage")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(SharedConfigs.shared.signedUser?.token, forHTTPHeaderField: "Authorization")
        let body = NSMutableData()
        body.appendString("\r\n--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"text\"\r\n\r\n")
        body.appendString(text)
        body.appendString("\r\n--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"tempUUID\"\r\n\r\n")
        body.appendString(uuid)
        body.appendString("\r\n--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n")
        body.appendString("Content-Type: image/jpg\r\n\r\n")
        body.append(image.jpegData(compressionQuality: 1)!)
        body.appendString("\r\n--\(boundary)--\r\n")
        let session = URLSession.shared
        session.uploadTask(with: request, from: body as Data)  { data, response, error in
            print(request.httpBody as Any)
            guard (response as? HTTPURLResponse) != nil else {
                completion(NetworkResponse.failed)
                return }
            if error != nil {
                print(error!.localizedDescription)
                completion(NetworkResponse.failed)
            } else {
                guard data != nil else {
                    completion(NetworkResponse.noData)
                    return
                }
                completion(nil)
            }
        }.resume()
    }
    
    func uploadImage(imageUrl: String, text: String, completion: @escaping (_ data: Data?, _ error: Error?)->()) {
        
    }
    
    private func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }    
    
    func handleNetworkResponse(_ response: HTTPURLResponse) -> Result<String>{
        print("status code: \(response.statusCode)")
        switch response.statusCode {
        case 200...299: return .success
        case 401...403: return .failure(NetworkResponse.authenticationError.rawValue)
        case 404...499: return .failure(NetworkResponse.failed.rawValue)
        case 500...599: return .failure(NetworkResponse.badRequest.rawValue)
        case 600: return .failure(NetworkResponse.outdated.rawValue)
        default: return .failure(NetworkResponse.failed.rawValue)
        }
    }
    
}
