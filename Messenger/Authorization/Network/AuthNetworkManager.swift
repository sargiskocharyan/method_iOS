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
    
    func beforeLogin(email: String, completion: @escaping (MailExistsResponse?, String?, Int?)->()) {
        router.request(.beforeLogin(email: email)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription,nil)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(MailExistsResponse.self, from: responseData)
                        completion(responseObject, nil, response.statusCode)
                        
                    } catch {
                        print(error)
                        completion(nil, nil, response.statusCode)
                    }
                case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, errorObject.Error, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, error.localizedDescription, response.statusCode)
                    }
                }
            }
        }
    }
    
    func login(email: String, code: String, completion: @escaping (String?, LoginResponse?, String?, Int?)->()) {
        router.request(.login(email: email, code: code)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, nil, error?.localizedDescription, nil)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                        completion(responseObject.token, responseObject, nil, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, nil, nil, response.statusCode)
                    }
                case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, nil, errorObject.Error, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, nil, error.localizedDescription, response.statusCode)
                    }
                }
            }
        }
    }
    
    func register(email: String, code: String, completion: @escaping (String?, LoginResponse?, String?, Int?)->()) {
        router.request(.register(email: email, code: code)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, nil, error?.localizedDescription, nil)
            }
            
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(LoginResponse.self, from: responseData)
                        completion(responseObject.token, responseObject, nil, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, nil, nil, response.statusCode)
                    }
                case .failure( _):
                    guard data != nil else {
                        completion(nil, nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: data!)
                        completion(nil, nil, errorObject.Error, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, nil, nil, response.statusCode)
                    }
                }
            }
        }
    }
    
    func updateUser(name: String, lastname: String, username: String, token: String, university: String, completion: @escaping (UserModel?, String?, Int?)->()) {
        router.request(.updateUser(name: name, lastname: lastname, username: username, university: university, token: token)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription, nil)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(UserModel.self, from: responseData)

                        completion(responseObject, nil, response.statusCode)
                        
                    } catch {
                        print(error)
                        completion(nil, nil, response.statusCode)
                    }
                case .failure( _):
                    guard data != nil else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                        _ = String(bytes: data!, encoding: .utf8)
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: data!)
                        completion(nil, errorObject.Error, response.statusCode)
                        
                    } catch {
                        print(error)
                        completion(nil, error.localizedDescription, response.statusCode)
                    }
                }
            }
        }
    }
    
    func verifyToken(token: String, completion: @escaping (VerifyTokenResponse?, String?, Int?)->()) {
        router.request(.verifyToken(token: token)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription, nil)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode(VerifyTokenResponse.self, from: responseData)
                        completion(responseObject, nil, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, nil, response.statusCode)
                    }
                case .failure( _):
                        completion(nil, nil, response.statusCode)
                    guard data != nil else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                }
            }
        }
    }
    
    func getUniversities(token: String, completion: @escaping ([University]?, String?, Int?)->()) {
        router.request(.getUniversities(token: token)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription, nil)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode([University].self, from: responseData)
                        completion(responseObject, nil, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, nil, response.statusCode)
                    }
                case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                        completion(nil, errorObject.Error, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, error.localizedDescription, response.statusCode)
                    }
                }
            }
        }
    }
}
