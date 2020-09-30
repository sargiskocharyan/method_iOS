//
//  ChannelMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class ChannelMessagesViewModel {
    
    func createChannel(name: String, completion: @escaping (Channel?, NetworkResponse?)->()) {
        HomeNetworkManager().createChannel(name: name) { (channel, error) in
            completion(channel, error)
        }
    }
    
    func getChannelMessages(id: String, dateUntil: String?, completion: @escaping (ChannelMessages?, NetworkResponse?)->()) {
        HomeNetworkManager().getChannelMessages(id: id, dateUntil: dateUntil) { (messages, error) in
            completion(messages, error)
        }
    }

    func subscribeToChannel(id: String, completion: @escaping (SubscribedResponse?, NetworkResponse?)->())  {
        HomeNetworkManager().subscribe(id: id) { (subresponse, error) in
            completion(subresponse, error)
        }
    }
    
}
