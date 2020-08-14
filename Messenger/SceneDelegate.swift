//
//  SceneDelegate.swift
//  Messenger
//
//  Created by Employee1 on 5/21/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
//fileprivate let defaultSignalingServerUrl = URL(string: "wss://192.168.0.105:8080")!
//
//// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
//fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
//                                     "stun:stun1.l.google.com:19302",
//                                     "stun:stun2.l.google.com:19302",
//                                     "stun:stun3.l.google.com:19302",
//                                     "stun:stun4.l.google.com:19302"]
//
//struct Config {
//    let signalingServerUrl: URL
//    let webRTCIceServers: [String]
//    
//    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
//}
class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        self.window = UIWindow(windowScene: windowScene)
        defineMode()
        defineStartController()
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
         
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
      if SocketTaskManager.shared.socket.status == .notConnected || SocketTaskManager.shared.socket.status == .disconnected {
                 SocketTaskManager.shared.connect()
             }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        SocketTaskManager.shared.disconnect()
    }
    
    
    
    func defineStartController() {
        UserDataController().loadUserInfo()
        if SharedConfigs.shared.signedUser == nil {
            AuthRouter().assemblyModule()
        } else {
            MainRouter().assemblyModule()
        }
        self.window?.makeKeyAndVisible()
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

