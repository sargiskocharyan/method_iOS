//
//  SocketTaskManager.swift
//  Messenger
//
//  Created by Employee1 on 6/17/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import SocketIO

class SocketTaskManager {
    
    static let shared = SocketTaskManager()
    
    var socket: SocketIOClient {
        return manager.defaultSocket
    }
    
    var manager: SocketManager = SocketManager(socketURL: URL(string: "https://messenger-dynamic.herokuapp.com")!, config: [.log(true), .connectParams(["token": KeyChain.load(key: "token")?.toString() ?? ""]), .forceNew(true), .compress])
    
    private init () { }
    
    
    func connect() {
        manager = SocketManager(socketURL: URL(string: "https://messenger-dynamic.herokuapp.com")!, config: [.log(true), .connectParams(["token": KeyChain.load(key: "token")?.toString() ?? ""]), .forceNew(true), .compress])
        socket.connect()
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
        }
        socket.on(clientEvent: .error) {data, ack in
            print("error")
        }
    }
    
    func emit() {
        socket.emit("join") {
            print("join")
        }
    }
    
    func send(message: String, id: String) {
        socket.emit("sendMessage", message, id) 
    }
    
    func disconnect() {
        socket.disconnect()
        
    }
    
    func getChatMessage(completionHandler: @escaping (_ message: Message) -> Void) {
        socket.on("message") { (dataArray, socketAck) -> Void in
            let data = dataArray[0] as! NSDictionary
            let sender = data["sender"] as! NSDictionary
            let message = Message(_id: data["_id"] as? String, reciever: data["reciever"] as? String, text: data["text"] as? String, createdAt: data["createdAt"] as? String, updatedAt: data["updatedAt"] as? String, owner: data["owner"] as? String, sender: Sender(id: sender["id"] as? String, name: sender["name"] as? String ?? ""))
            completionHandler(message)
        }
    }
}

