//
//  ChannelInfoViewModel.swift
//  Messenger
//
//  Created by Employee3 on 9/30/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
import UIKit.UIImage

class ChannelInfoViewModel {
    func leaveChannel(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().leaveChannel(id: id) { (error) in
            completion(error)
        }
    }
    
    func getModerators(id: String, completion: @escaping ([ChannelSubscriber]?, NetworkResponse?) -> ()) {
        HomeNetworkManager().getModerators(id: id) { (moderators, error) in
            completion(moderators, error)
        }
    }
    
    func getSubscribers(id: String, completion: @escaping ([ChannelSubscriber]?, NetworkResponse?)->()) {
        HomeNetworkManager().getSubscribers(id: id) { (user, error) in
            completion(user, error)
        }
    }
    
    func addModerator(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().addModerator(id: id, userId: userId) { (error) in
            completion(error)
        }
    }
    
    func removeModerator(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().removeModerator(id: id, userId: userId) { (error) in
            completion(error)
        }
    }
    
    func uploadImage(image: UIImage, id: String, completion: @escaping (NetworkResponse?, String?)->()) {
        HomeNetworkManager().uploadChannelImage(tmpImage: image, id: id) { (error, avatarUrl) in
            completion(error, avatarUrl)
        }
    }
    
    func changeAdmin(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().changeAdmin(id: id, userId: userId) { (error) in
            completion(error)
        }
    }
    
    func deleteChannelLogo(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().deleteChannelLogo(id: id) { (error) in
            completion(error)
        }
    }
    
    func deleteChannel(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().deleteChannel(id: id) { (error) in
            completion(error)
        }
    }
    
    func rejectBeModerator(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().rejectBeModerator(id: id) { (error) in
            completion(error)
        }
    }
}
