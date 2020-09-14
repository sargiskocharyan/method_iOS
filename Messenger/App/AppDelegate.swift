//
//  AppDelegate.swift
//  Messenger
//
//  Created by Employee1 on 5/21/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown
import Firebase
import CallKit
import CoreData
import UserNotifications
import PushKit

protocol AppDelegateD : class {
    func startCallD(id: String, roomName: String, name: String, type: String, completionHandler: @escaping () -> ())
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate {
    
    //    let nc = NotificationCenter.default
    weak var delegate: AppDelegateD?
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()
    var tabbar: MainTabBarController?
    //var badge: Int?
    var window: UIWindow?
    let name = Notification.Name("didReceiveData")
    var defaults: UserDefaults?
    var isVoIPCallStarted: Bool?
    let viewModel = AppDelegateViewModel()
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    @objc func handleNotification() {
        print("bcfgvjfgyvyugrvyugruvgrg-----")
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        //print("\n\n++++++++changed! \(change), \(object)")
    }
    
    
    
    func subscribeForChangesObservation() {
        defaults = UserDefaults(suiteName: "group.am.dynamic.method")
        defaults!.addObserver(self, forKeyPath: "Last", options: [.initial], context: nil)
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CallModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error {
                fatalError("Unresolved error, \((error as NSError).userInfo)")
            }
        })
        return container
    }()
    
    lazy var managedObjectContext : NSManagedObjectContext? = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if let managedObjectContext = appDelegate.managedObjectContext {
            return managedObjectContext
        } else {
            return nil
        }
    }()
    
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        //NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: NSNotification.Name("confirm"), object: nil)
        UserDataController().loadUserInfo()
        subscribeForChangesObservation()
        DropDown.startListeningToKeyboard()
        FirebaseApp.configure()
        providerDelegate = ProviderDelegate(callManager: callManager)
        UNUserNotificationCenter.current().delegate = self
        self.voipRegistration()
        let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
        if remoteNotif != nil {
            let aps = remoteNotif!["aps"] as? [String:AnyObject]
            NSLog("\n Custom: \(String(describing: aps))")
            
            if remoteNotif!["chatId"] != nil && remoteNotif!["messageId"] != nil {
                backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "backgroundTask") {
                    print("kokoaPods")
                    self.endBackgroundTask(task: &self.backgroundTask)
                }
                SocketTaskManager.shared.connect {
                    print(remoteNotif!["chatId"] as! String)
                    SocketTaskManager.shared.messageReceived(chatId: remoteNotif!["chatId"] as! String, messageId: remoteNotif!["messageId"] as! String) {
                        SocketTaskManager.shared.disconnect{
                            self.endBackgroundTask(task: &self.backgroundTask)
                        }
                    }
                }
            }
        } else {
            NSLog("//////////////////////////Normal launch")
            setInitialStoryboard()
        }
        return true
    }
    
    func endBackgroundTask(task: inout UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            print("Permission granted: \(granted)")
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            UNUserNotificationCenter.current().delegate = self
        }
        print(UIApplication.shared.applicationState.rawValue)
        return false
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print(RemoteNotificationManager.didReceiveVoiDeviceToken(token: deviceToken))
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
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        print(RemoteNotificationManager.didReceiveVoiDeviceToken(token: pushCredentials.token))
        SharedConfigs.shared.voIPToken = RemoteNotificationManager.didReceiveVoiDeviceToken(token: pushCredentials.token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("payload: ", payload.dictionaryPayload)
        print(payload.dictionaryPayload["username"] as! String)
        self.delegate?.startCallD(id: payload.dictionaryPayload["id"] as! String, roomName: payload.dictionaryPayload["roomName"] as! String, name: payload.dictionaryPayload["username"] as! String, type: payload.dictionaryPayload["type"] as! String, completionHandler: {
            self.displayIncomingCall(
            id: payload.dictionaryPayload["id"] as! String, uuid: UUID(), handle: payload.dictionaryPayload["username"] as! String, hasVideo: true, roomName: payload.dictionaryPayload["roomName"] as! String) { _ in
                SocketTaskManager.shared.connect {
                    self.isVoIPCallStarted = true
                    self.tabbar?.videoVC?.isCallHandled = true
                    SocketTaskManager.shared.checkCallState(roomname: payload.dictionaryPayload["roomName"] as! String)
                    completion()
                }
            }
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType:")
    }
    
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    
    
    func displayIncomingCall(id: String, uuid: UUID, handle: String, hasVideo: Bool = false, roomName: String, completion: ((Error?) -> Void)?) {
        providerDelegate.reportIncomingCall( id: id, uuid: uuid, handle: handle, hasVideo: hasVideo, roomName: roomName, completion: completion)
    }
    
}

// MARK: Extension
extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications() {
        //RemoteNotificationManager.requestPermissions()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //        UNUserNotificationCenter.current().delegate = self
        if notification.request.content.categoryIdentifier == "local" || notification.request.content.categoryIdentifier == "contactRequest" {
            completionHandler([.alert, .badge, .sound])
        } else {
            completionHandler([])
        }
    }
    
    func application(_ application: UIApplication,
              continue userActivity: NSUserActivity,
              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {

        if userActivity.activityType == "INStartVideoCallIntent" {
            // treat start video
        }
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        switch response.actionIdentifier {
        case "first":
            print("first")
            let userinfo = response.notification.request.content.userInfo
            viewModel.confirmRequest(id: userinfo["userId"] as! String, confirm: true) { (error) in
                if error == nil {
                    print("confirmed")
                }
            }
        case "second":
            print("second")
            let userinfo = response.notification.request.content.userInfo
            viewModel.confirmRequest(id: userinfo["userId"] as! String, confirm: false) { (error) in
                if error == nil {
                    print("merjec")
                }
            }
        default:
            print("default")
        }
        completionHandler()
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        SocketTaskManager.shared.disconnect{}
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        if window?.rootViewController == nil {
            setInitialStoryboard()
        } else {
            if let vc = (tabbar?.viewControllers?[0] as? UINavigationController)?.viewControllers[0] as? CallListViewController {
                if (tabbar?.viewControllers?[0] as? UINavigationController)?.viewControllers.count == 1 && tabbar?.selectedIndex == 0 {
                    vc.viewWillAppear(false)
                }
            }
        }
        if SharedConfigs.shared.signedUser != nil {
            SocketTaskManager.shared.connect {
                print("scene page connect")
            }
        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        if userInfo["type"] as? String == "message" {
            backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "krakadil") {
                self.endBackgroundTask(task: &self.backgroundTask)
            }
            SocketTaskManager.shared.connect {
                let vc = (self.tabbar?.viewControllers?[1] as? UINavigationController)?.viewControllers[0] as? RecentMessagesViewController
                for i in 0..<(vc?.chats.count ?? 0) {
                    if vc?.chats[i].id == userInfo["chatId"] as? String {
                        if (vc?.chats[i].unreadMessageExists != nil) && !(vc?.chats[i].unreadMessageExists)! {
                            var oldModel = SharedConfigs.shared.signedUser
                            if oldModel?.unreadMessagesCount != nil {
                                oldModel?.unreadMessagesCount! += 1
                            } else {
                                oldModel?.unreadMessagesCount = 1
                            }
                            UserDataController().populateUserProfile(model: oldModel!)
                            vc?.chats[i].unreadMessageExists = true
                            let user = SharedConfigs.shared.signedUser
                            DispatchQueue.main.async {
                                let nc = self.tabbar?.viewControllers?[2] as? UINavigationController
                                let profile = nc?.viewControllers[0] as? ProfileViewController
                                profile?.changeNotificationNumber()
                                UIApplication.shared.applicationIconBadgeNumber = ((user?.missedCallHistoryCount ?? 0) + (user?.unreadMessagesCount ?? 0))
                            }
                            if let tabItems = self.tabbar?.tabBar.items {
                                let tabItem = tabItems[1]
                                tabItem.badgeValue = oldModel?.unreadMessagesCount != nil && oldModel!.unreadMessagesCount! > 0 ? "\(oldModel!.unreadMessagesCount!)" : nil
                            }
                            break
                        }
                    }
                }

                
                print(userInfo["chatId"] as! String)
                SocketTaskManager.shared.messageReceived(chatId: userInfo["chatId"] as! String, messageId: userInfo["messageId"] as! String) {
                    
                    SocketTaskManager.shared.disconnect {
                        self.endBackgroundTask(task: &self.backgroundTask)
                        completionHandler(.newData)
                    }
                }
            }
        }
        if userInfo["type"] as? String == "missedCallHistory" {
            if let badge = aps["badge"] as? Int {
                var oldModel = SharedConfigs.shared.signedUser
                oldModel?.missedCallHistoryCount = badge
                UserDataController().populateUserProfile(model: oldModel!)
                let nc = tabbar?.viewControllers?[2] as? UINavigationController
                let profile = nc?.viewControllers[0] as? ProfileViewController
                profile?.changeNotificationNumber()
                if tabbar?.selectedIndex == 0 {
                    let nc = tabbar!.viewControllers![0] as! UINavigationController
                    if nc.viewControllers.count > 1 {
                        if let tabItems = self.tabbar?.tabBar.items {
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
                    if let tabItems = self.tabbar?.tabBar.items {
                        let tabItem = tabItems[0]
                        tabItem.badgeValue = badge > 0 ? "\(badge)" : nil
                        print(badge as Any)
                    }
                }
            }
            completionHandler(.newData)
        }
    }
    
    //MARK:- Helper
    
    func setInitialStoryboard() {
        defineMode()
        defineStartController()
    }
    
    func defineStartController() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        UserDataController().loadUserInfo()
        if SharedConfigs.shared.signedUser == nil {
            AuthRouter().assemblyModule()
        } else {
            MainRouter().assemblyModule()
        }
    }
    
    func defineMode() {
        if UserDefaults.standard.object(forKey: "mode") as? String == "dark" {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
            SharedConfigs.shared.setMode(selectedMode: "dark")
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
            SharedConfigs.shared.setMode(selectedMode: "light")
        }
    }
}

extension AppDelegate: Subscriber {
    func didHandleConnectionEvent() {
        
    }
}
