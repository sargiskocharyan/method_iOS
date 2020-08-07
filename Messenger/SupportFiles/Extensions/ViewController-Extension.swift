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
    case auth = "Auth"
}


extension UIViewController {
    
    func showErrorAlert(title: String, errorMessage: String) {
           let alert = UIAlertController(title: "error_message".localized(), message: errorMessage, preferredStyle: .alert)
           alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
           self.present(alert, animated: true)
       }
    
    class var storyboardID : String {
        return "\(self)"
    }
    
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        
        return appStoryboard.viewController(viewControllerClass: self)
    }
    
    func scheduleNotification(center: UNUserNotificationCenter, _ callHistory: CallHistory?, message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
        let content = UNMutableNotificationContent()
        if lastname != nil && name != nil {
            content.title = "\(name!) \(lastname!)"
        } else if username != nil {
            content.title = username!
        } else {
            content.title = "New message"
        }
        content.body = message.text ?? ""
        content.sound = UNNotificationSound.defaultCritical
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
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateTimeComponents, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        center.add(request) { (error) in
            if let error = error {
                print("Notification Error: ", error)
            }
        }
    }
    
        func hideKeyboardWhenTappedAround() {
            let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
            tap.cancelsTouchesInView = false
            view.addGestureRecognizer(tap)
        }
        
        @objc func dismissKeyboard() {
            view.endEditing(true)
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

