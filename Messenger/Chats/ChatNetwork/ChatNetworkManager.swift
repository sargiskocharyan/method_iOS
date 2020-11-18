//
//  ChatNetworkManager.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit.UIImage

class ChatNetworkManager: NetworkManager {
    
    
    let router = Router<ChatApi>()
    
    func getChats(completion: @escaping (Chats?, NetworkResponse?)->()) {
        router.request(.getChats) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(Chats.self, from: responseData)
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
    
    func getChatMessages(id: String, dateUntil: String?, completion: @escaping (Messages?, NetworkResponse?)->()) {
        router.request(.getChatMessages(id: id, dateUntil: dateUntil)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(Messages.self, from: responseData)
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
    
    func editChatMessage(messageId: String, text: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.editChatMessage(messageId: messageId, text: text)) { data, response, error in
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
    
    func deleteChatMessages(arrayMessageIds: [String], completion: @escaping (NetworkResponse?)->()) {
        router.request(.deleteChatMessages(arrayMessageIds: arrayMessageIds)) { data, response, error in
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
    
    func onlineUsers(arrayOfId: [String],  completion: @escaping (OnlineUsers?, NetworkResponse?)->()) {
        router.request(.onlineUsers(arrayOfId: arrayOfId)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(OnlineUsers.self, from: responseData)
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
    
}
