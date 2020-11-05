//
//  NotificationManager.swift
//  Messenger
//
//  Created by Employee1 on 11/4/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import PushKit

protocol NotificationManagerDelegate: class {
    func startCall(id: String, roomName: String, name: String, type: String, completionHandler: @escaping () -> ())
}

class NotificationManager {
    
    var message = "message"
    var contactRequest = "contactRequest"
    var missedCallHistory = "missedCallHistory"
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
    
    func getMessage(_ userInfo: [AnyHashable : Any], _ tabbar: MainTabBarController?, _ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "krakadil") {
            self.endBackgroundTask(task: &self.backgroundTask)
        }
        SocketTaskManager.shared.connect {
            if let chatId = userInfo["chatId"] as? String, let messageId = userInfo["messageId"] as? String {
            let vc = (tabbar?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? RecentMessagesViewController
            for i in 0..<(vc?.chats.count ?? 0) {
                if vc?.chats[i].id == chatId {
                    if (vc?.chats[i].unreadMessageExists != nil) && !(vc?.chats[i].unreadMessageExists)! {
                        SharedConfigs.shared.unreadMessages.append(vc!.chats[i])
                        vc?.chats[i].unreadMessageExists = true
                        DispatchQueue.main.async {
                            let nc = tabbar?.viewControllers?[2] as? UINavigationController
                            let profile = nc?.viewControllers[0] as? ProfileViewController
                            profile?.changeNotificationNumber()
                            UIApplication.shared.applicationIconBadgeNumber = SharedConfigs.shared.getNumberOfNotifications()
                        }
                        if let tabItems = tabbar?.tabBar.items {
                            let tabItem = tabItems[1]
                            tabItem.badgeValue = SharedConfigs.shared.unreadMessages.count > 0  ? "\(SharedConfigs.shared.unreadMessages.count)" : nil
                        }
                        break
                    }
                }
            }
            
            SocketTaskManager.shared.messageReceived(chatId: chatId, messageId: messageId) {
                SocketTaskManager.shared.disconnect {
                    self.endBackgroundTask(task: &self.backgroundTask)
                    completionHandler(.newData)
                }
            }
            }
        }
    }
    
    
    func getNotBody(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
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
    
    func receivedCall(_ tabbar: MainTabBarController?, _ aps: [String : AnyObject], _ application: UIApplication, _ completionHandler: (UIBackgroundFetchResult) -> Void) {
        if let badge = aps["badge"] as? Int {
            let nc = tabbar?.viewControllers?[2] as? UINavigationController
            let profile = nc?.viewControllers[0] as? ProfileViewController
            tabbar?.mainRouter?.notificationListViewController?.reloadData()
            profile?.changeNotificationNumber()
            if tabbar?.selectedIndex == 0 {
                let nc = tabbar!.viewControllers![0] as! UINavigationController
                if nc.viewControllers.count > 1 {
                    if let tabItems = tabbar?.tabBar.items {
                        let tabItem = tabItems[0]
                        tabItem.badgeValue = badge > 0 ? "\(badge)" : nil
                        print(badge as Any)
                    }
                } else {
                    if application.applicationState.rawValue == 0 && tabbar?.selectedIndex == 0 && (tabbar?.selectedViewController as! UINavigationController).viewControllers.count == 1 {
                        (nc.viewControllers[0] as! CallListViewController).viewWillAppear(false)
                    }
                }
            } else {
                if let tabItems = tabbar?.tabBar.items {
                    let tabItem = tabItems[0]
                    tabItem.badgeValue = badge > 0 ? "\(badge)" : nil
                    print(badge as Any)
                }
            }
        }
        completionHandler(.newData)
    }
    
    func didReceiveRemoteNotification(_ tabbar: MainTabBarController?, _ userInfo: [AnyHashable : Any], _ completionHandler: @escaping (UIBackgroundFetchResult) -> Void, _ aps: [String : AnyObject], _ application: UIApplication) {
        if let type = userInfo["type"] as? String {
            if type == contactRequest {
                if let request = userInfo["request"] as? NSDictionary {
                    let requestDictionary = request
                    if let sender = requestDictionary["sender"] as? String, let receiver = requestDictionary["receiver"] as? String, let createdAt = requestDictionary["createdAt"] as? String, let updatedAt = requestDictionary["updatedAt"] as? String, let id = requestDictionary["_id"] as? String {
                        let request = Request(_id: id, sender: sender, receiver: receiver, createdAt: createdAt, updatedAt: updatedAt)
                        SharedConfigs.shared.contactRequests.append(request)
                        tabbar?.mainRouter?.notificationListViewController?.reloadData()
                    }
                }
            }
            if type == message {
                getMessage(userInfo, tabbar, completionHandler)
            }
            if type == missedCallHistory {
                receivedCall(tabbar, aps, application, completionHandler)
            }
        }
    }
}
