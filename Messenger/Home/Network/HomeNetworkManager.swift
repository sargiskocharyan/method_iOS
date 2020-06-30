//
//  AuthNetworkManager.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import UIKit


class HomeNetworkManager: NetworkManager {
    
    let router = Router<HomeApi>()
    
    func getUserContacts(completion: @escaping ([User]?, NetworkResponse?)->()) {
        router.request(.getUserContacts) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([User].self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure(_):
                    completion(nil, error)
                }
            }
        }
    }
    
    func findUsers(term: String, completion: @escaping (Users?, NetworkResponse?)->()) {
        router.request(.findUsers(term: term)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(Users.self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                    completion(nil, error)
                }
            }
        }
    }
    
    func addContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.addContact(id: id)) { data, response, error in
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
    func logout(completion: @escaping (NetworkResponse?)->()) {
        router.request(.logout) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(error)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    completion(error)
                case .failure( _):
                    completion(error)
                }
            }
        }
        
    }
    
    func getChats(completion: @escaping ([Chat]?, NetworkResponse?)->()) {
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
                        let responseObject = try JSONDecoder().decode([Chat].self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                    completion(nil, error)
                }
            }
        }
    }
    
    func getChatMessages(id: String,  completion: @escaping ([Message]?, NetworkResponse?)->()) {
        router.request(.getChatMessages(id: id)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([Message].self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                    completion(nil, error)
                }
            }
        }
    }
    func getuserById(id: String,  completion: @escaping (UserById?, NetworkResponse?)->()) {
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
                        let responseObject = try JSONDecoder().decode(UserById.self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                    completion(nil, error)
                }
            }
        }
    }
    
    func getImage(avatar: String, completion: @escaping (UIImage?, NetworkResponse?)->()) {
        router.request(.getImage(avatar: avatar)) { data, response, error in
            print(avatar)
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
                    let image = UIImage(data: responseData)
                    completion(image, nil)
                case .failure( _):
                    completion(nil, error)
                }
            }
        }
    }
    
    func uploadImage(tmpImage: UIImage?, completion: @escaping (NetworkResponse?, AvatarModel?)->()) {
        guard let image = tmpImage else { return }
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "http://192.168.0.105:3000/users/me/avatar")!)
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
                do {
                    let responseObject = try JSONDecoder().decode(AvatarModel.self, from: responseData)
                    SharedConfigs.shared.signedUser?.avatar = responseObject.avatar
                    UserDataController().saveUserInfo()
                    completion(nil, responseObject)
                } catch {
                    print(error)
                    completion(NetworkResponse.unableToDecode, nil)
                }
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
