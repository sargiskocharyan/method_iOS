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
    
    func login(email: String, code: String, completion: @escaping (String?, LoginResponse?, NetworkResponse?)->()) {
        networkManager.login(email: email, code: code) { (token, loginResponse, error) in
            completion(token, loginResponse, error)
        }
    }

    func resendCode(email: String, completion: @escaping (String?, NetworkResponse?)->()) {
        networkManager.beforeLogin(email: email) { (responseObject, error) in
            completion(responseObject?.code, error)
        }
    }
    
    func register(email: String, code: String, completion: @escaping (String?, LoginResponse?, NetworkResponse?)->()) {
        networkManager.register(email: email, code: code) { (token, loginResponse, error) in
            completion(token, loginResponse, error)
        }
    }
}

