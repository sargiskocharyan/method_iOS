//
//  ChannelNetworkManager.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import AVFoundation

class ChannelNetworkManager: NetworkManager {
    
    let router = Router<ChannelApi>()
    
    func getChannelMessages(id: String, dateUntil: String?, completion: @escaping (ChannelMessages?, NetworkResponse?)->()) {
        router.request(.getChannelMessages(id: id, dateUntil: dateUntil)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(ChannelMessages.self, from: responseData)
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
    
    func subscribe(id: String, completion: @escaping (SubscribedResponse?, NetworkResponse?)->()) {
        router.request(.subscribe(id: id)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(SubscribedResponse.self, from: responseData)
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
    
    func deleteChannelMessages(id: String, ids: [String], completion: @escaping (NetworkResponse?)->()) {
        router.request(.deleteChannelMessages(id: id, ids: ids)) { data, response, error in
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
    
    func leaveChannel(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.leaveChannel(id: id)) { data, response, error in
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
    
    func deleteChannelMessageBySender(ids: [String], completion: @escaping (NetworkResponse?)->()) {
        router.request(.deleteChannelMessageBySender(ids: ids)) { data, response, error in
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
    
    func editChannelMessageBySender(id: String, text: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.editChannelMessageBySender(id: id, text: text)) { data, response, error in
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
    
    func getModerators(id: String, completion: @escaping ([ChannelSubscriber]?, NetworkResponse?)->()) {
        router.request(.getModerators(id: id)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([ChannelSubscriber].self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure(_):
                    completion(nil, NetworkResponse.failed)
                }
            }
        }
    }
    
    func getSubscribers(id: String, completion: @escaping ([ChannelSubscriber]?, NetworkResponse?)->()) {
        router.request(.getSubcribers(id: id)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([ChannelSubscriber].self, from: responseData)
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
    
    func addModerator(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.addModerator(id: id, userId: userId)) { data, response, error in
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
    
    func removeModerator(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.removeModerator(id: id, userId: userId)) { data, response, error in
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
    
    func uploadChannelImage(tmpImage: UIImage?, id: String, completion: @escaping (NetworkResponse?, String?)->()) {
        guard let image = tmpImage else { return }
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(Environment.baseURL)/channel/\(id)/avatar")!)
        request.httpMethod = "POST"
        request.timeoutInterval = 10
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(SharedConfigs.shared.signedUser?.token, forHTTPHeaderField: "Authorization")
        let body = NSMutableData()
        body.appendString("\r\n--\(boundary)\r\n")
        body.appendString("Content-Disposition: form-data; name=\"avatar\"; filename=\"avatar.jpg\"\r\n")
        body.appendString("Content-Type: image/jpg\r\n\r\n")
        body.append(image.jpegData(compressionQuality: 1)!)
        body.appendString("\r\n--\(boundary)--\r\n")
        let session = URLSession.shared
        session.uploadTask(with: request, from: body as Data)  { data, response, error in
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
                completion(nil, String(data: responseData, encoding: .utf8))
            }
        }.resume()
    }
    
    func changeAdmin(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.changeAdmin(id: id, userId: userId)) { data, response, error in
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
    
    func deleteChannelLogo(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.deleteChannelLogo(id: id)) { data, response, error in
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
    
    func deleteChannel(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.deleteChannel(id: id)) { data, response, error in
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
    
    func rejectBeModerator(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.rejectBeModerator(id: id)) { data, response, error in
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
    
    func blockSubscribers(id: String, subscribers: [String], completion: @escaping (NetworkResponse?)->()) {
        router.request(.blockSubscribers(id: id, subscribers: subscribers)) { data, response, error in
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
    
    func getChannelsInfo(ids: [String], completion: @escaping ([ChannelInfo]?, NetworkResponse?)->()) {
        router.request(.getChannelInfo(ids: ids)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([ChannelInfo].self, from: responseData)
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
    
    func findChannels(term: String, completion: @escaping ([ChannelInfo]?, NetworkResponse?)->()) {
        router.request(.findChannels(term: term)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([ChannelInfo].self, from: responseData)
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
    
    func createChannel(name: String, openMode: Bool, completion: @escaping (Channel?, NetworkResponse?)->()) {
        router.request(.createChannel(name: name, openMode: openMode)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(Channel.self, from: responseData)
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
    
    func checkChannelName(name: String, completion: @escaping (CheckChannelName?, NetworkResponse?)->()) {
        router.request(.checkChannelName(name: name)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(CheckChannelName.self, from: responseData)
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
    
    func updateChannelInfo(id: String, name: String?, description: String?, completion: @escaping (Channel?, NetworkResponse?)->()) {
        router.request(.updateChannelInfo(id: id, name: name, description: description)) { data, response, error in
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
                           let responseObject = try JSONDecoder().decode(Channel.self, from: responseData)
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
    
    func sendImage(tmpImage: UIImage?, channelId: String, text: String, completion: @escaping (NetworkResponse?)->()) {
        guard let image = tmpImage else { return }
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(Environment.baseURL)/chnMessages/\(channelId)/imageMessage")!)
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
    
    func sendVideoInChannel(data: Data, channelId: String, text: String, completion: @escaping (NetworkResponse?)->()) {
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(Environment.baseURL)/chnMessages/\(channelId)/videoMessage")!)
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
                completion(NetworkResponse.noData)
                return }
            if error != nil {
                print(error!.localizedDescription)
                completion(NetworkResponse.failed)
                return
            }
            guard data != nil else {
                completion(NetworkResponse.noData)
                return
            }
            completion(nil)
            return
        }.resume()
    }
}

