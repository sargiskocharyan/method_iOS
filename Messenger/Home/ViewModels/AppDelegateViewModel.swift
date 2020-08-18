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
}
