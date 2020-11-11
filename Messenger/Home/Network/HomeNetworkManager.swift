//
//  AuthNetworkManager.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import UIKit


class HomeNetworkManager: NetworkManager, URLSessionDelegate, StreamDelegate {
   
    
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
                    completion(nil, NetworkResponse.failed)
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
                    completion(nil, NetworkResponse.failed)
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
    
    
    func confirmRequest(id: String, confirm: Bool, completion: @escaping (NetworkResponse?)->()) {
        router.request(.confirmRequest(id: id, confirm: confirm)) { data, response, error in
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
    
    func logout(deviceUUID: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.logout(deviceUUID: deviceUUID)) { data, response, error in
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
                    completion(nil, NetworkResponse.failed)
                }
            }
        }
    }
    
    func getRequests(completion: @escaping ([Request]?, NetworkResponse?)->()) {
        router.request(.getRequests) { data, response, error in
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
                        let response = try JSONDecoder().decode([Request].self, from: responseData)
                        completion(response, nil)
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
        guard let image = tmpImage else { return }
        let boundary = UUID().uuidString
        var request = URLRequest(url: URL(string: "\(Environment.baseURL)/users/me/avatar")!)
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
                SharedConfigs.shared.signedUser?.avatarURL = String(data: responseData, encoding: .utf8)
                UserDataController().saveUserInfo()
                completion(nil, String(data: responseData, encoding: .utf8))
            }
        }.resume()
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
    
    func getVideo(url: String) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(SharedConfigs.shared.signedUser?.token, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            print("")
        }.resume()
        
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
    
    func deleteAccount(completion: @escaping (NetworkResponse?)->()) {
           router.request(.deleteAccount) { data, response, error in
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
    
    func deactivateAccount(completion: @escaping (NetworkResponse?)->()) {
              router.request(.deactivateAccount) { data, response, error in
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
    
    func deleteAvatar(completion: @escaping (NetworkResponse?)->()) {
        router.request(.deleteAvatar) { data, response, error in
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
    
    func deleteRequest(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.deleteRequest(id: id)) { data, response, error in
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
    
    func readCalls(id: String, readOne: Bool, completion: @escaping (NetworkResponse?)->()) {
        router.request(.readCalls(id: id, readOne: readOne)) { data, response, error in
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
    
    func editInformation(name: String?, lastname: String?, username: String?, info: String?, gender: String?, birthDate: String?, completion: @escaping (UserModel?, NetworkResponse?)->()) {
        router.request(.editInformation(name: name, lastname: lastname, username: username, info: info, gender: gender, birthDate: birthDate)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(UserModel.self, from: responseData)
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
    
    func removeContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.removeContact(id: id)) { data, response, error in
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
    
    func removeCall(id: [String], completion: @escaping (NetworkResponse?)->()) {
           router.request(.removeCall(id: id)) { data, response, error in
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
    
    func hideData(isHideData: Bool, completion: @escaping (NetworkResponse?)->()) {
        router.request(.hideData(isHideData: isHideData)) { data, response, error in
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
    
    func getCallHistory(completion: @escaping ([CallHistory]?, NetworkResponse?)->()) {
        router.request(.getCallHistory) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([CallHistory].self, from: responseData)
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
    
    func changeEmail(email: String, completion: @escaping (MailExistsResponse?, NetworkResponse?)->()) {
        router.request(.changeEmail(email: email)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(MailExistsResponse.self, from: responseData)
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
    
    func changePhone(phone: String, completion: @escaping (PhoneExistsResponse?, NetworkResponse?)->()) {
        router.request(.changePhone(phone: phone)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(PhoneExistsResponse.self, from: responseData)
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
    
    func verifyEmail(email: String, code: String, completion: @escaping (ChangeEmailResponse?, NetworkResponse?)->()) {
        router.request(.verifyEmail(email: email, code: code)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(ChangeEmailResponse.self, from: responseData)
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
    
    func verifyPhone(phone: String, code: String, completion: @escaping (ChangeEmailResponse?, NetworkResponse?)->()) {
        router.request(.verifyPhone(number: phone, code: code)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(ChangeEmailResponse.self, from: responseData)
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
    
    func getAdminMessages(completion: @escaping ([AdminMessage]?, NetworkResponse?)->()) {
        router.request(.getAdminMessage) { data, response, error in
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
                        let response = try JSONDecoder().decode([AdminMessage].self, from: responseData)
                        completion(response, nil)
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
    
}

extension NSMutableData {
    func appendString(_ string: String) {
        let data = string.data(using: .utf8)
        append(data!)
    }
}
