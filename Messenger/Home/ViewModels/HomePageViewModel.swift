//
//  HomePageViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/1/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import CoreData

class HomePageViewModel {
    func verifyToken(token: String, completion: @escaping (VerifyTokenResponse?, NetworkResponse?)->()) {
        AuthorizationNetworkManager().verifyToken(token: token) { (responseObject, error) in
            completion(responseObject, error)
        }
    }
    
    func checkCallAsSeen(callId: String, readOne: Bool, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().readCalls(id: callId, readOne: readOne) { (error) in
            completion(error)
        }
    }
    
    func getContacts(completion: @escaping ([User]?, NetworkResponse?)->()) {
        HomeNetworkManager().getUserContacts() { (contacts, error) in
            completion(contacts, error)
        }
    }
    
    func getCallHistory(completion: @escaping ([CallHistory]?, NetworkResponse?)->()) {
           HomeNetworkManager().getCallHistory() { (calls, error) in
               completion(calls, error)
           }
       }
    
    func removeCall(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().removeCall(id: id) { (error) in
            completion(error)
        }
    }
    
    func saveContacts(contacts: [User], completion: @escaping ([User]?, NetworkResponse?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ContactsEntity", in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        let mContacts = Contacts(contacts: contacts)
        cmsg.setValue(mContacts, forKeyPath: "contacts")
        do {
            try managedContext.save()
            completion(mContacts.contacts, nil)
            print("DATA SAVED!!!!!!!!!!!!!!!!!!!!!")
            
        } catch let error as NSError {
            completion(nil, NetworkResponse.noData)
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func saveOtherContacts(otherContacts: [User], completion: @escaping ([User]?, NetworkResponse?)->()) {
           let appDelegate = AppDelegate.shared
           let managedContext = appDelegate.persistentContainer.viewContext
           let entity = NSEntityDescription.entity(forEntityName: "OtherContactEntity", in: managedContext)!
           let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
           let mOtherContacts = Contacts(contacts: otherContacts)
           cmsg.setValue(mOtherContacts, forKeyPath: "otherContacts")
           do {
               try managedContext.save()
               completion(mOtherContacts.contacts, nil)
               print("DATA SAVED!!!!!!!!!!!!!!!!!!!!!")
               
           } catch let error as NSError {
               completion(nil, NetworkResponse.noData)
               print("Could not save. \(error), \(error.userInfo)")
           }
       }
}
