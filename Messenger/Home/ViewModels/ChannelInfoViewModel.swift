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
}
