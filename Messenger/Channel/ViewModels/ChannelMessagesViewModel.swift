//
//  ChannelMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class ChannelMessagesViewModel {
    
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
    
    func getChatMessages(id: String, dateUntil: String?, completion: @escaping (Messages?, NetworkResponse?)->()) {
           HomeNetworkManager().getChatMessages(id: id, dateUntil: dateUntil) { (messages, error) in
               completion(messages, error)
           }
       }
    
    func deleteChannelMessages(id: String, ids: [String], completion: @escaping (NetworkResponse?)->())  {
        HomeNetworkManager().deleteChannelMessages(id: id, ids: ids) { (error) in
            completion(error)
        }
    }
    
    func leaveChannel(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().leaveChannel(id: id) { (error) in
            completion(error)
        }
    }
    
    func deleteChannelMessageBySender(ids: [String], completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().deleteChannelMessageBySender(ids: ids) { (error) in
            completion(error)
        }
    }
    
    func editChannelMessageBySender(id: String, text: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().editChannelMessageBySender(id: id, text: text) { (error) in
            completion(error)
        }
    }
}
