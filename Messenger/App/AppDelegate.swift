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
    func startCallD(id: String, roomName: String, name: String, completionHandler: @escaping () -> ())
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate {
    
    let nc = NotificationCenter.default
    weak var delegate: AppDelegateD?
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()
    var tabbar: MainTabBarController?
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
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
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        SharedConfigs.shared.voIPToken = RemoteNotificationManager.didReceiveVoiDeviceToken(token: pushCredentials.token)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        print("payload: ", payload.dictionaryPayload)
        print(payload.dictionaryPayload["username"] as! String)
        delegate?.startCallD(id: payload.dictionaryPayload["id"] as! String, roomName: payload.dictionaryPayload["roomName"] as! String, name: payload.dictionaryPayload["username"] as! String, completionHandler: {
            self.displayIncomingCall(
            id: payload.dictionaryPayload["id"] as! String, uuid: UUID(), handle: payload.dictionaryPayload["username"] as! String, hasVideo: true, roomName: payload.dictionaryPayload["roomName"] as! String) { _ in
                completion()
            }
        })
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType:")
    }
      
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DropDown.startListeningToKeyboard()
        FirebaseApp.configure()
        providerDelegate = ProviderDelegate(callManager: callManager)
        registerForPushNotifications()
        self.voipRegistration()
        return true
    }
    
    func voipRegistration() {
        let mainQueue = DispatchQueue.main
        let voipRegistry: PKPushRegistry = PKPushRegistry(queue: mainQueue)
        voipRegistry.delegate = self
        voipRegistry.desiredPushTypes = [PKPushType.voIP]
    }
    
    // MARK: UISceneSession Lifecycle
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
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
        if UserDefaults.standard.bool(forKey: Keys.IS_REGISTERED) {
            SharedConfigs.shared.isRegistered = true
            SharedConfigs.shared.deviceToken = UserDefaults.standard.object(forKey: Keys.PUSH_DEVICE_TOKEN) as? String
            SharedConfigs.shared.voIPToken = UserDefaults.standard.object(forKey: Keys.VOIP_DEVICE_TOKEN) as? String
            SharedConfigs.shared.deviceUUID = UIDevice.current.identifierForVendor!.uuidString
//            if UserDefaults.standard.object(forKey: "deviceUUID") as! String != UIDevice.current.identifierForVendor?.uuidString {
//                SharedConfigs.shared.deviceUUID = UIDevice.current.identifierForVendor?.uuidString
//            }
        } else {
            SharedConfigs.shared.deviceToken = RemoteNotificationManager.didReceivePushDeviceToken(token: deviceToken)
            if SharedConfigs.shared.signedUser != nil && SharedConfigs.shared.signedUser?.token != nil {
                RemoteNotificationManager.registerDeviceToken(pushDevicetoken: SharedConfigs.shared.deviceToken!, voipDeviceToken: SharedConfigs.shared.voIPToken!) { (error) in
                    if error != nil {
                        print(error as Any)
                    }
                }
            }
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        // 1. Print out error if PNs registration not successful
        print("Failed to register for remote notifications with error: \(error)")
    }
    
//    func applicationDidEnterBackground(_ application: UIApplication) {
//        
//    }
//    
//    func applicationWillEnterForeground(_ application: UIApplication) {
//        
//    }
//    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
//        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
//          completionHandler(.failed)
//          return
//        }
//        print(aps)
//        completionHandler(.newData)
//    }
}

