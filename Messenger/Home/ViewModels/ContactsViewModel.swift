//
//  ContactsViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import CoreData


class ContactsViewModel {
    var contacts: [User] = []
    var otherContacts: [User] = []
    
    func getContacts(completion: @escaping ([User]?, NetworkResponse?)->()) {
        HomeNetworkManager().getUserContacts() { (contacts, error) in
            completion(contacts, error)
        }
    }
    
    func findUsers(term: String, completion: @escaping (Users?, NetworkResponse?)->()) {
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
    
    func removeContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().removeContact(id: id) { (error) in
            completion(error)
        }
    }
    
    func retrieveData(completion: @escaping ([User]?)->()) {
           let appDelegate = AppDelegate.shared
           let managedContext = appDelegate.persistentContainer.viewContext
           let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ContactsEntity")
           do {
               let result = try managedContext.fetch(fetchRequest)
               var i = 0
               for data in result as! [NSManagedObject] {
                   let mContacts = data.value(forKey: "contacts") as! Contacts
                self.contacts = mContacts.contacts
                   completion(mContacts.contacts)
                   i = i + 1
               }
           } catch {
            self.contacts = []
               completion(nil)
               print("Failed")
           }
       }
    
    func retrieveOtherContactData(completion: @escaping ([User]?)->()) {
              let appDelegate = AppDelegate.shared
              let managedContext = appDelegate.persistentContainer.viewContext
              let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "OtherContactEntity")
              do {
                  let result = try managedContext.fetch(fetchRequest)
                  var i = 0
                  for data in result as! [NSManagedObject] {
                      let mOtherContacts = data.value(forKey: "otherContacts") as! Contacts
                      self.otherContacts = mOtherContacts.contacts
                      completion(mOtherContacts.contacts)
                      i = i + 1
                  }
              } catch {
               self.contacts = []
                  completion(nil)
                  print("Failed")
              }
          }
    
    func addContactToCoreData(newContact: User, completion: @escaping (NSError?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ContactsEntity", in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        contacts.append(newContact)
        let mContacts = Contacts(contacts: contacts)
        cmsg.setValue(mContacts, forKeyPath: "contacts")
        do {
            try managedContext.save()
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
        }
    }
    
    func removeContactFromCoreData(id: String, completion: @escaping (NSError?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "ContactsEntity", in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        print(contacts.count)
        contacts = contacts.filter { (contact) -> Bool in
            return contact._id != id
        }
        print(contacts.count)
        let mContacts = Contacts(contacts: contacts)
        cmsg.setValue(mContacts, forKeyPath: "contacts")
        do {
            try managedContext.save()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
}
