//
//  CallViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import CallKit
import AVFoundation
import WebRTC

class CallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var callManager: CallManager!
    var signalClient: SignalingClient?
    var webRTCClient: WebRTCClient?
    @IBOutlet weak var tableView: UITableView!
    
    
//    init() {
//        self.signalClient = signalClient
//        self.webRTCClient = webRTCClient
////        super.init(nibName: String(describing: MainViewController.self), bundle: Bundle.main)
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBarController.center.delegate = self
        callManager = AppDelegate.shared.callManager
        tableView.delegate = self
        tableView.dataSource = self
        SocketTaskManager.shared.callAccepted { (callAccepted, roomName) in
            print("callAccepted")
            print(callAccepted, roomName)
            if callAccepted {
                self.webRTCClient!.offer { (sdp) in
                    print(sdp)
                    self.signalClient!.sendOffer(sdp: sdp, roomName: roomName)
                }
            }
        }
        SocketTaskManager.shared.answer { (data) in
            print(data)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell
        cell.nameLabel.text = "jhcbdh"
        cell.userImageView.image = UIImage(named: "noPhoto")
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        callManager.startCall(handle: "123", videoEnabled: true)
        SocketTaskManager.shared.call(id: "5f05baa520d4310017ebc9bd")
        
//        self.webRTCClient!.offer { (sdp) in
//            print(sdp)
//            self.signalClient!.send(sdp: sdp)
////            self.webRTCClient!.sendData(Data(base64Encoded: "mi string", options: .ignoreUnknownCharacters)!)
//        }
    }
}

extension CallViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
          completionHandler()
      }
      
      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          completionHandler([.alert, .badge, .sound])
      }
}
