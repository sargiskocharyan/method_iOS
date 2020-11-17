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
    
    func uploadImage(tmpImage: UIImage?, completion: @escaping (NetworkResponse?, String?)->()) {
        let uuid = UUID().uuidString
        router.uploadImageRequest(.uploadAvatar(tmpImage: tmpImage!, boundary: uuid), boundary: uuid) { (data, response, error) in
            guard (response as? HTTPURLResponse) != nil else {
                completion(NetworkResponse.failed, nil)
                return }
            if error != nil {
                print(error!.rawValue)
                completion(NetworkResponse.failed, nil)
            } else {
                guard let responseData = data else {
                    completion(NetworkResponse.noData, nil)
                    return
                }
                completion(nil, String(data: responseData, encoding: .utf8))
                return
            }
        }
    }
    
    func sendImageInChannel(tmpImage: UIImage?, channelId: String, text: String, tempUUID: String, boundary: String, completion: @escaping (NetworkResponse?)->()) {
            router.uploadImageRequest(.sendImageInChannel(tmpImage: tmpImage, channelId: channelId, text: text, boundary: boundary, tempUUID: tempUUID), boundary: boundary) { (data, response, error) in
                guard (response as? HTTPURLResponse) != nil else {
                    completion(NetworkResponse.failed)
                    return }
                if error != nil {
                    completion(NetworkResponse.failed)
                } else {
                    completion(nil)
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
    
    func sendImageInChat(tmpImage: UIImage?, userId: String, text: String, tempUUID: String, boundary: String, completion: @escaping (NetworkResponse?)->()) {
        router.uploadImageRequest(.sendImageInChat(tmpImage: tmpImage, userId: userId, text: text, boundary: boundary, tempUUID: tempUUID), boundary: boundary) { (data, response, error) in
            guard (response as? HTTPURLResponse) != nil else {
                completion(NetworkResponse.failed)
                return }
            if error != nil {
                completion(NetworkResponse.failed)
            } else {
                completion(nil)
            }
        }
    }
    
    func sendVideoInChat(data: Data, id: String, text: String, tempUUID: String, boundary: String, completion: @escaping (NetworkResponse?)->()) {
        router.uploadImageRequest(.sendVideoInChat(videoData: data, userId: id, text: text, boundary: boundary, tempUUID: tempUUID), boundary: boundary) { (data, response, error) in
            guard (response as? HTTPURLResponse) != nil else {
                completion(NetworkResponse.failed)
                return }
            if error != nil {
                completion(NetworkResponse.failed)
            } else {
                completion(nil)
            }
        }
    }
    
    func sendVideoInChannel(data: Data, channelId: String, text: String, uuid: String, completion: @escaping (NetworkResponse?)->()) {
        router.uploadImageRequest(.sendVideoInChannel(videoData: data, channelId: channelId, text: text, boundary: uuid, tempUUID: uuid), boundary: uuid) { (data, response, error) in
            guard (response as? HTTPURLResponse) != nil else {
                completion(NetworkResponse.failed)
                return }
            if error != nil {
                completion(NetworkResponse.failed)
            } else {
                completion(nil)
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
    
    func uploadChannelImage(tmpImage: UIImage?, id: String, completion: @escaping (NetworkResponse?, String?)->()) {
        if let tmpImage = tmpImage {
            let uuid = UUID().uuidString
            router.uploadImageRequest(.uploadChannelLogo(tmpImage: tmpImage, channelId: id, boundary: uuid), boundary: uuid) { (data, response, error) in
                guard (response as? HTTPURLResponse) != nil else {
                    completion(NetworkResponse.failed, nil)
                    return }
                if error != nil {
                    print(error!.rawValue)
                    completion(NetworkResponse.failed, nil)
                } else {
                    guard let responseData = data else {
                        completion(NetworkResponse.noData, nil)
                        return
                    }
                    completion(nil, String(data: responseData, encoding: .utf8))
                    return
                }
            }
        }
        
    }
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: .utf8)
        append(data!)
    }
}
