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

protocol Subscriber {
    func didHandleConnectionEvent()
}

enum Status {
    case connected
    case connecting
    case notConnected
    case disconnected
}

class SocketTaskManager {
    var tabbar: MainTabBarController?
    private var completions: [()->()] = []
    static let shared = SocketTaskManager()
    weak var delegate: SocketIODelegate?
    private var lock: NSLock = NSLock()
    private var subscribers: [Subscriber] = []
    private var status: SocketIOStatus = .notConnected
    let queue = DispatchQueue(label: "queue", qos: .default, attributes: [], autoreleaseFrequency: .inherit, target: nil)
    var socket: SocketIOClient? {
        return manager?.defaultSocket
    }
    
    var manager: SocketManager?
    
    private init () { }
    
    func changeSocketStatus(status: SocketIOStatus) {
        lock.lock()
        self.status = status
        lock.unlock()
    }
    
    func connect(completionHandler: @escaping () -> ()) {
        if status == .disconnected || status == .notConnected {
            print(SharedConfigs.shared.signedUser?.token as Any)
            manager = SocketManager(socketURL: URL(string: Environment.baseURL)!, config: [.log(false), .connectParams(["token": SharedConfigs.shared.signedUser?.token ?? ""]), .forceNew(true), .compress])
        }
        if status == .connected {
            queue.sync {
                completions.append(completionHandler)
            }
            for completion in completions {
                completion()
            }
            completions.removeAll()
        } else if status == .connecting {
            queue.sync {
                completions.append(completionHandler)
            }
        } else {
            queue.sync {
                completions.append(completionHandler)
            }
            socket!.connect()
            changeSocketStatus(status: .connecting)
            self.addAuthenticatedListener {
                self.manager?.reconnects = true
                self.changeSocketStatus(status: .connected)
                print(self.socket!.handlers)
                if self.socket!.handlers.count <= 2 {
                    self.tabbar?.handleCallAccepted()
                    self.tabbar?.handleCall()
                    self.tabbar?.handleAnswer()
                    self.tabbar?.handleCallSessionEnded()
                    self.tabbar?.handleOffer()
                    self.tabbar?.getCandidates()
                    self.tabbar?.handleCallEnd()
                    self.tabbar?.getNewMessage()
                    self.tabbar?.handleReadMessage()
                    self.tabbar?.handleReceiveMessage()
                    self.tabbar?.handleMessageTyping()
                    self.tabbar?.handleNewContact()
                    self.tabbar?.handleNewContactRequest()
                    self.tabbar?.handleContactRequestRejected()
                    self.tabbar?.handleContactRemoved()
                    self.addErrorListener()
                }
                for compleion in self.completions {
                    compleion()
                }
                self.completions.removeAll()
            }
        }
    }
    
    func addAuthenticatedListener(completionHandler: @escaping () -> ()) {
        socket?.on("authenticated", callback: { (dataArray, socketAck) in
            if dataArray[0] as! Bool == true {
                completionHandler()
            } else {
                print("error")
            }
        })
    }
    
    func emit() {
        socket!.emit("join") {
            print("join")
        }
    }
    
    func messageReceived(chatId: String, messageId: String, completionHandler: @escaping () -> ()) {
        socket?.emit("messageReceived", chatId, messageId) {
            print("message Received")
            completionHandler()
        }
    }
    
    func messageRead(chatId: String, messageId: String) {
           socket?.emit("messageRead", chatId, messageId) {
               print("message Read")
           }
       }
    
    
    
    func messageTyping(chatId: String) {
        socket?.emit("messageTyping", chatId)
    }
    
    func addMessageReceivedListener(completionHandler: @escaping (_ createdAt: String, _ userId: String) -> ()) {
        socket?.on("messageReceived") {dataArray, socketAck in
            completionHandler(dataArray[0] as! String, dataArray[1] as! String)
        }
    }
    
    func addMessageReadListener(completionHandler: @escaping (_ createdAt: String, _ userId: String) -> ()) {
        socket?.on("messageRead") {dataArray, socketAck in
            completionHandler(dataArray[0] as! String, dataArray[1] as! String)
        }
    }
    
    func addMessageTypingListener(completionHandler: @escaping (_ userId: String) -> ()) {
        socket?.on("messageTyping") {dataArray, socketAck in
            completionHandler(dataArray[0] as! String)
        }
    }
    
    func leaveRoom(roomName: String) {
        self.socket!.emit("leaveRoom", roomName)
    }
    
    func send(data: Dictionary<String, Any>, roomName: String) {
        self.socket!.emit("candidates", roomName, data)
    }
    
    func call(id: String, type: String, completionHandler: @escaping (_ roomname: String) -> ()) {
        socket!.emitWithAck("call", id, type).timingOut(after: 0.0) { (dataArray) in
            completionHandler(dataArray[0] as! String)
        }
    }

    func checkCallState(roomname: String) {
        socket!.emitWithAck("checkCallState", roomname).timingOut(after: 0.0) { (dataArray) in
//            completionHandler(dataArray[0] as! String)
        if dataArray[0] as! String != CallStatus.ongoing.rawValue {
            for call in AppDelegate.shared.callManager.calls {
                AppDelegate.shared.callManager.end(call: call)
            }
            AppDelegate.shared.callManager.removeAllCalls()
        }
     }
    }
    
    func callStarted(roomname: String) {
        self.socket!.emit("callStarted", roomname)
    }
    
    func callReconnected(roomname: String) {
        self.socket!.emit("reconnectCallRoom", roomname)
    }
    
    func callAccepted(id: String, isAccepted: Bool) {
        socket!.emit("callAccepted", id, isAccepted) {
            print("callAccepted")
        }
    }
    
    func addCallListener(completionHandler: @escaping (_ id: String, _ roomname: String, _ name: String, _ type: String) -> Void) {
        socket!.on("call") { (dataArray, socketAck) in
            let dictionary = dataArray[0] as! Dictionary<String, String?>
            completionHandler(dictionary["caller"]!!, dictionary["roomName"]!!, dictionary["username"]!!, dictionary["type"]!!)
        }
    }
    
    func addCallSessionEndedListener(completionHandler: @escaping (_ roomName: String) -> Void) {
        socket!.on("callSessionEnded") { (dataArray, socketAck) in
            completionHandler(dataArray[0] as! String)
        }
    }
  
    func addOfferListener(completionHandler: @escaping (_ roomName: String, _ answer: Dictionary<String, String>) -> Void) {
        socket!.on("offer") { (dataArray, socketAck) in
            let dic = dataArray[1] as! Dictionary<String, String>
            self.delegate?.receiveData(sdp: dic["sdp"] ?? "")
            completionHandler(dataArray[0] as! String, dataArray[1] as! Dictionary<String, String>)
        }
    }
    
    func answer(roomName: String, answer: Dictionary<String, String>) {
        socket!.emit("answer", roomName, answer) {
            print("answered")
        }
    }

    func addCallAcceptedLister(completionHandler: @escaping (_ accepted: Bool, _ roomName: String) -> Void) {
        socket!.on("callAccepted") { (dataArray, socketAck) in
            completionHandler(Bool(exactly: dataArray[0] as! NSNumber) ?? false, dataArray[1] as! String)
        }
    }
    
    func offer(roomName: String, payload: Dictionary<String, String>) {
        socket!.emit("offer", roomName, payload)
    }
    
    func addAnswerListener(completionHandler: @escaping (_ answer: Dictionary<String, String>) -> Void) {
            socket!.on("answer") { (dataArray, socketAck) in
                let data = dataArray[0] as! Dictionary<String, String>
                self.delegate?.receiveData(sdp: data["sdp"] ?? "")
                completionHandler(data)
            }
        }
    
    func addCandidatesListener(completionHandler: @escaping (_ answer: Dictionary<String, Any>) -> Void) {
        socket!.on("candidates") { (dataArray, socketAck) in
            let data = dataArray[0] as! Dictionary<String, Any>
            let json: Dictionary = ["candidate": data["candidate"] ?? "", "sdpMid": data["sdpMid"] ?? "", "sdpMLineIndex": data["sdpMLineIndex"] ?? ""] as [String : Any]
            self.delegate?.receiveCandidate(remoteCandidate: RTCIceCandidate(sdp: (data["candidate"] as! String), sdpMLineIndex: data["sdpMLineIndex"] as! Int32, sdpMid: data["sdpMid"] as? String))
            completionHandler(json)
        }
    }
    
    func addNewContactRequestListener(completionHandler: @escaping (_ userId: String) -> Void) {
        socket?.on("newContactRequest", callback: { (dataArray, socketAck) in
            completionHandler(dataArray[0] as! String)
        })
    }
    
    func addNewContactListener(completionHandler: @escaping (_ userId: String) -> Void) {
           socket?.on("newContact", callback: { (dataArray, socketAck) in
               completionHandler(dataArray[0] as! String)
           })
       }
    
    func addContactRequestRejectedListener(completionHandler: @escaping (_ userId: String) -> Void) {
        socket?.on("contactRequestRejected", callback: { (dataArray, socketAck) in
            completionHandler(dataArray[0] as! String)
        })
    }
    
    func addContactRemovedListener(completionHandler: @escaping (_ userId: String) -> Void) {
        socket?.on("contactRemoved", callback: { (dataArray, socketAck) in
            completionHandler(dataArray[0] as! String)
        })
    }
    
    func send(message: String, id: String) {
        socket!.emit("sendMessage", message, id)
    }
    
    func addErrorListener() {
        socket?.on(clientEvent: .error, callback: { (dataArray, socketAck) in
            print(dataArray)
        })
    }
    
    func disconnect(completion: @escaping () -> ()) {
        socket?.disconnect()
        manager?.reconnects = false
        changeSocketStatus(status: .disconnected)
    }
        
    func addCallEndListener(completionHandler: @escaping (_ roomName: String) -> Void) {
           socket!.on("callEnded") { (dataArray, socketAck) -> Void in
               completionHandler(dataArray[0] as! String)
           }
       }
    
    func getChatMessage(completionHandler: @escaping (_ callHistory: CallHistory?, _ message: Message, _ senderName: String?, _ senderLastname: String?, _ senderUsername: String?) -> Void) {
        socket!.on("message") { (dataArray, socketAck) -> Void in
            let data = dataArray[0] as! NSDictionary
            let chatId = data["reciever"] as? String == SharedConfigs.shared.signedUser?.id ? data["senderId"] as? String :  data["reciever"] as? String
            if data["senderId"] as? String != SharedConfigs.shared.signedUser?.id {
                self.messageReceived(chatId: chatId ?? "", messageId: data["_id"] as? String ?? "") {
                    print("messageReceived")
                }
            }
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
                let vc = (self.tabbar?.viewControllers![1] as! UINavigationController).viewControllers[0] as! RecentMessagesViewController
                for i in 0..<vc.chats.count {
                    if vc.chats[i].id == data["senderId"] as? String {
                        if !vc.chats[i].unreadMessageExists {
                            SharedConfigs.shared.unreadMessages.append(vc.chats[i])
                            self.tabbar?.mainRouter?.notificationListViewController?.reloadData()
                            DispatchQueue.main.async {
                                let nc = self.tabbar!.viewControllers![2] as! UINavigationController
                                let profile = nc.viewControllers[0] as! ProfileViewController
                                profile.changeNotificationNumber()
                            }
                            if let tabItems = self.tabbar?.tabBar.items {
                                let tabItem = tabItems[1]
                                tabItem.badgeValue = SharedConfigs.shared.unreadMessages.count > 0 ? "\(SharedConfigs.shared.unreadMessages.count)" : nil
                            }
                            break
                        }
                    }
                }
                return
            }
        }
    }
}

