//
//  HomePageViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/1/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class HomePageViewModel {
    func verifyToken(token: String, completion: @escaping (VerifyTokenResponse?, NetworkResponse?)->()) {
        AuthorizationNetworkManager().verifyToken(token: token) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func checkCallAsSeen(callId: String, readOne: Bool, completion: @escaping (NetworkResponse?)->()) {
        CallNetworkManager().readCalls(id: callId, readOne: readOne) { (error) in
            completion(error)
        }
    }
    
    func getContacts(completion: @escaping ([User]?, NetworkResponse?)->()) {
        ProfileNetworkManager().getUserContacts() { (contacts, error) in
            completion(contacts, error)
        }
    }
    
    func getCallHistory(completion: @escaping ([CallHistory]?, NetworkResponse?)->()) {
           CallNetworkManager().getCallHistory() { (calls, error) in
               completion(calls, error)
           }
       }
    
    func removeCall(id: [String], completion: @escaping (NetworkResponse?)->()) {
        CallNetworkManager().removeCall(id: id) { (error) in
            completion(error)
        }
    }
    
    func saveContacts(contacts: [User], completion: @escaping ([User]?, NetworkResponse?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: CallModelConstants.contactsEntity, in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        cmsg.setValue(contacts, forKeyPath: CallModelConstants.contacts)
        do {
            try managedContext.save()
            completion(contacts, nil)
            
        } catch let error as NSError {
            completion(nil, NetworkResponse.noData)
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveOtherContacts(otherContacts: [User], completion: @escaping ([User]?, NetworkResponse?)->()) {
           let appDelegate = AppDelegate.shared
           let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: CallModelConstants.otherContactsEntity, in: managedContext)!
           let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        cmsg.setValue(otherContacts, forKeyPath: CallModelConstants.otherContacts)
           do {
               try managedContext.save()
               completion(otherContacts, nil)               
           } catch let error as NSError {
               completion(nil, NetworkResponse.noData)
               print("Could not save. \(error), \(error.userInfo)")
           }
       }
}
