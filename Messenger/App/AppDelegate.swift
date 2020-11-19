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
import UIKit
import FBSDKCoreKit

protocol AppDelegateProtocol : class {
    func startCallD(id: String, roomName: String, name: String, type: String, completionHandler: @escaping () -> ())
}

enum NotificationType : String {
    case message = "message"
    case contactRequest = "contactRequest"
    case missedCall = "missedCallHistory"
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, PKPushRegistryDelegate {
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()
    var tabbar: MainTabBarController?
    var callModel = "CallModel"
    var localCategoryIdentifier = "local"
    var remoteCategoryIdentifier = "contactRequest"
    var firstActionIdentifier = "first"
    var secondActionIdentifier = "second"
    var message = "message"
    var contactRequest = "contactRequest"
    var missedCallHistory = "missedCallHistory"
    let name = Notification.Name("didReceiveData")
    var window: UIWindow?
    var defaults: UserDefaults?
    var isVoIPCallStarted: Bool?
    let viewModel = AppDelegateViewModel()
    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
    var notificationManager = NotificationManager()
    
    class var shared: AppDelegate {
        return UIApplication.shared.delegate as! AppDelegate
    }

    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: callModel)
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
    
    func getNotificationBody(_ launchOptions: [UIApplication.LaunchOptionsKey : Any]?) {
        notificationManager.sendMessageReceived(launchOptions)
    }
    
    func application( _ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool { ApplicationDelegate.shared.application( app, open: url, sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UserDataController().loadUserInfo()
        DropDown.startListeningToKeyboard()
        FirebaseApp.configure()
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions )
        providerDelegate = ProviderDelegate(callManager: callManager)
        UNUserNotificationCenter.current().delegate = self
        self.voipRegistration()
        getNotificationBody(launchOptions)
        return true
    }
    
    func endBackgroundTask(task: inout UIBackgroundTaskIdentifier) {
        UIApplication.shared.endBackgroundTask(task)
        task = .invalid
    }
    
    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
            (granted, error) in
            guard granted else { return }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
            UNUserNotificationCenter.current().delegate = self
        }
        return false
    }
    
   
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let firebaseAuth = Auth.auth()
        firebaseAuth.setAPNSToken(deviceToken, type: AuthAPNSTokenType.unknown)
        notificationManager.registerDeviceToken(deviceToken)
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        SharedConfigs.shared.voIPToken = RemoteNotificationManager.didReceiveVoiDeviceToken(token: pushCredentials.token)
        
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
        notificationManager.displayIncomingCall(payload, tabbar) {
            completion()
        }
    }
    
    func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        print("pushRegistry:didInvalidatePushTokenForType: \(type.rawValue)")
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
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        if notification.request.content.categoryIdentifier == localCategoryIdentifier || notification.request.content.categoryIdentifier == remoteCategoryIdentifier {
            completionHandler([.alert, .badge, .sound])
        } else {
            completionHandler([])
        }
    }
    
    func application(_ application: UIApplication,
              continue userActivity: NSUserActivity,
              restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        return true
    }
    
  
    
    
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userinfo = response.notification.request.content.userInfo
        let request = userinfo["request"] as? NSDictionary
        switch response.actionIdentifier {
        case firstActionIdentifier:
            notificationManager.confirmContactRequest(request, tabbar)
        case secondActionIdentifier:
            notificationManager.rejectContactRequest(request, tabbar)
        default:
            break
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
            SocketTaskManager.shared.connect {}
        }
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
    
    func getMessage(_ userInfo: [AnyHashable : Any], _ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "backgroundTask") {
            self.endBackgroundTask(task: &self.backgroundTask)
        }
        SocketTaskManager.shared.connect { [self] in
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
    
    func receivedCall(_ aps: [String : AnyObject], _ application: UIApplication, _ completionHandler: (UIBackgroundFetchResult) -> Void) {
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
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let firebaseAuth = Auth.auth()
        if (firebaseAuth.canHandleNotification(userInfo)) {
            print(userInfo)
            return
        }
        guard let aps = userInfo["aps"] as? [String: AnyObject] else {
            completionHandler(.failed)
            return
        }
        notificationManager.didReceiveRemoteNotification(userInfo, aps, application) { [self] (type) in
            if type == NotificationType.contactRequest.rawValue {
                self.tabbar?.mainRouter?.notificationListViewController?.reloadData()
            } else if type == NotificationType.message.rawValue {
                getMessage(userInfo, completionHandler)
            } else if type == NotificationType.missedCall.rawValue {
                receivedCall(aps, application, completionHandler)
            }
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
