//
//  ContactsViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class ContactsViewModel {
    func getContacts(completion: @escaping ([ContactResponseWithId]?, NetworkResponse?)->()) {
        HomeNetworkManager().getUserContacts() { (contacts, error) in
            completion(contacts, error)
        }
    }
    
    func findUsers(term: String, completion: @escaping ([User]?, NetworkResponse?)->()) {
        HomeNetworkManager().findUsers(term: term) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func addContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().addContact(id: id) { (error) in
            completion(error)

    }
  }
    func getMessages(id: String, completion: @escaping ([Message]?, NetworkResponse?)->()) {
        HomeNetworkManager().getChatMessages(id: id) { (messages, error) in
            completion(messages, error)
        }
    }
    
}
