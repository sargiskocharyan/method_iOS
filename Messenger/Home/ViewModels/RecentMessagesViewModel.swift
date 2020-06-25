//
//  RecentMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class RecentMessagesViewModel {
    func getChats(completion: @escaping ([Chat]?, NetworkResponse?)->()) {
        HomeNetworkManager().getChats() { (chats, error) in
            completion(chats, error)
        }
    }
    func getuserById(id: String, completion: @escaping (UserById?, NetworkResponse?)->()) {
        HomeNetworkManager().getuserById(id: id) { (user, error) in
            completion(user, error)
        }
    }
}
