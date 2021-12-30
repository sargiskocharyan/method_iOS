//
//  NotificationManager.swift
//  Messenger
//
//  Created by Employee1 on 11/4/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import PushKit

protocol NotificationManagerDelegate: AnyObject {
    func startCall(id: String, roomName: String, name: String, type: String, completionHandler: @escaping () -> ())
}

class NotificationManager {
    
  
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    weak var delegate: NotificationManagerDelegate?
    
    func registerDeviceToken(_ deviceToken: Data) {
        if UserDefaults.standard.bool(forKey: Keys.IS_REGISTERED) {
            SharedConfigs.shared.isRegistered = true
            SharedConfigs.shared.deviceToken = UserDefaults.standard.object(forKey: Keys.PUSH_DEVICE_TOKEN) as? String
            SharedConfigs.shared.voIPToken = UserDefaults.standard.object(forKey: Keys.VOIP_DEVICE_TOKEN) as? String
            SharedConfigs.shared.deviceUUID = UIDevice.current.identifierForVendor!.uuidString
        } else {
            SharedConfigs.shared.deviceToken = RemoteNotificationManager.getDeviceToken(tokenData: deviceToken)
            if SharedConfigs.shared.signedUser != nil {
                RemoteNotificationManager.registerDeviceToken(pushDevicetoken: SharedConfigs.shared.deviceToken!, voipDeviceToken: SharedConfigs.shared.voIPToken!) { (error) in
                    if error != nil {
                        print(error as Any)
                    }
                }
            }
        }
    }
    
    func  displayIncomingCall(_ payload: PKPushPayload, _ tabbar: MainTabBarController?, _ completion: @escaping () -> ()) {
        if let id = payload.dictionaryPayload["id"] as? String, let roomname =  payload.dictionaryPayload["roomName"] as? String, let name = payload.dictionaryPayload["username"] as? String, let type = payload.dictionaryPayload["type"] as? String {
            self.delegate!.startCall(id: id, roomName: roomname, name: name, type: type) {
                AppDelegate.shared.displayIncomingCall(id: id, uuid: UUID(), handle: name, hasVideo: true, roomName: roomname) { (_) in
                    SocketTaskManager.shared.connect {
                        AppDelegate.shared.isVoIPCallStarted = true
                        tabbar?.videoVC?.isCallHandled = true
                        SocketTaskManager.shared.checkCallState(roomname: roomname)
                        completion()
                    }
                }
            }
        }
    }
    
    func confirmContactRequest(_ request: NSDictionary?, _ tabbar: MainTabBarController?) {
        if let sender = request?["sender"] as? String, let id = request?["_id"] as? String {
            AppDelegate.shared.viewModel.confirmRequest(id: sender, confirm: true) { (error) in
                if error == nil {
                    SharedConfigs.shared.contactRequests = SharedConfigs.shared.contactRequests.filter({ (req) -> Bool in
                        return req._id != id
                    })
                    DispatchQueue.main.async {
                        tabbar?.mainRouter?.notificationListViewController?.reloadData()
                    }
                }
            }
        }
    }
    
    func rejectContactRequest(_ request: NSDictionary?, _ tabbar: MainTabBarController?) {
        if let sender = request?["sender"] as? String, let id = request?["_id"] as? String {
            AppDelegate.shared.viewModel.confirmRequest(id: sender, confirm: false) { (error) in
                if error == nil {
                    SharedConfigs.shared.contactRequests = SharedConfigs.shared.contactRequests.filter({ (req) -> Bool in
                        return req._id != id
                    })
                    DispatchQueue.main.async {
                        tabbar?.mainRouter?.notificationListViewController?.reloadData()
                    }
                }
            }
        }
    }
    
    func endBackgroundTask(task: inout UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
    }
    
    
    func sendMessageReceived(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
        if remoteNotif != nil {
            if let chatId = remoteNotif!["chatId"] as? String, let messageId = remoteNotif!["messageId"] as? String {
                backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "backgroundTask") {
                    self.endBackgroundTask(task: &self.backgroundTask)
                }
                SocketTaskManager.shared.connect {
                    SocketTaskManager.shared.messageReceived(chatId: chatId, messageId: messageId) {
                        SocketTaskManager.shared.disconnect{
                            self.endBackgroundTask(task: &self.backgroundTask)
                        }
                    }
                }
            }
        } else {
            AppDelegate.shared.setInitialStoryboard()
        }
    }
    
    func didReceiveRemoteNotification(_ userInfo: [AnyHashable : Any], _ aps: [String : AnyObject], _ application: UIApplication, completion: @escaping (_ type: String) -> ()) {
        if let type = userInfo["type"] as? String {
            if type == NotificationType.contactRequest.rawValue {
                if let request = userInfo["request"] as? NSDictionary {
                    let requestDictionary = request
                    if let sender = requestDictionary["sender"] as? String, let receiver = requestDictionary["receiver"] as? String, let createdAt = requestDictionary["createdAt"] as? String, let updatedAt = requestDictionary["updatedAt"] as? String, let id = requestDictionary["_id"] as? String {
                        let request = Request(_id: id, sender: sender, receiver: receiver, createdAt: createdAt, updatedAt: updatedAt)
                        SharedConfigs.shared.contactRequests.append(request)
                    }
                }
            }
            completion(type)
        }
    }
}
