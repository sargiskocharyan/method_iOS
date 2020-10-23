//
//  MainTabBarController.swift
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
    var timer: Timer?
    var mode: VideoVCMode?
    var nc = NotificationCenter.default
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBar.items?[2].image = UIImage(named: "channelIcon")?.withRenderingMode(.automatic)
        ((self.tabBar.items?[2].value(forKey: "view") as? UIView)?.subviews[0] as? UIImageView)?.frame = CGRect(x: 0, y: 0, width: 20, height: 10)
        ((self.tabBar.items?[2].value(forKey: "view") as? UIView)?.subviews[0] as? UIImageView)?.clipsToBounds = true
        ((self.tabBar.items?[2].value(forKey: "view") as? UIView)?.subviews[0] as? UIImageView)?.contentMode = .scaleAspectFit
        self.navigationController?.isNavigationBarHidden = true
        self.saveContacts()
        self.retrieveCoreDataObjects()
        verifyToken()
        getRequests()
        getAdminMessages()
        SocketTaskManager.shared.connect(completionHandler: {
            print("home page connect")
        })
        callManager = AppDelegate.shared.callManager
        AppDelegate.shared.delegate = self
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
    
    //MARK: Helper methods
    private func buildSignalingClient() -> SignalingClient {
        return SignalingClient()
    }
    
    func handleCallEnd() {
        SocketTaskManager.shared.addCallEndListener { (roomName) in
            self.webRTCClient?.peerConnection?.close()
        }
    }
    
    func handleCallSessionEnded() {
        SocketTaskManager.shared.addCallSessionEndedListener { (roomname) in
            for call in self.callManager.calls {
                self.callManager.end(call: call)
            }
            self.callManager.removeAllCalls()
        }
    }
    
    func handleChannelSubscriberUpdate() {
        SocketTaskManager.shared.addChannelSubscriberInfo { (user, name, avatarUrl) in
            self.mainRouter?.channelListViewController?.handleSubscriberUpdate(user: user, name: name, avatarUrl: avatarUrl)
        }
    }
    
    func handleChannelMessageEdit() {
        SocketTaskManager.shared.addEditChannelMessageListener { (message) in
            if self.selectedIndex == 2 {
                let channelNC = self.selectedViewController as? UINavigationController
                if channelNC?.viewControllers.count ?? 0 >= 2 {
                    self.mainRouter?.channelMessagesViewController?.handleMessageEdited(message: message)
                }
            }
        }
    }
    
    func handleChatMessageEdit() {
        SocketTaskManager.shared.addEditChatMessageListener { (message) in
            self.mainRouter?.chatViewController?.handleMessageEdited(message: message)
            if self.mainRouter?.recentMessagesViewController?.isLoadedMessages == true {
                let chatId = message.senderId == SharedConfigs.shared.signedUser?.id ? message.reciever : message.senderId
                self.mainRouter?.recentMessagesViewController?.handleMessageEdited(chatId: chatId ?? "", message: message)
            }
        }
    }
    
    func handleChannelMessageDelete() {
        SocketTaskManager.shared.addDeleteChannelMessageListener(completion: { (messages) in
            if self.selectedIndex == 2 {
                let channelNC = self.selectedViewController as? UINavigationController
                if channelNC?.viewControllers.count ?? 0 >= 2 {
                    self.mainRouter?.channelMessagesViewController?.handleChannelMessageDeleted(messages: messages)
                }
            }
        })
    }
    
    func handleChatMessageDelete() {
        SocketTaskManager.shared.addDeleteChatMessageListener { (messages) in
            if self.mainRouter?.recentMessagesViewController != nil && self.mainRouter!.recentMessagesViewController!.isLoaded {
                self.mainRouter?.recentMessagesViewController?.handleMessageDelete(messages: messages)
                self.mainRouter?.chatViewController?.handleDeleteMessage(messages: messages)
            }
        }
    }
    
    func startCall(_ id: String, _ roomname: String, _ name: String, _ type: String, completionHandler: @escaping () -> ()) {
        self.id = id
        self.roomName = roomname
        self.mode = type == "video" ? VideoVCMode.videoCall : VideoVCMode.audioCall
        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        self.webRTCClient?.delegate = self
        AppDelegate.shared.providerDelegate.webrtcClient = self.webRTCClient
        self.videoVC?.webRTCClient = self.webRTCClient
        self.callsVC?.handleCall(id: id)
        videoVC?.isCallHandled = true
        completionHandler()
        return
    }
    
    func getAdminMessages() {
        contactsViewModel?.getAdminMessages(completion: { (adminMessages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if adminMessages != nil && adminMessages!.count > 0 {
                SharedConfigs.shared.adminMessages = adminMessages!
            }
        })
    }
    
    func handleCall() {
        videoVC?.isCallHandled = true
        SocketTaskManager.shared.addCallListener { (id, roomname, name, type) in
            if !self.onCall {
                self.startCall(id, roomname, name, type) {
                    self.mode = type == "video" ? VideoVCMode.videoCall : VideoVCMode.audioCall
                    DispatchQueue.main.async {
                        AppDelegate.shared.displayIncomingCall(id: id, uuid: UUID(), handle: name, hasVideo: true, roomName: roomname) { error in
                            print("error \(error?.localizedDescription ?? "nil")")
                        }
                    }
                }
            }
        }
    }
    
    func handleNewContactRequest() {
        SocketTaskManager.shared.addNewContactRequestListener { (userId) in
            print("new request sent")
        }
    }
    
    func handleNewContact() {
        SocketTaskManager.shared.addNewContactListener { (userId) in
            print("new contact added")
            self.recentMessagesViewModel?.getuserById(id: userId, completion: { (user, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    }
                } else if user != nil {
                    DispatchQueue.main.async {
                        self.contactsViewModel?.addContactToCoreData(newContact: user!, completion: { (error) in
                            print(error?.localizedDescription as Any)
                        })
                    }
                }
            })
        }
    }
    
    func handleContactRequestRejected() {
        SocketTaskManager.shared.addContactRequestRejectedListener { (userId) in
            print("new request rejected")
        }
    }
    
    func handleContactRemoved() {
        SocketTaskManager.shared.addContactRemovedListener(completionHandler: { (userId) in
            print("The user delete us from contacts...")
            self.contactsViewModel?.removeContactFromCoreData(id: userId, completion: { (error) in
                if error != nil {
                    print(error?.localizedDescription as Any)
                } else {
                    print("removed")
                }
            })
        })
    }
    
    func getCandidates() {
        SocketTaskManager.shared.addCandidatesListener { (data) in
        }
    }
    
    func handleReadMessage()  {
        SocketTaskManager.shared.addMessageReadListener { (createdAt, userId) in
            self.mainRouter?.chatViewController?.handleMessageReadFromTabbar(createdAt: createdAt, userId: userId)
        }
    }
    
    func handleReceiveMessage()  {
        SocketTaskManager.shared.addMessageReceivedListener { (createdAt, userId) in
            self.mainRouter?.chatViewController?.handleMessageReceiveFromTabbar(createdAt: createdAt, userId: userId)
        }
    }
    
    func handleMessageTyping()  {
        SocketTaskManager.shared.addMessageTypingListener { (userId) in
            self.mainRouter?.chatViewController?.handleMessageTypingFromTabbar(userId: userId)
        }
    }
    
    func handleCallAccepted() {
        SocketTaskManager.shared.addCallAcceptedLister { (callAccepted, roomName) in
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
            self.timer?.invalidate()
        }
    }
    
    func handleAnswer() {
        SocketTaskManager.shared.addAnswerListener { (data) in
            self.videoVC?.handleAnswer()
            self.webRTCClient!.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: data["sdp"]!), completion: { (error) in })
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
        contactsViewModel!.retrieveData { (contacts) in }
        contactsViewModel!.retrieveOtherContactData { (contacts) in }
    }
    
    func handleOffer() {
        videoVC?.isCallHandled = true
        SocketTaskManager.shared.addOfferListener { (roomName, offer) in
            self.onCall = true
            self.callsVC?.onCall = true
            self.roomName = roomName
            self.videoVC?.handleOffer(roomName: roomName)
            DispatchQueue.main.async {
                self.mainRouter?.showVideoViewController(mode: self.mode!)
                self.webRTCClient?.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: offer["sdp"]!), completion: { (error) in
                })
                self.webRTCClient?.answer { (localSdp) in
                    self.hasLocalSdp = true
                    self.signalClient!.sendAnswer(roomName: roomName, sdp: localSdp)
                }
            }
            
        }
    }
    
    func getRequests() {
        contactsViewModel?.getRequests(completion: { (requests, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if requests != nil {
                SharedConfigs.shared.contactRequests = requests!
            }
        })
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<SharedConfigs.shared.unreadMessages.count {
            for j in i..<SharedConfigs.shared.unreadMessages.count {
                guard SharedConfigs.shared.unreadMessages[i].message != nil, SharedConfigs.shared.unreadMessages[j].message != nil else {
                    break
                }
                let firstDate = formatter.date(from: SharedConfigs.shared.unreadMessages[i].message!.createdAt ?? "")
                let secondDate = formatter.date(from: SharedConfigs.shared.unreadMessages[j].message!.createdAt ?? "")
                if firstDate?.compare(secondDate!).rawValue == -1 {
                    let temp = SharedConfigs.shared.unreadMessages[i]
                    SharedConfigs.shared.unreadMessages[i] = SharedConfigs.shared.unreadMessages[j]
                    SharedConfigs.shared.unreadMessages[j] = temp
                }
            }
        }
    }
    
    func getnewMessage(callHistory: CallHistory?, message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
        mainRouter?.callListViewController?.viewModel!.getuserById(id: message.senderId!) { (user, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if user != nil {
                for i in 0..<SharedConfigs.shared.unreadMessages.count {
                    var isUnreadMessage = false
                    if SharedConfigs.shared.unreadMessages[i].id == message.senderId! {
                        if callHistory != nil {
                            isUnreadMessage = SharedConfigs.shared.unreadMessages[i].unreadMessageExists
                        } else {
                            isUnreadMessage = true
                        }
                        SharedConfigs.shared.unreadMessages[i] = Chat(id: message.senderId!, name: user!.name, lastname: user!.lastname, username: user!.username, message: message, recipientAvatarURL: user!.avatarURL, online: true, statuses: nil, unreadMessageExists: isUnreadMessage)
                        self.sort()
                        if self.mainRouter?.notificationDetailViewController?.type == CellType.message {
                            DispatchQueue.main.async {
                                self.mainRouter?.notificationDetailViewController?.tableView?.reloadData()
                            }
                        }
                        return
                    }
                }
                if callHistory == nil && message.senderId != SharedConfigs.shared.signedUser?.id {
                    SharedConfigs.shared.unreadMessages.append(Chat(id: message.senderId!, name: user!.name, lastname: user!.lastname, username: user!.username, message: message, recipientAvatarURL: user?.avatarURL, online: true, statuses: nil, unreadMessageExists: !(callHistory != nil)))
                    self.sort()
                }
                if self.mainRouter?.notificationDetailViewController?.type == CellType.message {
                    DispatchQueue.main.async {
                        self.mainRouter?.notificationDetailViewController?.tableView?.reloadData()
                    }
                }
            }
        }
    }
    
    func getNewChannelMessage() {
        SocketTaskManager.shared.getChannelMessage { (message, name, lastname, username) in
            let channelMessageNC = self.viewControllers?[2] as? UINavigationController
            switch self.selectedIndex {
            case 2:
                if (channelMessageNC?.viewControllers.count)! == 1 {
                    if message.senderId != SharedConfigs.shared.signedUser?.id {
                        self.selectedViewController?.scheduleNotification(center: Self.center, nil, message: message, name, lastname, username)
                    }
                } else if (channelMessageNC?.viewControllers.count)! == 2 {
                    let channelMessageVC = channelMessageNC?.viewControllers[1] as? ChannelMessagesViewController
                    if message.owner != channelMessageVC?.channelInfo.channel?._id {
                        self.selectedViewController?.scheduleNotification(center: Self.center, nil, message: message, name, lastname, username)
                    }
                    channelMessageVC?.getnewMessage(message: message, name, lastname, username, isSenderMe: false)
                } else {
                    if message.senderId != SharedConfigs.shared.signedUser?.id {
                        self.selectedViewController?.scheduleNotification(center: Self.center, nil, message: message, name, lastname, username)
                    }
                    let channelMessageVC = channelMessageNC?.viewControllers[1] as? ChannelMessagesViewController
                    channelMessageVC?.getnewMessage(message: message, name, lastname, username, isSenderMe: false)
                }
            default:
                self.selectedViewController?.scheduleNotification(center: Self.center, nil, message: message, name, lastname, username)
            }
        }
    }
    
    func onCallNC(_ callHistory: CallHistory?, _ message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
        let callNc = self.viewControllers![0] as! UINavigationController
        if callNc.viewControllers.count == 1 {
            if callHistory == nil {
                self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
            }
        }
        else if callNc.viewControllers.count == 2 {
            if callHistory == nil && message.senderId != SharedConfigs.shared.signedUser?.id && callHistory?.status == CallStatus.missed.rawValue {
                self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
            } else if callHistory != nil && callHistory?.caller != SharedConfigs.shared.signedUser?.id && callHistory?.status == CallStatus.missed.rawValue {
                self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
            }
        } else {
            if let chatVC = callNc.viewControllers[2] as? ChatViewController {
                chatVC.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
            } else if let videoVC = callNc.viewControllers[2] as? VideoViewController {
                videoVC.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
            }
        }
    }
    
    func onChatNC(_ callHistory: CallHistory?, _ message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
        let recentNc = self.viewControllers![1] as! UINavigationController
        if callHistory != nil && callHistory?.caller != SharedConfigs.shared.signedUser?.id {
            if recentNc.viewControllers.count == 2  {
                let chatVC = recentNc.viewControllers[1] as? ChatViewController
                if chatVC == nil && callHistory?.status == CallStatus.missed.rawValue  {
                    self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
                } else {
                    chatVC?.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
                }
            } else if callHistory?.status == CallStatus.missed.rawValue {
                self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
            }
        } else if callHistory == nil && recentNc.viewControllers.count == 2 && message.senderId != SharedConfigs.shared.signedUser?.id {
            let contactsVC = recentNc.viewControllers[1] as? ContactsViewController
            if contactsVC != nil {
                self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
            }
        } else if recentNc.viewControllers.count > 2 {
            if let _ = recentNc.viewControllers[2] as? ContactProfileViewController {
                if callHistory?.status == CallStatus.missed.rawValue && callHistory?.caller != SharedConfigs.shared.signedUser?.id {
                    self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
                }
                let chatVC = recentNc.viewControllers[1] as? ChatViewController
                chatVC?.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
            } else if recentNc.viewControllers.count == 4, let _ = recentNc.viewControllers[3] as? ContactProfileViewController {
                if (message.senderId != SharedConfigs.shared.signedUser?.id && callHistory == nil) || (callHistory != nil && callHistory?.caller != SharedConfigs.shared.signedUser?.id && callHistory?.status == CallStatus.missed.rawValue) {
                    self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
                }
            }
        }
    }
    
    func onChannelNC(_ callHistory: CallHistory?, _ message: Message, _ name: String?, _ lastname: String?, _ username: String?) {
        let channelNC = self.viewControllers![2] as! UINavigationController
        if channelNC.viewControllers.count >= 6 {
            if let chatVC = channelNC.viewControllers[5] as? ChatViewController  {
                chatVC.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
            }
        }
    }
    
    func onProfileNC(_ message: Message, _ callHistory: CallHistory?, _ name: String?, _ lastname: String?, _ username: String?) {
        let profileNC = self.viewControllers![3] as! UINavigationController
        if profileNC.viewControllers.count < 4 {
            if (message.senderId != SharedConfigs.shared.signedUser?.id && callHistory == nil) || (callHistory != nil && callHistory?.caller != SharedConfigs.shared.signedUser?.id && callHistory?.status == CallStatus.missed.rawValue) {
                self.selectedViewController?.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
            }
        } else if profileNC.viewControllers.count == 4 {
            let chatVC = profileNC.viewControllers[3] as? ChatViewController
            if chatVC != nil {
                chatVC!.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
            } else {
                let videoVC = profileNC.viewControllers[3] as? VideoViewController
                if videoVC != nil {
                    videoVC!.scheduleNotification(center: Self.center, callHistory, message: message, name, lastname, username)
                }
            }
        }
    }
    
    func getNewMessage() {
        SocketTaskManager.shared.getChatMessage { [self] (callHistory, message, name, lastname, username) in
            let chatsNC = self.viewControllers![1] as! UINavigationController
            let chatsVC = chatsNC.viewControllers[0] as! RecentMessagesViewController
            if callHistory != nil && callHistory?.status == CallStatus.missed.rawValue && callHistory?.receiver == SharedConfigs.shared.signedUser?.id {
                SharedConfigs.shared.missedCalls.append(callHistory!._id!)
                self.mainRouter?.notificationListViewController?.reloadData()
            }
            if chatsVC.isLoaded {
                chatsVC.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
            }
            self.getnewMessage(callHistory: callHistory, message: message, name, lastname, username)
            if callHistory != nil  {
                self.callsVC?.showEndedCall(callHistory!)
            }
            switch self.selectedIndex {
            case 0:
                self.onCallNC(callHistory, message, name, lastname, username)
                break
            case 1:
                self.onChatNC(callHistory, message, name, lastname, username)
                break
            case 2:
                self.onChannelNC(callHistory, message, name, lastname, username)
            case 3:
                self.onProfileNC(message, callHistory, name, lastname, username)
            default:
                break
            }
        }
    }
    
    func sessionExpires() {
        SocketTaskManager.shared.disconnect{}
        DispatchQueue.main.async {
            UserDataController().logOutUser()
            let alert = UIAlertController(title: "error_message".localized(), message: "your_session_expires_please_log_in_again".localized(), preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: { (action: UIAlertAction!) in
                AuthRouter().assemblyModule()
            }))
            self.present(alert, animated: true)
        }
    }
    
    func checkOurInfo(completion: @escaping ()->()) {
        recentMessagesViewModel?.getuserById(id: SharedConfigs.shared.signedUser!.id, completion: { (user, error) in
            if error == nil && user != nil {
                UserDataController().populateUserProfile(model: UserModel(name: user?.name, lastname: user?.lastname, username: user?.username, email: user?.email, token: SharedConfigs.shared.signedUser?.token, id: SharedConfigs.shared.signedUser!.id, avatarURL: user?.avatarURL, phoneNumber: user?.phoneNumber, birthDate: user?.birthday, gender: user?.gender, info: user?.info, tokenExpire: SharedConfigs.shared.signedUser?.tokenExpire, deactivated: nil, blocked: nil, channels: user?.channels))
                if user?.missedCallHistory != nil {
                    SharedConfigs.shared.missedCalls = user!.missedCallHistory!
                }
                completion()
            }
        })
    }
    
    func checkInfo() {
        self.checkOurInfo(completion: {
            DispatchQueue.main.async {
                let recentNC = self.viewControllers![1] as! UINavigationController
                let recentVC = recentNC.viewControllers[0] as! RecentMessagesViewController
                if SharedConfigs.shared.missedCalls.count > 0 {
                    self.viewModel?.checkCallAsSeen(callId: SharedConfigs.shared.missedCalls[SharedConfigs.shared.missedCalls.count - 1], readOne: false, completion: { (error) in
                        if error == nil {
                            SharedConfigs.shared.missedCalls = []
                            DispatchQueue.main.async {
                                self.mainRouter?.profileViewController?.changeNotificationNumber()
                                if let tabItems = self.tabBar.items {
                                    let tabItem = tabItems[0]
                                    tabItem.badgeValue = nil
                                }
                            }
                        }
                    })
                }
                recentVC.getChats(isFromHome: true)
            }
        })
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
                    self.profileViewModel.logout(deviceUUID: UIDevice.current.identifierForVendor!.uuidString) { (error) in
                        UserDefaults.standard.set(false, forKey: Keys.IS_REGISTERED)
                        self.sessionExpires()
                    }
                } else {
                    self.checkInfo()
                }
            }
        }
    }
}

//MARK: Extensions
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
        let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
        if message == "turn camera off" {
            videoVC?.turnOffOtherSideCamera()
        } else if message == "turn camera on" {
            videoVC?.turnOnOtherSideCamera()
        } else if message == "opponent leave call" {
            DispatchQueue.main.async {
                self.videoVC?.endCall()
            }
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
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
                SocketTaskManager.shared.callStarted(roomname: roomName!)
                videoVC!.handleCallConnect()
            } else {
                SocketTaskManager.shared.callReconnected(roomname: roomName!)
            }
            videoVC?.handleAnswer()
            if isFirstConnect == nil {
                isFirstConnect = true
                DispatchQueue.main.async {
                    self.videoVC?.startCall("connecting".localized())
                }
                startDate = Date()
            }
        }
        else if state == .closed || state == .failed {
            isFirstConnect = nil
            if state == .failed {
                SocketTaskManager.shared.leaveRoom(roomName: roomName!)
            }
            videoVC?.handleAnswer()
            onCall = false
            callsVC?.onCall = false
            self.webRTCClient = nil
            videoVC?.webRTCClient = nil
            id = nil
            videoVC?.closeAll()
            DispatchQueue.main.async {
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
        mainRouter?.showVideoViewController(mode: .audioCall)
    }
    
    func handleCallClick(id: String, name: String, mode: VideoVCMode) {
        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        SocketTaskManager.shared.call(id: id, type: mode.rawValue) { (roomname) in
            self.roomName = roomname
            self.videoVC?.handleOffer(roomName: roomname)
        }
        webRTCClient?.delegate = self
        self.videoVC?.webRTCClient = self.webRTCClient
        self.onCall = true
        self.callsVC?.onCall = true
        self.videoVC?.isCallHandled = false
        mainRouter?.showVideoViewController(mode: mode)
        videoVC?.startCall("calling".localized() + " \(name)...")
        callManager.startCall(handle: name, videoEnabled: true)
        self.timer = Timer.scheduledTimer(withTimeInterval: 200, repeats: false, block: { (timer) in
            if self.isFirstConnect != true {
                self.videoVC?.endCall()
            }
        })
    }
}

extension MainTabBarController: AppDelegateProtocol {
    func startCallD(id: String, roomName: String, name: String, type: String, completionHandler: @escaping () -> ()) {
        self.startCall(id, roomName, name, type) {
            completionHandler()
        }
    }
}
