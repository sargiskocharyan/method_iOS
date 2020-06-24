//
//  ViewController-Extension.swift
//  Articles
//
//  Created by Employee1 on 5/19/20.
//  Copyright © 2020 employee. All rights reserved.
//

import UIKit
import UserNotifications

enum AppStoryboard: String {
    case main = "Main"
}


extension UIViewController {
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    func scheduleNotification(center: UNUserNotificationCenter, message: Message) {
        print("scheduleNotification")
        let content = UNMutableNotificationContent()
        content.title = "You have a new message"
        content.body = message.text
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
    
    func topMostViewController() -> UIViewController {
         if self.presentedViewController == nil {
             return self
         }
         if let navigation = self.presentedViewController as? UINavigationController {
            return (navigation.visibleViewController?.topMostViewController())!
         }
         if let tab = self.presentedViewController as? UITabBarController {
             if let selectedTab = tab.selectedViewController {
                 return selectedTab.topMostViewController()
             }
             return tab.topMostViewController()
         }
         return self.presentedViewController!.topMostViewController()
     }
    
}

extension AppStoryboard {
    
    var instance : UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
    
    func viewController<T : UIViewController>(viewControllerClass : T.Type, function : String = #function, line : Int = #line, file : String = #file) -> T {
        
        let storyboardID = (viewControllerClass as UIViewController.Type).storyboardID
        
        guard let scene = instance.instantiateViewController(withIdentifier: storyboardID) as? T else {
            
            fatalError("ViewController with identifier \(storyboardID), not found in \(self.rawValue) Storyboard.\nFile : \(file) \nLine Number : \(line) \nFunction : \(function)")
        }
        
        return scene
    }
    
    func initialViewController() -> UIViewController? {
        
        return instance.instantiateInitialViewController()
    }
}

extension UIApplication {
    func topMostViewController() -> UIViewController? {
        return self.keyWindow?.rootViewController?.topMostViewController()
    }
}
