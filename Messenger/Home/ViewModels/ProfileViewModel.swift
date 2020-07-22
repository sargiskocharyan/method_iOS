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
    
    func uploadImage(image: UIImage, completion: @escaping (NetworkResponse?, String?)->()) {
        HomeNetworkManager().uploadImage(tmpImage: image) { (error, avatarURL) in
            completion(error, avatarURL)
        }
    }
    
    func getImage(avatar: String, completion: @escaping (UIImage?, NetworkResponse?)->()) {
        HomeNetworkManager().getImage(avatar: avatar) { (image, error) in
            completion(image, error)
        }
    }
    
    func deleteAvatar(completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().deleteAvatar() { (error) in
            completion(error)
        }
    }
    
}
