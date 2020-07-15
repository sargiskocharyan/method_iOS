//
//  SocketTaskManager.swift
//  Messenger
//
//  Created by Employee1 on 6/17/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import SocketIO
import WebRTC

protocol SocketIODelegate: class {
    func receiveData(sdp: String)
    func receiveCandidate(remoteCandidate: RTCIceCandidate)
}

class SocketTaskManager {
    
    static let shared = SocketTaskManager()
    weak var delegate: SocketIODelegate?
    var socket: SocketIOClient {
        return manager.defaultSocket
    }
    
    var manager: SocketManager = SocketManager(socketURL: URL(string: Environment.baseURL)!, config: [.log(true), .connectParams(["token": KeyChain.load(key: "token")?.toString() ?? ""]), .forceNew(true), .compress])
    
    private init () { }
    
    
    func connect() {
        manager = SocketManager(socketURL: URL(string: Environment.baseURL)!, config: [.log(true), .connectParams(["token": KeyChain.load(key: "token")?.toString() ?? ""]), .forceNew(true), .compress])
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
    
    func send(data: Dictionary<String, Any>, roomName: String) {
        self.socket.emit("candidates", roomName, data) {
            print("send data")
        }
    }
    
    func call(id: String) {
        socket.emit("call", id) {
            print("called")
        }
    }
    
    func callAccepted(id: String, isAccepted: Bool) {
        socket.emit("callAccepted", id, isAccepted) {
            print("called")
        }
    }
    
     func handleCall(completionHandler: @escaping (_ id: String) -> Void) {
            socket.on("call") { (dataArray, socketAck) in
                completionHandler(dataArray[0] as! String)
            }
        }
    
    func handleOffer(completionHandler: @escaping (_ roomName: String, _ answer: Dictionary<String, String>) -> Void) {
        socket.on("offer") { (dataArray, socketAck) in
            let dic = dataArray[1] as! Dictionary<String, String>
            self.delegate?.receiveData(sdp: dic["sdp"] ?? "")
            completionHandler(dataArray[0] as! String, dataArray[1] as! Dictionary<String, String>)
        }
    }
    
    func answer(roomName: String, answer: Dictionary<String, String>) {
        socket.emit("answer", roomName, answer) {
            print("answered")
        }
    }
    
    func handleCallAccepted(completionHandler: @escaping (_ accepted: Bool, _ roomName: String) -> Void) {
        socket.on("callAccepted") { (dataArray, socketAck) in
//                      let sender = data["sender"] as! NSDictionary
//                      let message = Message(_id: data["_id"] as? String, reciever: data["reciever"] as? String, text: data["text"] as? String, createdAt: data["createdAt"] as? String, updatedAt: data["updatedAt"] as? String, owner: data["owner"] as? String, sender: Sender(id: sender["id"] as? String, name: sender["name"] as? String ?? ""))
            completionHandler(Bool(exactly: dataArray[0] as! NSNumber) ?? false, dataArray[1] as! String)
        }
    }
    
    private func readMessage(completionHandler: @escaping (_ message: Message) -> Void) {
        socket.on("receive") { (dataArray, socketAck) in
              let data = dataArray[0] as! NSDictionary
                      let sender = data["sender"] as! NSDictionary
                      let message = Message(_id: data["_id"] as? String, reciever: data["reciever"] as? String, text: data["text"] as? String, createdAt: data["createdAt"] as? String, updatedAt: data["updatedAt"] as? String, owner: data["owner"] as? String, sender: Sender(id: sender["id"] as? String, name: sender["name"] as? String ?? ""))
                      completionHandler(message)
        }
//        self.socket?.receive { [weak self] message in
//            guard let self = self else { return }
//            print("stex")
//            print(message)
//            switch message {
//            case .success(.data(let data)):
//                self.delegate?.webSocket(self, didReceiveData: data)
//                self.readMessage()
//
//            case .success:
//                debugPrint("Warning: Expected to receive data format but received a string. Check the websocket server config.")
//                self.readMessage()
//
//            case .failure:
//                self.disconnect()
//            }
//        }
    }
    
    func offer(roomName: String, payload: Dictionary<String, String>) {
        socket.emit("offer", roomName, payload)
    }
    
    func handleAnswer(completionHandler: @escaping (_ answer: Dictionary<String, String>) -> Void) {
            socket.on("answer") { (dataArray, socketAck) in
                
                let data = dataArray[0] as! Dictionary<String, String>
                self.delegate?.receiveData(sdp: data["sdp"] ?? "")
    //                      let sender = data["sender"] as! NSDictionary
    //                      let message = Message(_id: data["_id"] as? String, reciever: data["reciever"] as? String, text: data["text"] as? String, createdAt: data["createdAt"] as? String, updatedAt: data["updatedAt"] as? String, owner: data["owner"] as? String, sender: Sender(id: sender["id"] as? String, name: sender["name"] as? String ?? ""))
                completionHandler(data)
            }
        }
    
    func getCanditantes(completionHandler: @escaping (_ answer: Dictionary<String, Any>) -> Void) {
               socket.on("candidates") { (dataArray, socketAck) in
                let data = dataArray[0] as! Dictionary<String, Any>
                let json: Dictionary = ["candidate": data["candidate"] ?? "", "sdpMid": data["sdpMid"] ?? "", "sdpMLineIndex": data["sdpMLineIndex"] ?? ""] as [String : Any]
                self.delegate?.receiveCandidate(remoteCandidate: RTCIceCandidate(sdp: (data["candidate"] as! String), sdpMLineIndex: data["sdpMLineIndex"] as! Int32, sdpMid: data["sdpMid"] as! String))
                completionHandler(json)
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

