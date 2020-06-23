//
//  RecentMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class RecentMessagesViewModel {
    func getChats(completion: @escaping ([Chat]?, String?, Int?)->()) {
        HomeNetworkManager().getChats() { (chats, error, code) in
            completion(chats, error, code)
        }
    }
    func getuserById(id: String, completion: @escaping (UserById?, String?, Int?)->()) {
        HomeNetworkManager().getuserById(id: id) { (user, error, code) in
            completion(user, error, code)
        }
    }
}
