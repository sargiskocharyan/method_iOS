//
//  HomePageViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//


import UIKit
import UserNotifications

class MainTabBarController: UITabBarController, UNUserNotificationCenterDelegate {
    
    
    //MARK: Properties
    let viewModel = HomePageViewModel()
    let socketTaskManager = SocketTaskManager.shared
    let center = UNUserNotificationCenter.current()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        verifyToken()
   
        self.socketTaskManager.connect()
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    func getNewMessage() {
        socketTaskManager.getChatMessage { (message) in
            let chatsNC = self.viewControllers![3] as! UINavigationController
            let chatsVC = chatsNC.viewControllers[0] as! RecentMessagesViewController
            switch self.selectedIndex {
                
            case 0, 1, 2, 4:
                self.selectedViewController?.scheduleNotification(center: self.center)
                
                chatsVC.getnewMessage(message: message)
                break
            case 3:
                let chatsVC = (self.selectedViewController?.children[0])! as! RecentMessagesViewController
                chatsVC.getnewMessage(message: message)
                break
            default:
                break
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNewMessage()
    }
    
//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        print(item.selectedImage?.cgImage)
//        if item.selectedImage?.cgImage == UIImage(named: "call")?.cgImage {
//            let callVC = CallViewController.instantiate(fromAppStoryboard: .main)
//            callVC.getnewMessage()
//        }
//    }
    
//    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        self.tabBarController = segue.destination as? UITabBarController
//
//        if let vc = self.tabBarController?.viewControllers?[0] as? RequestTabBarController {
//            vc.doWhatEver(niceObject)
//        }
//    }(<UIImage:0x6000022fc7e0 named(main: call) {30, 30}>)
    //MARK: Helper methods
    
    
    

    func verifyToken() {
        viewModel.verifyToken(token: (SharedConfigs.shared.signedUser?.token)!) { (responseObject, error, code) in
            if (error != nil) {
                if code == 401 {
                     let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                           let nav = UINavigationController(rootViewController: vc)
                           let window: UIWindow? = UIApplication.shared.windows[0]
                           window?.rootViewController = nav
                           window?.makeKeyAndVisible()
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else if responseObject != nil && responseObject!.tokenExists == false {
                DispatchQueue.main.async {
                    let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                    vc.modalPresentationStyle = .fullScreen
                    let nav = UINavigationController(rootViewController: vc)
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let sceneDelegate = windowScene.delegate as? SceneDelegate
                        else {
                            return
                    }
                    sceneDelegate.window?.rootViewController = nav
                }
            }
            else if responseObject != nil && ((responseObject?.tokenExists) == true) {
              
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
   
}
