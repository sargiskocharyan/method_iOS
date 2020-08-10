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
import CoreData
class MainTabBarController: UITabBarController {
    
    
    //MARK: Properties
    var viewModel: HomePageViewModel?
    var contactsViewModel: ContactsViewModel?
    var recentMessagesViewModel: RecentMessagesViewModel?
    let socketTaskManager = SocketTaskManager.shared
    static let center = UNUserNotificationCenter.current()
    private let config = Config.default
    var webRTCClient: WebRTCClient?
    private var roomName: String?
    var callManager: CallManager!
    var videoVC: VideoViewController?
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
    var startDate: Date?
    var mainRouter: MainRouter?
    var isFirstConnect: Bool?
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        self.saveContacts()
        self.retrieveCoreDataObjects()
        verifyToken()
        socketTaskManager.connect()
        callManager = AppDelegate.shared.callManager
        handleCall()
        handleAnswer()
        handleCallAccepted()
        handleCallSessionEnded()
        handleOffer()
        getCanditantes()
        handleCallEnd()
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
        getNewMessage()
    }
    
    //MARK: Helper methods
    private func buildSignalingClient() -> SignalingClient {
        return SignalingClient()
    }
    
    func handleCallEnd() {
        socketTaskManager.handleCallEnd { (roomName) in
            self.webRTCClient?.peerConnection?.close()
        }
    }
    
    func handleCallSessionEnded() {
        socketTaskManager.handleCallSessionEnded { (roomname) in
            print(roomname)
//            if self.roomName == roomname {
                
//            }
            for call in self.callManager.calls {
                    self.callManager.end(call: call)
                }
                self.callManager.removeAllCalls()
//            }
        }
    }
    
    func handleCall() {
        SocketTaskManager.shared.handleCall { (id) in
            if !self.onCall {
                self.id = id
                self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
                self.webRTCClient?.delegate = self
                AppDelegate.shared.providerDelegate.webrtcClient = self.webRTCClient
                self.videoVC?.webRTCClient = self.webRTCClient
                self.recentMessagesViewModel!.getuserById(id: id) { (user, error) in
                    if (error != nil) {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                        }
                        return
                    } else if user != nil {
                        let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now()) {
                            AppDelegate.shared.displayIncomingCall(
                                id: id, uuid: UUID(), handle: user?.name ?? (user?.username)!, hasVideo: true, roomName: self.roomName ?? "") { _ in
                                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                            }
                        }
                        DispatchQueue.main.async {
                            self.callsVC?.handleCall(id: id, user: user!)
                        }
                    }
                }
            }
        }
    }
    
    func getCanditantes() {
        socketTaskManager.getCanditantes { (data) in
            
        }
    }
    
    func handleCallAccepted() {
        socketTaskManager.handleCallAccepted { (callAccepted, roomName) in
            self.roomName = roomName
            self.videoVC?.handleOffer(roomName: roomName)
            if callAccepted && self.webRTCClient != nil {
                self.webRTCClient!.offer { (sdp) in
                    self.videoVC!.handleAnswer()
                    self.videoVC!.roomName = roomName
                    self.signalClient!.sendOffer(sdp: sdp, roomName: roomName)
                }
            } else if callAccepted == false {
                self.webRTCClient?.peerConnection?.close()
            }
        }
    }
    
    func handleAnswer() {
        socketTaskManager.handleAnswer { (data) in
            self.videoVC?.handleAnswer()
            self.webRTCClient!.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: data["sdp"]!), completion: { (error) in
                print(error?.localizedDescription as Any)
            })
            self.webRTCClient!.answer { (localSdp) in
                self.hasLocalSdp = true
            }
            self.startDate = Date()
            self.callsVC?.activeCall?.time = Date()
        }
    }
    
    func saveContacts() {
        viewModel!.getContacts { (userContacts, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if userContacts != nil {
                DispatchQueue.main.async {
                    self.viewModel!.saveContacts(contacts: userContacts!) { (users, error) in
                        if users != nil {
                            self.contactsViewModel!.contacts = users!
                        }
                    }
                }
            }
        }
    }
    
    func retrieveCoreDataObjects() {
        contactsViewModel!.retrieveData { (contacts) in
            print("Data retrieved!!!")
        }
        contactsViewModel!.retrieveOtherContactData { (contacts) in
            print("Other data retrieved!!!")
        }
    }

    
    func handleOffer() {
        SocketTaskManager.shared.handleOffer { (roomName, offer) in
            self.onCall = true
            self.callsVC?.onCall = true
            self.roomName = roomName
            self.videoVC?.handleOffer(roomName: roomName)
            DispatchQueue.main.async {
                self.mainRouter?.showVideoViewController()
            }
            self.webRTCClient?.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: offer["sdp"]!), completion: { (error) in
            })
            self.webRTCClient?.answer { (localSdp) in
                self.hasLocalSdp = true
                self.signalClient!.sendAnswer(roomName: roomName, sdp: localSdp)
            }
        }
    }
    
    func getNewMessage() {
        socketTaskManager.getChatMessage { (callHistory, message, name, lastname, username) in
            let chatsNC = self.viewControllers![1] as! UINavigationController
            let chatsVC = chatsNC.viewControllers[0] as! RecentMessagesViewController                          
            if chatsVC.isLoaded {
                chatsVC.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
            }
            if callHistory != nil {
                self.callsVC?.showEndedCall(callHistory!)
            }
            switch self.selectedIndex {
            case 0:
                 let callNc = self.viewControllers![0] as! UINavigationController
                 if callNc.viewControllers.count <= 2 {
                    self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
                 } else {
                    if let chatVC = callNc.viewControllers[2] as? ChatViewController {
                        chatVC.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
                    }
                 }
                break
            case 2:
                let profileNC = self.viewControllers![2] as! UINavigationController
                if profileNC.viewControllers.count < 4 {
                    self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
                } else if profileNC.viewControllers.count == 4 {
                    let chatVC = profileNC.viewControllers[3] as! ChatViewController
                    chatVC.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
                }
            default:
               break
            }
        }
    }
    
    func sessionExpires() {
        self.socketTaskManager.disconnect()
        UserDataController().logOutUser()
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "error_message".localized(), message: "your_session_expires_please_log_in_again".localized(), preferredStyle: .alert)
             alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action: UIAlertAction!) in
                AuthRouter().assemblyModule()
            }))
             self.present(alert, animated: true)
        }
    }
    
    func verifyToken() {
        viewModel!.verifyToken(token: (SharedConfigs.shared.signedUser?.token)!) { (responseObject, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if responseObject != nil && responseObject!.tokenExists == false {
                self.sessionExpires()
            } else if responseObject != nil && responseObject!.tokenExists {
                let userCalendar = Calendar.current
                let requestedComponent: Set<Calendar.Component> = [ .month, .day, .hour, .minute, .second]
                let timeDifference = userCalendar.dateComponents(requestedComponent, from: Date(), to: (SharedConfigs.shared.signedUser?.tokenExpire)!)
                if timeDifference.day! <= 1 {
                    self.profileViewModel.logout { (error) in
                        self.sessionExpires()
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
        self.localCandidateCount += 1
        self.signalClient!.send(candidate: candidate, roomName: self.roomName ?? "")
    }
    
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
        if state == .disconnected {
            DispatchQueue.main.async {
                self.videoVC?.startCall("reconnecting".localized())
            }
        }
        else if state == .connected {
            if isFirstConnect == nil {
                isFirstConnect = true
                socketTaskManager.callStarted(roomname: roomName!)
            } else {
                socketTaskManager.callReconnected(roomname: roomName!)
            }
            videoVC?.handleAnswer()
            startDate = Date()
        }
        else if state == .closed || state == .failed {
            if state == .failed {
                socketTaskManager.leaveRoom(roomName: roomName!)
            }
            videoVC?.handleAnswer()
            onCall = false
            callsVC?.onCall = false
            self.webRTCClient = nil
            videoVC?.webRTCClient = nil
            id = nil
            videoVC?.closeAll()
            DispatchQueue.main.async {
//                self.callsVC?.saveCall(startDate: self.startDate)
                self.callsVC?.view.viewWithTag(20)?.removeFromSuperview()
                self.startDate = nil
            }
        }
    }
}

extension  MainTabBarController: SignalClientDelegate {
    func signalClientDidConnect(_ signalClient: SignalingClient) {
        self.signalingConnected = true
    }
    
    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
        self.signalingConnected = false
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
        self.webRTCClient?.set(remoteSdp: sdp) { (error) in
            print(error?.localizedDescription as Any)
            self.hasRemoteSdp = true
        }
    }
    
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
        self.remoteCandidateCount += 1
        self.webRTCClient!.set(remoteCandidate: candidate)
    }
}

extension MainTabBarController: CallListViewDelegate {
    func handleClickOnSamePerson() {
        mainRouter?.showVideoViewController()
    }
    
    func handleCallClick(id: String, name: String) {
        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        SocketTaskManager.shared.call(id: id) { (roomname) in
            self.roomName = roomname
            self.videoVC?.handleOffer(roomName: roomname)
        }
        callManager.startCall(handle: name, videoEnabled: true)
        webRTCClient?.delegate = self
        
        self.videoVC?.webRTCClient = self.webRTCClient
        self.onCall = true
        self.callsVC?.onCall = true
        videoVC?.startCall("calling".localized() + " \(name)...")
        mainRouter?.showVideoViewController()
    }
}
