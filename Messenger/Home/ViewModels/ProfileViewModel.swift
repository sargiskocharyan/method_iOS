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
    
    func uploadImage(image: UIImage, completion: @escaping (NetworkResponse?, AvatarModel?)->()) {
        HomeNetworkManager().uploadImage(tmpImage: image) { (error, responseObject) in
            completion(error, responseObject)
        }
    }
    
    func getImage(avatar: String, completion: @escaping (UIImage?, NetworkResponse?)->()) {
        HomeNetworkManager().getImage(avatar: avatar) { (image, error) in
            completion(image, error)
        }
    }
    
}
