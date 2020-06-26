//
//  ProfileViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class ProfileViewModel {
    func logout(completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().logout() { (error) in
            completion(error)
        }
    }
    
    func uploadImage(image: UIImage, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().uploadImage(tmpImage: image) { (error) in
            completion(error)
        }
    }
    
    func getImage(id: String, completion: @escaping (UIImage?, NetworkResponse?)->()) {
        HomeNetworkManager().getImage(id: id) { (image, error) in
            completion(image, error)
        }
    }
    
}
