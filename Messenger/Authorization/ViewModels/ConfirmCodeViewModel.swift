//
//  ConfirmCodeViewModel.swift
//  Messenger
//
//  Created by Employee1 on 5/26/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class ConfirmCodeViewModel {
    let networkManager = AuthorizationNetworkManager()
    
    func login(email: String, code: String, completion: @escaping (String?, LoginResponse?, String?)->()) {
        networkManager.login(email: email, code: code) { (token, loginResponse, error) in
            if error != nil {
                completion(nil, nil, error)
            } else if token != nil && loginResponse != nil {
                completion(token, loginResponse, nil)
            } else if error == nil && token == nil {
                completion(nil, nil, nil)
            }
        }
    }

    func resendCode(email: String, completion: @escaping (String?, String?)->()) {
        networkManager.beforeLogin(email: email) { (responseObject, error) in
            completion(responseObject?.code, error)
        }
    }
    
    func register(email: String, code: String, completion: @escaping (String?, LoginResponse?, String?)->()) {
        networkManager.register(email: email, code: code) { (token, loginResponse, error) in
            if error != nil {
                completion(nil, nil, error)
            } else if token != nil {
                completion(token, loginResponse, nil)
            } else if error == nil && token == nil {
                completion(nil, nil, nil)
            }
        }
    }
}

