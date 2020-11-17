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
    
    func sendImageInChat(tmpImage: UIImage?, userId: String, text: String, completion: @escaping (NetworkResponse?)->()) {
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
    
    func sendVideoInChat(data: Data, id: String, text: String) {
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(Environment.baseURL)/chatMessages/\(id)/videoMessage")!)
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
        body.appendString("Content-Disposition: form-data; name=\"video\"; filename=\"video.mp4\"\r\n")
        body.appendString("Content-Type: video/mp4\r\n\r\n")
        body.append(data)
        body.appendString("\r\n--\(boundary)--\r\n")
        let session = URLSession.shared
        session.uploadTask(with: request, from: body as Data)  { data, response, error in
            print(request.httpBody as Any)
            guard (response as? HTTPURLResponse) != nil else {
                return }
            if error != nil {
                print(error!.localizedDescription)
            } else {
                guard data != nil else {
                    return
                }
            }
        }.resume()
    }
}
