//
//  AppDelegateViewModel.swift
//  Messenger
//
//  Created by Employee1 on 8/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class AppDelegateViewModel {
    func registerDevice(token: String, voIPToken: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().registerDevice(token: token, voipToken: voIPToken) { (error) in
            completion(error)
        }
    }
    
    func confirmRequest(id: String, confirm: Bool, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().confirmRequest(id: id, confirm: confirm) { (error) in
            completion(error)
        }
    }
    
    func getuserById(id: String, completion: @escaping (User?, NetworkResponse?)->()) {
        HomeNetworkManager().getuserById(id: id) { (user, error) in
            completion(user, error)
        }
    }
}
