//
//  ChannelListViewModel.swift
//  Messenger
//
//  Created by Employee3 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class ChannelListViewModel {
    func getChannels(ids: [String], completion: @escaping ([ChannelInfo]?, NetworkResponse?)->()) {
        ChannelNetworkManager().getChannelsInfo(ids: ids) { (channels, error) in
            completion(channels, error)
        }
    }
    
    func findChannels(term: String, completion: @escaping ([ChannelInfo]?, NetworkResponse?)->()) {
        ChannelNetworkManager().findChannels(term: term) { (channels, error) in
            completion(channels, error)
        }
    }
    
    func createChannel(name: String, openMode: Bool, completion: @escaping (Channel?, NetworkResponse?)->()) {
           ChannelNetworkManager().createChannel(name: name, openMode: openMode) { (channel, error) in
               completion(channel, error)
           }
       }
    
    func checkChannelName(name: String, completion: @escaping(CheckChannelName?, NetworkResponse?)->()) {
           ChannelNetworkManager().checkChannelName(name: name) { (response, error) in
               completion(response, error)
           }
       }
}

