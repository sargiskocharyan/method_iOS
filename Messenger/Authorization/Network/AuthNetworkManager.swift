//
//  AuthNetworkManager.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation


class AuthorizationNetworkManager: NetworkManager {
    
    let router = Router<AuthApi>()
    
    func beforeLogin(email: String, completion: @escaping (MailExistsResponse?, NetworkResponse?)->()) {
        router.request(.beforeLogin(email: email)) { data, response, error in
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
    
    func login(email: String, code: String, completion: @escaping (String?, LoginResponse?, NetworkResponse?)->()) {
        router.request(.login(email: email, code: code)) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(nil, nil, error)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, error)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                        completion(responseObject.token, responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                    completion(nil, nil, NetworkResponse.failed)
                }
            }
        }
    }
    
    func checkUsername(username: String, completion: @escaping (CheckUsername?, NetworkResponse?)->()) {
        router.request(.checkUsername(username: username)) { data, response, error in
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
                           let responseObject = try JSONDecoder().decode(CheckUsername.self, from: responseData)
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
    
    func register(email: String, code: String, completion: @escaping (String?, LoginResponse?, NetworkResponse?)->()) {
        router.request(.register(email: email, code: code)) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(nil, nil, error)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, error)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                        completion(responseObject.token, responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                    completion(nil, nil, NetworkResponse.failed)
                }
            }
        }
    }
    
    func updateUser(name: String?, lastname: String?, username: String?, gender: String?, completion: @escaping (UserModel?, NetworkResponse?)->()) {
        router.request(.updateUser(name: name, lastname: lastname, username: username, gender: gender)) { data, response, error in
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
    
    func verifyToken(token: String, completion: @escaping (VerifyTokenResponse?, NetworkResponse?)->()) {
        router.request(.verifyToken(token: token)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(VerifyTokenResponse.self, from: responseData)
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
}
