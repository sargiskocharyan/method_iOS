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
import WebRTC

class MainTabBarController: UITabBarController {
    
    
    //MARK: Properties
    let viewModel = HomePageViewModel()
    let socketTaskManager = SocketTaskManager.shared
    static let center = UNUserNotificationCenter.current()
    private let config = Config.default
    var webRTCClient: WebRTCClient?
    private var roomName: String?
    var callManager: CallManager!
    var recentMessagesViewModel = RecentMessagesViewModel()
    var vc: VideoViewController?
    var onCall: Bool = false
    var id: String?
    var signalClient: SignalingClient?
    private var signalingConnected: Bool = false
    private var hasRemoteSdp: Bool = false
    private var remoteCandidateCount: Int = 0
    private var localCandidateCount: Int = 0
    private var hasLocalSdp: Bool = false
    var callsNC: UINavigationController?
    var callsVC: CallListViewController?
    let profileViewModel = ProfileViewModel()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
//        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
//        self.webRTCClient?.delegate = self
        verifyToken()
        socketTaskManager.connect()
        callManager = AppDelegate.shared.callManager
        handleCall()
        handleAnswer()
        handleCallAccepted()
        handleOffer()
        getCanditantes()
        callsNC = viewControllers![0] as? UINavigationController
        callsVC = callsNC!.viewControllers[0] as? CallListViewController
        callsVC!.delegate = self
        self.signalClient = self.buildSignalingClient()
        self.signalClient?.delegate = self
        Self.center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        vc = VideoViewController.instantiate(fromAppStoryboard: .main)
        vc?.delegate = self
        vc?.webRTCClient = self.webRTCClient
        getNewMessage()
    }
    
    //MARK: Helper methods
    
    private func buildSignalingClient() -> SignalingClient {
           return SignalingClient()
       }
    
    func handleCall() {
        SocketTaskManager.shared.handleCall { (id) in
            self.id = id
            
            self.recentMessagesViewModel.getuserById(id: id) { (user, error) in
                if (error != nil) {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    return
                } else if user != nil {
                    let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now()) {
                        AppDelegate.shared.displayIncomingCall(
                            id: id, uuid: UUID(),
                            handle: user?.name ?? (user?.username)!,
                            hasVideo: true, roomName: self.roomName ?? "") { _ in
                                UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                        }
                    }
                    DispatchQueue.main.async {
                            let chatsNC = self.viewControllers![0] as! UINavigationController
                            let vc = chatsNC.viewControllers[0] as! CallListViewController
                            vc.handleCall(id: id, user: user!)
                    }
                }
            }
        }
    }
    
    func getCanditantes() {
        socketTaskManager.getCanditantes { (data) in
//            print(data)
        }
    }
    
    func handleCallAccepted() {
        socketTaskManager.handleCallAccepted { (callAccepted, roomName) in
            self.roomName = roomName
            self.vc?.handleOffer(roomName: roomName)
            if callAccepted && self.webRTCClient != nil {
                self.webRTCClient!.offer { (sdp) in
                    self.vc!.handleAnswer()
                    self.vc!.roomName = roomName
                    self.signalClient!.sendOffer(sdp: sdp, roomName: roomName)
                }
            }
        }
    }

    func handleAnswer() {
        socketTaskManager.handleAnswer { (data) in
            self.vc?.handleAnswer()
            self.webRTCClient!.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: data["sdp"]!), completion: { (error) in
                print(error?.localizedDescription as Any)
            })
            self.webRTCClient!.answer { (localSdp) in
                self.hasLocalSdp = true
            }
        }
    }

    
    func handleOffer() {
        SocketTaskManager.shared.handleOffer { (roomName, offer) in
            self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
            self.webRTCClient?.delegate = self
            self.vc?.webRTCClient = self.webRTCClient
            self.onCall = true
            self.callsVC?.onCall = true
            self.roomName = roomName
            self.vc?.handleOffer(roomName: roomName)
            DispatchQueue.main.async {
                let selectedNC = self.selectedViewController as? UINavigationController
                selectedNC?.pushViewController(self.vc!, animated: false)
            }
            self.webRTCClient!.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: offer["sdp"]!), completion: { (error) in
            })
            self.webRTCClient!.answer { (localSdp) in
                self.hasLocalSdp = true
                self.signalClient!.sendAnswer(roomName: roomName, sdp: localSdp)
            }
        }
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
                if profileNC.viewControllers.count < 4 {
                    self.selectedViewController?.scheduleNotification(center: Self.center, message: message)
                } else if profileNC.viewControllers.count == 4 {
                    let chatVC = profileNC.viewControllers[3] as! ChatViewController
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
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else if responseObject != nil && responseObject!.tokenExists == false {
                UserDataController().logOutUser()
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: "Your session expires, please log in again", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action: UIAlertAction!) in
                        let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                        vc.modalPresentationStyle = .fullScreen
                        let nav = UINavigationController(rootViewController: vc)
                        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                            let sceneDelegate = windowScene.delegate as? SceneDelegate
                            else {
                                return
                        }
                        sceneDelegate.window?.rootViewController = nav
                    }))
                     self.present(alert, animated: true)
                }
            } else if responseObject != nil && responseObject!.tokenExists {
                let userCalendar = Calendar.current
                let requestedComponent: Set<Calendar.Component> = [ .month, .day, .hour, .minute, .second]
                let timeDifference = userCalendar.dateComponents(requestedComponent, from: Date(), to: (SharedConfigs.shared.signedUser?.tokenExpire)!)
                if timeDifference.day! <= 1 {
                    self.profileViewModel.logout { (error) in
                        self.socketTaskManager.disconnect()
                        UserDataController().logOutUser()
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "error_message".localized(), message: "Your session expires, please log in again", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action: UIAlertAction!) in
                                let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                                let nav = UINavigationController(rootViewController: vc)
                                let window: UIWindow? = UIApplication.shared.windows[0]
                                window?.rootViewController = nav
                                window?.makeKeyAndVisible()
                            }))
                            self.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
}

//MARK: Extension
extension MainTabBarController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
          completionHandler()
      }
      
      func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
          completionHandler([.alert, .badge, .sound])
      }
}

extension UIViewController {
    func pushVideoVC(id: String) {
        
    }
}

extension MainTabBarController: VideoViewControllerProtocol {
    func handleClose() {
////        onCall = false
//        callsVC?.onCall = false
//        self.webRTCClient = nil
////        vc?.webRTCClient = nil
//        id = nil
//        //vc?.roomName = nil
    }
}

extension MainTabBarController: WebRTCClientDelegate {
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
        if state == .closed {
            onCall = false
            callsVC?.onCall = false
            self.webRTCClient = nil
            vc?.webRTCClient = nil
            id = nil
            vc?.closeAll()
        }
        print(state)
        print("did Change Connection State")
    }
}

extension  MainTabBarController: SignalClientDelegate {
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
            print(sdp)
            print(error?.localizedDescription ?? "error chka!!!!!!!!!!!")
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        print("Received remote candidate")
        self.remoteCandidateCount += 1
        self.webRTCClient!.set(remoteCandidate: candidate)
    }
}

extension MainTabBarController: CallListViewDelegate {
    
    func handleClickOnSamePerson() {
        DispatchQueue.main.async {
            let selectedNC = self.selectedViewController as? UINavigationController
            selectedNC?.pushViewController(self.vc!, animated: false)
        }
    }
    
    func handleCallClick(id: String) {
        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        SocketTaskManager.shared.call(id: id)
        callManager.startCall(handle: id, videoEnabled: true)
        webRTCClient?.delegate = self
        self.vc?.webRTCClient = self.webRTCClient
        self.onCall = true
        self.callsVC?.onCall = true
        vc?.startCall()
        DispatchQueue.main.async {
            let selectedNC = self.selectedViewController as? UINavigationController
            selectedNC?.pushViewController(self.vc!, animated: false)
        }
    }
}
