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
    var badge: Int?
    var window: UIWindow?
    let name = Notification.Name("didReceiveData")
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    @objc func handleNotification() {
        print("bcfgvjfgyvyugrvyugruvgrg-----")
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
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification), name: NSNotification.Name("confirm"), object: nil)
        badge = UserDefaults.standard.value(forKey: "badge") as? Int
        DropDown.startListeningToKeyboard()
        FirebaseApp.configure()
        providerDelegate = ProviderDelegate(callManager: callManager)
        registerForPushNotifications()
        self.voipRegistration()
        UNUserNotificationCenter.current().delegate = self
        let remoteNotif = launchOptions?[UIApplication.LaunchOptionsKey.remoteNotification] as? [String: Any]
        if remoteNotif != nil {
            let aps = remoteNotif!["aps"] as? [String:AnyObject]
            NSLog("\n Custom: \(String(describing: aps))")
            UserDataController().loadUserInfo()
            SocketTaskManager.shared.connect {
                print(remoteNotif!["chatId"] as! String)
                SocketTaskManager.shared.messageReceived(chatId: remoteNotif!["chatId"] as! String, messageId: remoteNotif!["messageId"] as! String) {
                    SocketTaskManager.shared.disconnect()
                }
            }
        }
        else {
            NSLog("//////////////////////////Normal launch")
            setInitialStoryboard()
        }
        return true
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
                    completion()
                }
            }
        })
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
         UserDefaults.standard.set(badge, forKey: "badge")
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

extension AppDelegate: UNUserNotificationCenterDelegate {
    func registerForPushNotifications() {
        RemoteNotificationManager.requestPermissions()
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
    
  
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        print(launchOptions)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification) , name: name, object: nil)
        print(UIApplication.shared.applicationState.rawValue)
        return false
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
       SocketTaskManager.shared.disconnect()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
       if SharedConfigs.shared.signedUser != nil {
            SocketTaskManager.shared.connect {
                print("scene page connect")
            }
        }
        
//        let tabbar = window?.rootViewController as? MainTabBarController
//        if tabbar?.selectedIndex == 0 {
//            let nc = tabbar!.viewControllers![0] as! UINavigationController
//            if (nc.viewControllers.last as? CallListViewController) != nil {
//                (nc.viewControllers[0] as! CallListViewController).viewWillAppear(false)
//            }
//        }
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
//        print(userInfo)
        if userInfo["type"] as? String == "message" {
            SocketTaskManager.shared.connect {
                print(userInfo["chatId"] as! String)
                SocketTaskManager.shared.messageReceived(chatId: userInfo["chatId"] as! String, messageId: userInfo["messageId"] as! String) {
                    SocketTaskManager.shared.disconnect()
                    completionHandler(.newData)
                }
            }
        }
       
        if userInfo["type"] as? String == "missedCallHistory" {
            badge = aps["badge"] as? Int
            if tabbar?.selectedIndex == 0 {
                let nc = tabbar!.viewControllers![0] as! UINavigationController
                if nc.viewControllers.count > 1 {
                    if let tabItems = self.tabbar?.tabBar.items {
                        let tabItem = tabItems[0]
                        tabItem.badgeValue = badge != nil && badge! > 0 ? "\(badge!)" : nil
                        print(badge as Any)
                    }
                } else {
                    if application.applicationState.rawValue == 0 {
                        (nc.viewControllers[0] as! CallListViewController).viewWillAppear(false)
                    }
                }
            } else {
                if let tabItems = self.tabbar?.tabBar.items {
                    let tabItem = tabItems[0]
                    tabItem.badgeValue = badge != nil && badge! > 0 ? "\(badge!)" : nil
                    print(badge as Any)
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
        //self.window?.makeKeyAndVisible()
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
