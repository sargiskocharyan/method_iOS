//
//  BeforeLoginViewModel.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class BeforeLoginViewModel {
    
    let networkManager = AuthorizationNetworkManager()
    
    func emailChecking(email: String, completion: @escaping (MailExistsResponse?, NetworkResponse?)->()) {
        networkManager.beforeLogin(email: email) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
}
