//
//  HomePageViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/1/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class HomePageViewModel {
    func verifyToken(token: String, completion: @escaping (VerifyTokenResponse?, NetworkResponse?)->()) {
        AuthorizationNetworkManager().verifyToken(token: token) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
}
