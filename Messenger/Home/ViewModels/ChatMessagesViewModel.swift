//
//  ChatMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class ChatMessagesViewModel {
    
    func getChatMessages(id: String, completion: @escaping (Messages?, NetworkResponse?)->()) {
        HomeNetworkManager().getChatMessages(id: id) { (messages, error) in
            completion(messages, error)
        }
    }
}
