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

class NetworkManager {
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
