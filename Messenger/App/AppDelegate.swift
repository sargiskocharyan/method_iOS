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


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var providerDelegate: ProviderDelegate!
    let callManager = CallManager()
    
    class var shared: AppDelegate {
       return UIApplication.shared.delegate as! AppDelegate
     }
    
//    private func buildMainViewController() -> UIViewController {
//
//           let webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
//           let signalClient = self.buildSignalingClient()
//           let mainViewController = MainViewController(signalClient: signalClient, webRTCClient: webRTCClient)
//           let navViewController = UINavigationController(rootViewController: mainViewController)
//           if #available(iOS 11.0, *) {
//               navViewController.navigationBar.prefersLargeTitles = true
//           }
//           else {
//               navViewController.navigationBar.isTranslucent = false
//           }
//           return navViewController
//       }
       
      
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DropDown.startListeningToKeyboard()
        FirebaseApp.configure()
        providerDelegate = ProviderDelegate(callManager: callManager)

        return true
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
    
    func displayIncomingCall(
        id: String,
      uuid: UUID,
      handle: String,
      hasVideo: Bool = false,
      completion: ((Error?) -> Void)?
    ) {
      providerDelegate.reportIncomingCall(
        id: id, uuid: uuid,
        handle: handle,
        hasVideo: hasVideo,
        completion: completion)
    }
}


