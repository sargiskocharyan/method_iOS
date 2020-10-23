//
//  ChatMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/16/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class ChatMessagesViewModel {
    
    func getChatMessages(id: String, dateUntil: String?, completion: @escaping (Messages?, NetworkResponse?)->()) {
        HomeNetworkManager().getChatMessages(id: id, dateUntil: dateUntil) { (messages, error) in
            completion(messages, error)
        }
    }
    
    func editChatMessage(messageId: String, text: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().editChatMessage(messageId: messageId, text: text) { (error) in
            completion(error)
        }
    }
    
    func deleteChatMessages(arrayMessageIds: [String], completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().deleteChatMessages(arrayMessageIds: arrayMessageIds) { (error) in
            completion(error)
        }
    }
}
