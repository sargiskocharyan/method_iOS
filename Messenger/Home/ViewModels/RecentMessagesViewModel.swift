//
//  RecentMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 6/15/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import CoreData

struct FetchedCall {
    let id: String
    let name: String?
    let username: String?
    let image: String?
    let isHandleCall: Bool
    let time: Date
    let lastname: String?
}
class RecentMessagesViewModel {
     var calls: [FetchedCall] = []
    private var privateCalls: [NSManagedObject] = []
    func getHistory(completion: @escaping ([FetchedCall])->()) {
//        DispatchQueue.global(qos: .background).async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                    completion([])
                    return
            }
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CallEntity")
            do {
                let callsFetched = try managedContext.fetch(fetchRequest)
                self.privateCalls = callsFetched
                self.calls = callsFetched.map { (call) -> FetchedCall in
                    return FetchedCall(id: call.value(forKey: "id") as! String, name: call.value(forKey: "name") as? String, username: call.value(forKey: "username") as? String, image: call.value(forKey: "image") as? String, isHandleCall: call.value(forKey: "isHandleCall") as! Bool, time: call.value(forKey: "time") as! Date, lastname: call.value(forKey: "lastname") as? String)
                }
                completion(self.calls)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                completion([])
            }
//        }
        
    }
    
    func deleteItem() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CallEntity")
        
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            managedContext.delete(privateCalls[0])
            calls.removeLast()
            try managedContext.save()
            
        } catch {
            // Error Handling
            // ...
        }
    }
    
    func getChats(completion: @escaping ([Chat]?, NetworkResponse?)->()) {
        HomeNetworkManager().getChats() { (chats, error) in
            completion(chats, error)
        }
    }
    func getuserById(id: String, completion: @escaping (User?, NetworkResponse?)->()) {
        HomeNetworkManager().getuserById(id: id) { (user, error) in
            completion(user, error)
        }
    }
    
    func save(newCall: FetchedCall) {
        let appDelegate = AppDelegate.shared as AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CallEntity", in: managedContext)!
        let call = NSManagedObject(entity: entity, insertInto: managedContext)
        call.setValue(newCall.name, forKeyPath: "name")
        call.setValue(newCall.lastname, forKeyPath: "lastname")
        call.setValue(newCall.username, forKeyPath: "username")
        call.setValue(newCall.id, forKeyPath: "id")
        call.setValue(newCall.image, forKeyPath: "image")
        call.setValue(newCall.time, forKeyPath: "time")
        call.setValue(newCall.isHandleCall, forKeyPath: "isHandleCall")
        do {
            try managedContext.save()
            privateCalls.append(call)
            calls.append(newCall)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
}
