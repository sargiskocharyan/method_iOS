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

fileprivate let defaultSignalingServerUrl = URL(string: "wss://192.168.0.105:8080")!

// We use Google's public stun servers. For production apps you should deploy your own stun/turn servers.
fileprivate let defaultIceServers = ["stun:stun.l.google.com:19302",
                                     "stun:stun1.l.google.com:19302",
                                     "stun:stun2.l.google.com:19302",
                                     "stun:stun3.l.google.com:19302",
                                     "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}

class CallViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    var callManager: CallManager!
    var signalClient: SignalingClient?
    var webRTCClient: WebRTCClient?
    private let config = Config.default
    private var signalingConnected: Bool = false
    private var hasRemoteSdp: Bool = false
    private var remoteCandidateCount: Int = 0
    private var localCandidateCount: Int = 0
    private var hasLocalSdp: Bool = false
    private var roomName: String?
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBarController.center.delegate = self
        callManager = AppDelegate.shared.callManager
        tableView.delegate = self
        tableView.dataSource = self
        SocketTaskManager.shared.callAccepted { (callAccepted, roomName) in
            print("callAccepted")
            print(callAccepted, roomName)
            self.roomName = roomName
            if callAccepted {
                self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
                self.signalClient = self.buildSignalingClient()
                self.webRTCClient?.delegate = self
                self.signalClient?.delegate = self
                self.webRTCClient?.offer { (sdp) in
                    print(sdp)
                    self.signalClient!.sendOffer(sdp: sdp, roomName: roomName)
                }
            }
        }
        
        SocketTaskManager.shared.answer { (data) in
            self.webRTCClient?.answer { (localSdp) in
                self.hasLocalSdp = true
                self.signalClient!.sendOffer(sdp: localSdp, roomName: self.roomName ?? "")
            }
        }
        
        SocketTaskManager.shared.getCanditantes { (data) in
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
        let vc = VideoViewController.instantiate(fromAppStoryboard: .main)
        vc.webRTCClient = webRTCClient
        self.navigationController?.present(vc, animated: true, completion: nil)
        
//        self.webRTCClient!.offer { (sdp) in
//            print(sdp)
//            self.signalClient!.send(sdp: sdp)
////            self.webRTCClient!.sendData(Data(base64Encoded: "mi string", options: .ignoreUnknownCharacters)!)
//        }
    }
    
    private func buildSignalingClient() -> SignalingClient {
                  return SignalingClient()
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

extension  CallViewController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        print("signalClientDidDisconnect")
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        print("Received remote sdp")
        self.webRTCClient?.set(remoteSdp: sdp) { (error) in
            self.hasRemoteSdp = true
        }
    }//nayel!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
        self.remoteCandidateCount += 1
        self.webRTCClient?.set(remoteCandidate: candidate)
    }
}

extension CallViewController: WebRTCClientDelegate {
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
        DispatchQueue.main.async {
            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
        print("discovered local candidate")
        self.localCandidateCount += 1
        self.signalClient!.send(candidate: candidate, roomName: self.roomName ?? "")
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        let textColor: UIColor
        switch state {
        case .connected, .completed:
            textColor = .green
        case .disconnected:
            textColor = .orange
        case .failed, .closed:
            textColor = .red
        case .new, .checking, .count:
            textColor = .black
        @unknown default:
            textColor = .black
        }
    }
}
