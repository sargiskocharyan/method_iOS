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
    var calls: [CallHistory] = []
    
    private var privateCalls: [NSManagedObject] = []
    
    func getHistory(completion: @escaping ([CallHistory])->()) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            completion([])
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: CallModelConstants.callEntity)
        do {
            let callsFetched = try managedContext.fetch(fetchRequest)
            self.privateCalls = callsFetched
            self.calls = callsFetched.map({ (call) -> CallHistory in
                return CallHistory(type: call.value(forKey: "type") as? String, receiver: call.value(forKey: "receiver") as? String, status: call.value(forKey: "status") as? String, participants: call.value(forKey: "participants") as! [String], callSuggestTime: call.value(forKey: "callSuggestTime") as? String, _id: call.value(forKey: "id") as? String, createdAt: call.value(forKey: "createdAt") as? String, caller: call.value(forKey: "caller") as? String, callEndTime: call.value(forKey: "callEndTime") as? String, callStartTime: call.value(forKey: "callStartTime") as? String)
            })
            completion(self.calls)
            return
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            completion([])
        }
    }
    
    func saveCalls(calls: [CallHistory], completion: @escaping ([CallHistory]?, NetworkResponse?)->()) {
        var count = 0
        deleteAllRecords()
        if calls.count == 0 {
            completion(nil, nil)
        }
        for call in calls {
            let filteredCalls: [CallHistory] = calls.filter { (call) -> Bool in
                return call.status != CallStatus.ongoing.rawValue
            }
            if call.status != CallStatus.ongoing.rawValue {
                save(newCall: call) {
                    count += 1
                    if count == filteredCalls.count {
                        completion(filteredCalls, nil)
                        return
                    }
                }
            }
        }
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: CallModelConstants.callEntity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print("There was an error")
        }
    }
    
    func getChatMessages(id: String, dateUntil: String?, completion: @escaping (Messages?, NetworkResponse?)->()) {
        ChatNetworkManager().getChatMessages(id: id, dateUntil: dateUntil) { (messages, error) in
            completion(messages, error)
        }
    }
    
    func deleteItem(id: [String], completion: @escaping (NetworkResponse?)->()) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CallModelConstants.callEntity)
        fetchRequest.includesPropertyValues = false
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            privateCalls = privateCalls.filter { (obj) -> Bool in
                if id.contains(obj.value(forKey: "id") as! String) {
                    managedContext.delete(obj)
                }
                return !(id.contains(obj.value(forKey: "id") as! String))
            }
            calls = calls.filter({ (call) -> Bool in
                return !(id.contains(call._id!))
            })
            try managedContext.save()
            completion(nil)
            return
        } catch {
            completion(NetworkResponse.failed)
            return
        }
    }
    
    func getChats(completion: @escaping (Chats?, NetworkResponse?)->()) {
        ChatNetworkManager().getChats() { (chats, error) in
            completion(chats, error)
        }
    }
    func getuserById(id: String, completion: @escaping (User?, NetworkResponse?)->()) {
        HomeNetworkManager().getuserById(id: id) { (user, error) in
            completion(user, error)
        }
    }
    func onlineUsers(arrayOfId: [String], completion: @escaping (OnlineUsers?, NetworkResponse?)->()) {
        ChatNetworkManager().onlineUsers(arrayOfId: arrayOfId) { (user, error) in
            completion(user, error)
        }
    }
    
    
    func save(newCall: CallHistory, completion: @escaping ()->()) {
        let appDelegate = AppDelegate.shared
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: CallModelConstants.callEntity, in: managedContext)!
        let call = NSManagedObject(entity: entity, insertInto: managedContext)
        call.setValue(newCall._id, forKeyPath: "id")
        call.setValue(newCall.type, forKeyPath: "type")
        call.setValue(newCall.status, forKeyPath: "status")
        call.setValue(newCall.callEndTime, forKeyPath: "callEndTime")
        call.setValue(newCall.callSuggestTime, forKeyPath: "callSuggestTime")
        call.setValue(newCall.caller, forKeyPath: "caller")
        call.setValue(newCall.participants, forKeyPath: "participants")
        call.setValue(newCall.createdAt, forKeyPath: "createdAt")
        call.setValue(newCall.callStartTime, forKeyPath: "callStartTime")
        call.setValue(newCall.receiver, forKeyPath: "receiver")
        
        do {
            try managedContext.save()
            privateCalls.append(call)
            calls.insert(newCall, at: 0)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        completion()
        return
    }
    
}
