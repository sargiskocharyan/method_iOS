//
//  AuthNetworkManager.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import UIKit
import AVFoundation

class HomeNetworkManager: NetworkManager, URLSessionDelegate, StreamDelegate {
    
    let router = Router<HomeApi>()
    
    func getuserById(id: String,  completion: @escaping (User?, NetworkResponse?)->()) {
        router.request(.getUserById(id: id)) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(nil, error)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, error)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(User.self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                    completion(nil, NetworkResponse.failed)
                }
            }
        }
    }
    
    func registerDevice(token: String, voipToken: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.registerDevice(token: token, voipToken: voipToken)) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(error)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    completion(nil)
                case .failure( _):
                    completion(NetworkResponse.failed)
                }
            }
        }
    }
    
    func downloadVideo(from url: String, isNeedAllBytes: Bool, completion: @escaping (NetworkResponse?, Data?) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if !isNeedAllBytes {
            let a = 1024 * 1024
            request.setValue("bytes=0-\(a)", forHTTPHeaderField: "Range")
        }
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard (response as? HTTPURLResponse) != nil else {
                completion(NetworkResponse.failed, nil)
                return }
            if error != nil {
                print(error!.localizedDescription)
                completion(NetworkResponse.failed, nil)
            } else {
                guard let responseData = data else {
                    completion(NetworkResponse.noData, nil)
                    return
                }
                completion(nil, responseData)
                return
            }
        }.resume()
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: .utf8)
        append(data!)
    }
}
