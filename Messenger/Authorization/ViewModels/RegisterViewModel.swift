//
//  RegisterViewModel.swift
//  Messenger
//
//  Created by Employee1 on 5/28/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class RegisterViewModel {
    let networkManager = AuthorizationNetworkManager()
    
    func updateUser(name: String, lastname: String, username: String, university: String, completion: @escaping (UserModel?, NetworkResponse?)->()) {
        let token = SharedConfigs.shared.signedUser?.token
        networkManager.updateUser(name: name, lastname: lastname, username: username, token: token!, university: university) {(user, error) in
          completion(user, error)
        }
    }
    
    func getUniversities(completion: @escaping ([University]?, NetworkResponse?)->()) {
        networkManager.getUniversities(token:  (SharedConfigs.shared.signedUser?.token)!) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func checkUsername(username: String, completion: @escaping (CheckUsername?, NetworkResponse?)->()) {
        networkManager.checkUsername(username: username) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
}
