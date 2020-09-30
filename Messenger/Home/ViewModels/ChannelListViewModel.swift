//
//  ChannelListViewModel.swift
//  Messenger
//
//  Created by Employee3 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class ChannelListViewModel {
    func getChannels(ids: [String], completion: @escaping ([Channel]?, NetworkResponse?)->()) {
        HomeNetworkManager().getChannelsInfo(ids: ids) { (channels, error) in
            completion(channels, error)
        }
    }
    
    func findChannels(term: String, completion: @escaping ([Channel]?, NetworkResponse?)->()) {
        HomeNetworkManager().findChannels(term: term) { (channels, error) in
            completion(channels, error)
        }
    }
    
    func createChannel(name: String, completion: @escaping (Channel?, NetworkResponse?)->()) {
           HomeNetworkManager().createChannel(name: name) { (channel, error) in
               completion(channel, error)
           }
       }
}

