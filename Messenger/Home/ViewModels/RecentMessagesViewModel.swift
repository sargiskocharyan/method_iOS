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
    let id: UUID
    var isHandleCall: Bool
    var time: Date
    var callDuration: Int?
    let calleeId: String
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
                    return FetchedCall(id: UUID(), isHandleCall: call.value(forKey: "isHandleCall") as! Bool, time: call.value(forKey: "time") as! Date, callDuration: (call.value(forKey: "callDuration") as! Int), calleeId: call.value(forKey: "calleeId") as!  String)
                }
                completion(self.calls)
            } catch let error as NSError {
                print("Could not fetch. \(error), \(error.userInfo)")
                completion([])
            }
//        }
        
    }
    
    func deleteItem(index: Int) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CallEntity")
        
        // Configure Fetch Request
        fetchRequest.includesPropertyValues = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            managedContext.delete(privateCalls[privateCalls.count - index - 1])
            privateCalls.remove(at: privateCalls.count - index - 1)
            calls.remove(at: index)
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
    
    func save(newCall: FetchedCall, completion: @escaping ()->()) {
        let appDelegate = AppDelegate.shared as AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CallEntity", in: managedContext)!
        let call = NSManagedObject(entity: entity, insertInto: managedContext)
        call.setValue(newCall.id, forKeyPath: "id")
        call.setValue(newCall.time, forKeyPath: "time")
        call.setValue(newCall.callDuration, forKeyPath: "callDuration")
        call.setValue(newCall.isHandleCall, forKeyPath: "isHandleCall")
        call.setValue(newCall.calleeId, forKeyPath: "calleeId")
        do {
            try managedContext.save()
            privateCalls.append(call)
            calls.append(newCall)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
//                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CallEntity")
//        fetchRequest.predicate = NSPredicate(format: "id == %@", newCall.id as CVarArg)
//                do {
//                    let fetchResults = try managedContext.fetch(fetchRequest) as! [NSManagedObject]
//                    for fetchedResult in fetchResults {
//                        if fetchedResult.value(forKey: "image") as? String != newCall.imageURL {
//
//                            fetchedResult.setValue(newCall.imageURL, forKey: "image")
//                            try managedContext.save()
//                        }
//                    }
//                } catch let error {
//                    print(error.localizedDescription)
//                }
        print(calls)
//        var newCalls: [FetchedCall] = []
//        for var call in calls {
//            if call.id == newCall.id && call.imageURL != newCall.imageURL {
//                call.imageURL = newCall.imageURL
//            }
//            newCalls.append(call)
//        }
//        calls = newCalls
        completion()
       
    }
}
