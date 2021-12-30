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
    var findedUsers: [User] = []
    var contactsMiniInformation: [User] = []
    
    func getContacts(completion: @escaping ([User]?, NetworkResponse?)->()) {
        ProfileNetworkManager().getUserContacts() { (contacts, error) in
            completion(contacts, error)
        }
    }
    
    func findUsers(term: String, completion: @escaping (Users?, NetworkResponse?)->()) {
        ProfileNetworkManager().findUsers(term: term) { (responseObject, error) in
            if responseObject != nil {
                for i in .zero..<responseObject!.users.count {
                    var a = false
                    for j in .zero..<self.contacts.count {
                        if responseObject!.users[i]._id == self.contacts[j]._id {
                            a = true
                            break
                        }
                    }
                    if a == false {
                        self.findedUsers.append(responseObject!.users[i])
                    }
                }
            }
            completion(responseObject, error)
        }
    }
    
    func getContactsMiniInformation() {
        contactsMiniInformation = findedUsers.map({ (user) -> User in
            User(name: user.name, lastname: user.lastname, _id: user._id!, username: user.username, avaterURL: user.avatarURL, email: nil, info: user.info, phoneNumber: user.phoneNumber, birthday: user.birthday, address: user.address, gender: user.gender, missedCallHistory: user.missedCallHistory, channels: user.channels)
        })
    }
    
    func addContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        ProfileNetworkManager().addContact(id: id) { (error) in
            completion(error)
        }
    }
    
    func getMessages(id: String, dateUntil: String?, completion: @escaping (Messages?, NetworkResponse?)->()) {
        ChatNetworkManager().getChatMessages(id: id, dateUntil: dateUntil) { (messages, error) in
            completion(messages, error)
        }
    }
    
    func removeContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        ProfileNetworkManager().removeContact(id: id) { (error) in
            completion(error)
        }
    }
    
    func getRequests(completion: @escaping ([Request]?, NetworkResponse?)->())  {
        ProfileNetworkManager().getRequests { (requests, error) in
            completion(requests, error)
        }
    }
    
    func getAdminMessages(completion: @escaping ([AdminMessage]?, NetworkResponse?)->())  {
        ProfileNetworkManager().getAdminMessages { (adminMessages, error) in
            completion(adminMessages, error)
        }
    }
    
    func deleteRequest(id: String, completion: @escaping (NetworkResponse?) -> ()) {
        ProfileNetworkManager().deleteRequest(id: id) { (error) in
            completion(error)
        }
    }
    
    func retrieveData(completion: @escaping ([User]?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CallModelConstants.contactsEntity)
        do {
            let result = try managedContext.fetch(fetchRequest)
            var i = 0
            for data in result as! [NSManagedObject] {
                let mContacts = data.value(forKey: CallModelConstants.contacts) as! [User]
                self.contacts = mContacts
                completion(mContacts)
                i = i + 1
            }
        } catch {
            self.contacts = []
            completion(nil)
        }
    }
    
    func retrieveOtherContactData(completion: @escaping ([User]?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CallModelConstants.otherContactsEntity)
        do {
            let result = try managedContext.fetch(fetchRequest)
            var i = 0
            for data in result as! [NSManagedObject] {
                let mOtherContacts = data.value(forKey: CallModelConstants.otherContacts) as! [User]
                self.otherContacts = mOtherContacts
                completion(mOtherContacts)
                i = i + 1
            }
        } catch {
            self.contacts = []
            completion(nil)
        }
    }
    
    func addContactToCoreData(newContact: User, completion: @escaping (NSError?)->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: CallModelConstants.contactsEntity, in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        contacts.append(newContact)
        cmsg.setValue(contacts, forKeyPath: CallModelConstants.contacts)
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
        let entity = NSEntityDescription.entity(forEntityName: CallModelConstants.contactsEntity, in: managedContext)!
        let cmsg = NSManagedObject(entity: entity, insertInto: managedContext)
        contacts = contacts.filter { (contact) -> Bool in
            return contact._id != id
        }
        cmsg.setValue(contacts, forKeyPath: CallModelConstants.contacts)
        do {
            try managedContext.save()
            completion(nil)
        } catch let error as NSError {
            completion(error)
        }
    }
}
