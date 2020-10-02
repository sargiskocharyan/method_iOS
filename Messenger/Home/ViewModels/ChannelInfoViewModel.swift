//
//  ChannelInfoViewModel.swift
//  Messenger
//
//  Created by Employee3 on 9/30/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

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
}
