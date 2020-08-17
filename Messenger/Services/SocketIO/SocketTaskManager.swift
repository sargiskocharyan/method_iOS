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
    
    
    func connect(completionHandler: @escaping () -> ()) {
        manager = SocketManager(socketURL: URL(string: Environment.baseURL)!, config: [.log(true), .connectParams(["token": KeyChain.load(key: "token")?.toString() ?? ""]), .forceNew(true), .compress])
        if socket.status != .connecting || socket.status != .connected {//socket.status.active
        socket.connect()
        socket.on(clientEvent: .connect) {data, ack in
            print("socket connected")
            completionHandler()
        }
        socket.on(clientEvent: .error) {data, ack in
            print("error")
            completionHandler()
        }
        } else {
            completionHandler()
        }
    }
    
    func emit() {
        socket.emit("join") {
            print("join")
        }
    }
    
    func leaveRoom(roomName: String) {
        self.socket.emit("leaveRoom", roomName)
    }
    
    func send(data: Dictionary<String, Any>, roomName: String) {
        self.socket.emit("candidates", roomName, data)
    }
    
    func call(id: String, completionHandler: @escaping (_ roomname: String) -> ()) {
        socket.emitWithAck("call", id).timingOut(after: 0.0) { (dataArray) in
            completionHandler(dataArray[0] as! String)
        }
    }
    
    func callStarted(roomname: String) {
        self.socket.emit("callStarted", roomname)
    }
    
    func callReconnected(roomname: String) {
        self.socket.emit("reconnectCallRoom", roomname)
    }
    
    func callAccepted(id: String, isAccepted: Bool) {
        socket.emit("callAccepted", id, isAccepted) {
            print("callAccepted")
        }
    }
    
    func handleCall(completionHandler: @escaping (_ id: String, _ roomname: String, _ name: String) -> Void) {
        socket.on("call") { (dataArray, socketAck) in
            let dictionary = dataArray[0] as! Dictionary<String, String?>
            completionHandler(dictionary["caller"]!!, dictionary["roomName"]!!, dictionary["username"]!!)
        }
    }
    
    func handleCallSessionEnded(completionHandler: @escaping (_ roomName: String) -> Void) {
        socket.on("callSessionEnded") { (dataArray, socketAck) in
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
            completionHandler(Bool(exactly: dataArray[0] as! NSNumber) ?? false, dataArray[1] as! String)
        }
    }
    
//    private func readMessage(completionHandler: @escaping (_ message: Message) -> Void) {
//        socket.on("receive") { (dataArray, socketAck) in
//            let data = dataArray[0] as! NSDictionary
//            if let call = data["call"] as? NSDictionary {
//                let messageCall = MessageCall(callSuggestTime: call["callSuggestTime"] as? String, type: call["type"] as? String, status: call["status"] as? String, duration: call["duration"] as? Float)
//                let message = Message(call: messageCall, type: data["type"] as? String, _id: data["_id"] as? String, reciever: data["reciever"] as? String, text: data["text"] as? String, createdAt: data["createdAt"] as? String, updatedAt: data["updatedAt"] as? String, owner: data["owner"] as? String, senderId: data["senderId"] as? String)
//            completionHandler(message)
//            }
//        }
//    }
    
    func offer(roomName: String, payload: Dictionary<String, String>) {
        socket.emit("offer", roomName, payload)
    }
    
    func handleAnswer(completionHandler: @escaping (_ answer: Dictionary<String, String>) -> Void) {
            socket.on("answer") { (dataArray, socketAck) in
                
                let data = dataArray[0] as! Dictionary<String, String>
                self.delegate?.receiveData(sdp: data["sdp"] ?? "")
                completionHandler(data)
            }
        }
    
    func getCanditantes(completionHandler: @escaping (_ answer: Dictionary<String, Any>) -> Void) {
               socket.on("candidates") { (dataArray, socketAck) in
                let data = dataArray[0] as! Dictionary<String, Any>
                let json: Dictionary = ["candidate": data["candidate"] ?? "", "sdpMid": data["sdpMid"] ?? "", "sdpMLineIndex": data["sdpMLineIndex"] ?? ""] as [String : Any]
                self.delegate?.receiveCandidate(remoteCandidate: RTCIceCandidate(sdp: (data["candidate"] as! String), sdpMLineIndex: data["sdpMLineIndex"] as! Int32, sdpMid: data["sdpMid"] as? String))
                completionHandler(json)
               }
           }
    
    func send(message: String, id: String) {
        socket.emit("sendMessage", message, id) 
    }
    
    func disconnect() {
        socket.disconnect()
        leaveRoom(roomName: "")
    }
    
    
    
    func handleCallEnd(completionHandler: @escaping (_ roomName: String) -> Void) {
           socket.on("callEnded") { (dataArray, socketAck) -> Void in
               completionHandler(dataArray[0] as! String)
           }
       }
    
    func getChatMessage(completionHandler: @escaping (_ callHistory: CallHistory?, _ message: Message, _ senderName: String?, _ senderLastname: String?, _ senderUsername: String?) -> Void) {
        socket.on("message") { (dataArray, socketAck) -> Void in
            let data = dataArray[0] as! NSDictionary
            if let call = data["call"] as? NSDictionary {
                let messageCall = MessageCall(callSuggestTime: call["callSuggestTime"] as? String, type: call["type"] as? String, status: call["status"] as? String, duration: call["duration"] as? Float)
                let callHistory = CallHistory(type: call["type"] as? String, receiver: call["receiver"] as? String, status: call["status"] as? String, participants: call["participants"] as? [String], callSuggestTime: call["callSuggestTime"] as? String, _id: call["_id"] as? String, createdAt: call["createdAt"] as? String, caller: call["caller"] as? String, callEndTime: call["callEndTime"] as? String, callStartTime: call["callStartTime"] as? String)
                print(callHistory)
                let message = Message(call: messageCall, type: data["type"] as? String, _id: data["_id"] as? String, reciever: data["reciever"] as? String, text: data["text"] as? String, createdAt: data["createdAt"] as? String, updatedAt: data["updatedAt"] as? String, owner: data["owner"] as? String, senderId: data["senderId"] as? String)
            completionHandler(callHistory, message, data["senderName"] as? String, data["senderLastname"] as? String, data["senderUsername"] as? String)
                return
            }
            if let text = data["text"] as? String {
                let message = Message(call: nil, type: data["type"] as? String, _id: data["_id"] as? String, reciever: data["reciever"] as? String, text: text, createdAt: data["createdAt"] as? String, updatedAt: data["updatedAt"] as? String, owner: data["owner"] as? String, senderId: data["senderId"] as? String)
                completionHandler(nil, message, data["senderName"] as? String, data["senderLastname"] as? String, data["senderUsername"] as? String)
                return
            }
        }
    }
}

