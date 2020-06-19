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
    
    func beforeLogin(email: String, completion: @escaping (MailExistsResponse?, String?)->()) {
        router.request(.beforeLogin(email: email)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(MailExistsResponse.self, from: responseData)
                        completion(responseObject, nil)
                        
                    } catch {
                        print(error)
                        completion(nil, nil)
                    }
                case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, errorObject.Error)
                    } catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func login(email: String, code: String, completion: @escaping (String?, LoginResponse?, String?)->()) {
        router.request(.login(email: email, code: code)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, nil, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, nil)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                        completion(responseObject.token, responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, nil)
                    }
                case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil, nil)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, nil, errorObject.Error)
                    } catch {
                        print(error)
                        completion(nil, nil, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func register(email: String, code: String, completion: @escaping (String?, LoginResponse?, String?)->()) {
        router.request(.register(email: email, code: code)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, nil, error?.localizedDescription)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, nil)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                        completion(responseObject.token, responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, nil, nil)
                    }
                case .failure( _):
                    guard data != nil else {
                        completion(nil, nil, nil)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: data!)
                        completion(nil, nil, errorObject.Error)
                    } catch {
                        print(error)
                        completion(nil, nil, nil)
                    }
                }
            }
        }
    }
    
    func updateUser(name: String, lastname: String, username: String, token: String, university: String, completion: @escaping (UserModel?, String?)->()) {
        router.request(.updateUser(name: name, lastname: lastname, username: username, university: university, token: token)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(UserModel.self, from: responseData)

                        completion(responseObject, nil)
                        
                    } catch {
                        print(error)
                        completion(nil, nil)
                    }
                case .failure( _):
                    //please fix this)), use Error type
                    if response.statusCode == 401 {
                        completion(nil, "unauthorized")
                    }
                    guard data != nil else {
                        completion(nil, nil)
                        return
                    }
                    do {
                        _ = String(bytes: data!, encoding: .utf8)
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: data!)
                        completion(nil, errorObject.Error)
                        
                    } catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                }
            }
        }
    }
    
    func verifyToken(token: String, completion: @escaping (VerifyTokenResponse?, String?)->()) {
        router.request(.verifyToken(token: token)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(VerifyTokenResponse.self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, nil)
                    }
                case .failure( _):
                        completion(nil, nil)
                    guard data != nil else {
                        completion(nil, nil)
                        return
                    }
                }
            }
        }
    }
    
    func getUniversities(token: String, completion: @escaping ([University]?, String?)->()) {
        router.request(.getUniversities(token: token)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode([University].self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, nil)
                    }
                case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, errorObject.Error)
                    } catch {
                        print(error)
                        completion(nil, error.localizedDescription)
                    }
                }
            }
        }
    }
}
