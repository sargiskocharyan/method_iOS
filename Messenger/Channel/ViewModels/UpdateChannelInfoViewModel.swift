//
//  UpdateChannelInfoViewModel.swift
//  Messenger
//
//  Created by Employee3 on 10/6/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
import UIKit.UIImage

class UpdateChannelInfoViewModel {
    func checkChannelName(name: String, completion: @escaping(CheckChannelName?, NetworkResponse?)->()) {
        ChannelNetworkManager().checkChannelName(name: name) { (response, error) in
            completion(response, error)
        }
    }
    
    func updateChannelInfo(id: String, name: String?, description: String?, completion: @escaping(Channel?, NetworkResponse?)->()) {
        ChannelNetworkManager().updateChannelInfo(id: id, name: name, description: description) { (channel, error) in
            completion(channel, error)
        }
    }
  
}
