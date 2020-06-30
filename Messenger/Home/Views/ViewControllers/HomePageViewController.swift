//
//  HomePageViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//


import UIKit
import UserNotifications
import AVFoundation
class MainTabBarController: UITabBarController, UNUserNotificationCenterDelegate {
    
    
    //MARK: Properties
    let viewModel = HomePageViewModel()
    let socketTaskManager = SocketTaskManager.shared
    static let center = UNUserNotificationCenter.current()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        verifyToken()
        socketTaskManager.connect()
        Self.center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
        
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                //access granted
            } else {

            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getNewMessage()
    }
    
    //MARK: Helper methods
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    
    func getNewMessage() {
        socketTaskManager.getChatMessage { (message) in
            let chatsNC = self.viewControllers![3] as! UINavigationController
            let chatsVC = chatsNC.viewControllers[0] as! RecentMessagesViewController                          
            if chatsVC.isLoaded {
                chatsVC.getnewMessage(message: message)
            } 
            switch self.selectedIndex {
            case 0, 1, 2:
                self.selectedViewController?.scheduleNotification(center: Self.center, message: message)
                break
            case 4:
                let profileNC = self.viewControllers![4] as! UINavigationController
                if profileNC.viewControllers.count < 3 {
                    self.selectedViewController?.scheduleNotification(center: Self.center, message: message)
                } else if profileNC.viewControllers.count == 3 {
                    let chatVC = profileNC.viewControllers[2] as! ChatViewController
                    chatVC.getnewMessage(message: message)
                }
            default:
                break
            }
        }
    }
    
    func verifyToken() {
        viewModel.verifyToken(token: (SharedConfigs.shared.signedUser?.token)!) { (responseObject, error) in
            if (error != nil) {
                if error == NetworkResponse.authenticationError {
                    let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                    let nav = UINavigationController(rootViewController: vc)
                    let window: UIWindow? = UIApplication.shared.windows[0]
                    window?.rootViewController = nav
                    window?.makeKeyAndVisible()
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error!.rawValue, preferredStyle: .alert)
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
        }
    }
}
