//
//  HomePageViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//


import UIKit
import UserNotifications

class HomePageViewController: UITabBarController, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
    //MARK: Properties
    let viewModel = HomePageViewModel()
    let socketTaskManager = SocketTaskManager.shared
    let center = UNUserNotificationCenter.current()
    private weak var tabVc:UITabBarController?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        verifyToken()
        self.socketTaskManager.connect()
        getnewMessage()
        
        print(self.selectedViewController)
        center.delegate = self
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
//    override public func prepare(for segue: UIStoryboardSegue, sender: Any?) {
////        self.tabBarController = segue.destination as? UITabBarController
//
//        if let vc = self.tabBarController?.viewControllers?[0] as? RequestTabBarController {
//            vc.doWhatEver(niceObject)
//        }
//    }
    //MARK: Helper methods
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Late wake up call"
        content.body = "The early bird catches the worm, but the second mouse gets the cheese."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default
     let currentDateTime = Date()
     let userCalendar = Calendar.current
     let requestedComponents: Set<Calendar.Component> = [
         .year,
         .month,
         .day,
         .hour,
         .minute,
         .second
     ]
     let dateTimeComponents = userCalendar.dateComponents(requestedComponents, from: currentDateTime)
     print(dateTimeComponents)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateTimeComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    func getnewMessage() {
    socketTaskManager.getChatMessage(completionHandler: { (message) in
        
            self.scheduleNotification()
        })
    }

    
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
   
}
