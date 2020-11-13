//
//  ProfileNetworkManager.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class ProfileNetworkManager: NetworkManager {
   
    
    let router = Router<ProfileApi>()
    
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
}
