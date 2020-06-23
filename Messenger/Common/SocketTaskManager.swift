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
    let manager = SocketManager(socketURL: URL(string: "https://messenger-dynamic.herokuapp.com")!, config: [.log(true), .connectParams(["token": KeyChain.load(key: "token")?.toString() ?? ""]), .compress])
    
    var socket: SocketIOClient {
        let socket = manager.defaultSocket
        return socket
    }
    
    private init () { }
    
    
    func connect() {
        socket.connect()
    }
    
    func emit() {
        socket.emit("join") {
            print("join")
        }
    }
    
    func send(message: String, id: String) {
        socket.emit("sendMessage", message, id) 
    }
    
    func getChatMessage(completionHandler: @escaping (_ message: Message) -> Void) {
        socket.on("message") { (dataArray, socketAck) -> Void in
            let data = dataArray[0] as! NSDictionary
            let sender = data["sender"] as! NSDictionary
            let message = Message(_id: data["_id"] as! String, reciever: data["reciever"] as! String, text: data["text"] as! String, createdAt: data["createdAt"] as! String, updatedAt: data["updatedAt"] as! String, owner: data["owner"] as! String, sender: Sender(id: sender["id"] as! String, name: sender["name"] as? String ?? ""))
            completionHandler(message)
        }
    }
    //https://messenger-dynamic.herokuapp.com/socket.io/?EIO=3&transport=websocket
}

