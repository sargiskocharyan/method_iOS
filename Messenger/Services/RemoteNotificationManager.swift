//
//  RemoteNotificationManager.swift
//  Messenger
//
//  Created by Employee1 on 8/11/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
import UserNotifications
import UIKit.UIApplication


class RemoteNotificationManager {
    
    static func registerDeviceToken(pushDevicetoken: String, voipDeviceToken: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().registerDevice(token: pushDevicetoken, voipToken: voipDeviceToken) { (error) in
            if error == nil {
                UserDefaults.standard.set(true, forKey: Keys.IS_REGISTERED)
                UserDefaults.standard.set(pushDevicetoken, forKey: Keys.PUSH_DEVICE_TOKEN)
                UserDefaults.standard.set(voipDeviceToken, forKey: Keys.VOIP_DEVICE_TOKEN)
                UserDefaults.standard.set(UIDevice.current.identifierForVendor!.uuidString, forKey: "deviceUUID")
                SharedConfigs.shared.isRegistered = true
                SharedConfigs.shared.deviceToken = pushDevicetoken
                SharedConfigs.shared.voIPToken = voipDeviceToken
                SharedConfigs.shared.deviceUUID = UIDevice.current.identifierForVendor!.uuidString
            }
            completion(error)
        }
    }
    
    static func checkForRegisteredDeviceToken() -> Bool {
        return SharedConfigs.shared.isRegistered ?? false
    }
    
    static func getDeviceToken(tokenData: Data) -> String {
        let tokenParts = tokenData.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Device Token: \(token)")
        return token
    }
    
    static func didReceiveVoiDeviceToken(token: Data) -> String {
        let tokenParts = token.map { data -> String in
            return String(format: "%02.2hhx", data)
        }
        let token = tokenParts.joined()
        print("Our Token: \(token)")
        return token
    }
    
    static func requestPermissions() {
//        UNUserNotificationCenter.current().delegate = AppDelegate.shared
//        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) {
//            (granted, error) in
//            print("Permission granted: \(granted)")
//            guard granted else { return }
//            DispatchQueue.main.async {
//                UIApplication.shared.registerForRemoteNotifications()
//            }
//        }
    }
}
