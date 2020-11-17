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
        ChannelNetworkManager().leaveChannel(id: id) { (error) in
            completion(error)
        }
    }
    
    func getModerators(id: String, completion: @escaping ([ChannelSubscriber]?, NetworkResponse?) -> ()) {
        ChannelNetworkManager().getModerators(id: id) { (moderators, error) in
            completion(moderators, error)
        }
    }
    
    func getSubscribers(id: String, completion: @escaping ([ChannelSubscriber]?, NetworkResponse?)->()) {
        ChannelNetworkManager().getSubscribers(id: id) { (user, error) in
            completion(user, error)
        }
    }
    
    func addModerator(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        ChannelNetworkManager().addModerator(id: id, userId: userId) { (error) in
            completion(error)
        }
    }
    
    func removeModerator(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        ChannelNetworkManager().removeModerator(id: id, userId: userId) { (error) in
            completion(error)
        }
    }
    
    func uploadImage(image: UIImage, id: String, completion: @escaping (NetworkResponse?, String?)->()) {
        ChannelNetworkManager().uploadChannelImage(tmpImage: image, id: id) { (error, avatarUrl) in
            completion(error, avatarUrl)
        }
    }
    
    func changeAdmin(id: String, userId: String, completion: @escaping (NetworkResponse?)->()) {
        ChannelNetworkManager().changeAdmin(id: id, userId: userId) { (error) in
            completion(error)
        }
    }
    
    func deleteChannelLogo(id: String, completion: @escaping (NetworkResponse?)->()) {
        ChannelNetworkManager().deleteChannelLogo(id: id) { (error) in
            completion(error)
        }
    }
    
    func deleteChannel(id: String, completion: @escaping (NetworkResponse?)->()) {
        ChannelNetworkManager().deleteChannel(id: id) { (error) in
            completion(error)
        }
    }
    
    func rejectBeModerator(id: String, completion: @escaping (NetworkResponse?)->()) {
        ChannelNetworkManager().rejectBeModerator(id: id) { (error) in
            completion(error)
        }
    }
    
    func subscribeToChannel(id: String, completion: @escaping (SubscribedResponse?, NetworkResponse?)->())  {
        ChannelNetworkManager().subscribe(id: id) { (subresponse, error) in
            completion(subresponse, error)
        }
    }
    
    func blockSubscribers(id: String, subscribers: [String], completion: @escaping (NetworkResponse?)->())  {
        ChannelNetworkManager().blockSubscribers(id: id, subscribers: subscribers) { (error) in
            completion(error)
        }
    }
}
