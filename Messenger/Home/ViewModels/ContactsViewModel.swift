//
//  ContactsViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class ContactsViewModel {
    func getContacts(completion: @escaping ([ContactResponseWithId]?, String?, Int?)->()) {
        HomeNetworkManager().getUserContacts() { (contacts, error, code) in
            completion(contacts, error, code)
        }
    }
    
    func findUsers(term: String, completion: @escaping (FindUserResponse?, String?, Int?)->()) {
        HomeNetworkManager().findUsers(term: term) { (responseObject, error, code) in
            completion(responseObject, error, code)
        }
    }
    
    func addContact(id: String, completion: @escaping (String?, Int?)->()) {
        HomeNetworkManager().addContact(id: id) { (error, code) in
            completion(error, code)

    }
  }
    func getMessages(id: String, completion: @escaping ([Message]?, String?, Int?)->()) {
        HomeNetworkManager().getChatMessages(id: id) { (messages, error, code) in
            completion(messages, error, code)
        }
    }
    
}
