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
    
    func getContacts(completion: @escaping ([User]?, NetworkResponse?)->()) {
        HomeNetworkManager().getUserContacts() { (contacts, error) in
            completion(contacts, error)
        }
    }
    
    func saveContacts(contacts: [User]) {
        let appDelegate = AppDelegate.shared as AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ContactsEntity", in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        let mContacts = Contacts(contacts: contacts)
        cmsg.setValue(mContacts, forKeyPath: "contacts")
        do {
            try managedContext.save()
            print("DATA SAVED!!!!!!!!!!!!!!!!!!!!!")
            
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
//    func retrieveData(completion: @escaping ([User]?)->()) {
//        let appDelegate = AppDelegate.shared as AppDelegate
//        let managedContext = appDelegate.persistentContainer.viewContext
//        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactsEntity")
//        do {
//            let result = try managedContext.fetch(fetchRequest)
//            var i = 0
//            for data in result as! [NSManagedObject] {
//                let mContacts = data.value(forKey: "contacts") as! Contacts
//                completion(mContacts.contacts)
//                print(" contact batch : \(i)")
//                for element in mContacts.contacts {
//                    print("name:\(element.name), username:\(element.username)")
//                }
//                i = i + 1
//            }
//        } catch {
//            completion(nil)
//            print("Failed")
//        }
//    }
}
