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
import CoreData

let defaultSignalingServerUrl = URL(string: "wss://192.168.0.105:8080")!
let defaultIceServers = ["stun:stun.l.google.com:19302",
                         "stun:stun1.l.google.com:19302",
                         "stun:stun2.l.google.com:19302",
                         "stun:stun3.l.google.com:19302",
                         "stun:stun4.l.google.com:19302"]

struct Config {
    let signalingServerUrl: URL
    let webRTCIceServers: [String]
    
    static let `default` = Config(signalingServerUrl: defaultSignalingServerUrl, webRTCIceServers: defaultIceServers)
}

protocol CallListViewDelegate: class  {
    func handleCallClick(id: String)
    func handleClickOnSamePerson()
}

class CallListViewController: UIViewController {
    
    //MARK: Properties
    //    var webRTCClient: WebRTCClient?
    //     var signalClient: SignalingClient?
    //    private var signalingConnected: Bool = false
    //    private var hasRemoteSdp: Bool = false
    //    private var remoteCandidateCount: Int = 0
    //    private var localCandidateCount: Int = 0
    //    private var hasLocalSdp: Bool = false
    private let config = Config.default
    private var roomName: String?
    var onCall: Bool = false
    weak var delegate: CallListViewDelegate?
    var id: String?
    var viewModel = RecentMessagesViewModel()
    var calls: [FetchedCall] = []
    //    var vc: VideoViewController?
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activity: UIActivityIndicatorView!
    
    //MARK: LifecyclesF
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        self.sort()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //        let provider = CXProvider(configuration: ProviderDelegate.providerConfiguration)
        //        provider.setDelegate(self, queue: DispatchQueue.main)
        //        self.deleteAllData(entity: "CallEntity")
        MainTabBarController.center.delegate = self
        
        tableView.delegate = self
        tableView.dataSource = self
        getHistory()
        //        self.signalClient = self.buildSignalingClient()
        //        self.signalClient?.delegate = self
        //        self.webRTCClient?.speakerOn()
        //        handleCallAccepted()
        //        handleAnswer()
        //        getCanditantes()
        //        handleOffer()
        navigationItem.title = "Call history"
        //        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        //        self.webRTCClient?.delegate = self
        
    }
    
    //MARK: Helper methods
    func getHistory() {
        activity.startAnimating()
        viewModel.getHistory { (calls) in
            self.activity.stopAnimating()
            self.calls = calls
            if self.calls.count == 0 {
                self.addNoCallView()
            }
        }
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<viewModel.calls.count {
            for j in i..<viewModel.calls.count {
                let firstDate = viewModel.calls[i].time
                let secondDate = viewModel.calls[j].time
                if firstDate.compare(secondDate).rawValue == -1 {
                    let temp = viewModel.calls[i]
                    viewModel.calls[i] = viewModel.calls[j]
                    viewModel.calls[j] = temp
                }
            }
        }
    }
    
    func addNoCallView() {
       let label = UILabel()
        label.text = "You have no calls"
        label.tag = 20
        label.textAlignment = .center
        label.textColor = .lightGray
        self.tableView.addSubview(label)
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.anchor(top: view.topAnchor, paddingTop: 0, bottom: view.bottomAnchor, paddingBottom: 0, left: view.leftAnchor, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: 25, height: 48)
    }
    
    //    func handleCallAccepted() {
    //        SocketTaskManager.shared.handleCallAccepted { (callAccepted, roomName) in
    //            self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
    //            self.webRTCClient!.delegate = self
    //            self.vc?.webRTCClient = self.webRTCClient
    //            self.onCall = true
    //            self.roomName = roomName
    //            self.vc?.handleOffer(roomName: roomName)
    //            if callAccepted {
    //                self.webRTCClient!.offer { (sdp) in
    //                    print(sdp)
    //                    self.vc!.handleAnswer()
    //                    self.vc!.roomName = roomName
    //                    self.signalClient!.sendOffer(sdp: sdp, roomName: roomName)
    //                }
    //            }
    //        }
    //    }
    //
    //    func handleAnswer() {
    //        SocketTaskManager.shared.handleAnswer { (data) in
    //            self.webRTCClient!.answer { (localSdp) in
    //                self.hasLocalSdp = true
    //            }
    //        }
    //    }
    
    func handleCall(id: String, user: User) {
        //        SocketTaskManager.shared.handleCall { (id) in
        self.id = id
        if viewModel.calls.count >= 15 {
            viewModel.deleteItem()
        }
        //            let backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
        //            DispatchQueue.main.asyncAfter(deadline: .now()) {
        //                AppDelegate.shared.displayIncomingCall(
        //                    id: id, uuid: UUID(),
        //                    handle: "araa ekeq e!fdgfdgfdgdfdfgdfdfdgfd!!",
        //                    hasVideo: true, roomName: self.roomName ?? "") { _ in
        //                        UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
        //                }
        //            }
        //            self.viewModel.getuserById(id: id) { (user, error) in
        //                if (error != nil) {
        //                    if error == NetworkResponse.authenticationError {
        //                        UserDataController().logOutUser()
        //                        DispatchQueue.main.async {
        //                            let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
        //                            let nav = UINavigationController(rootViewController: vc)
        //                            let window: UIWindow? = UIApplication.shared.windows[0]
        //                            window?.rootViewController = nav
        //                            window?.makeKeyAndVisible()
        //                        }
        //                    }
        //                    DispatchQueue.main.async {
        //                        let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
        //                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
        //                        self.present(alert, animated: true)
        //                    }
        //                    return
        //                } else if user != nil {
        DispatchQueue.main.async {
            self.view.viewWithTag(20)?.removeFromSuperview()
            self.viewModel.save(newCall: FetchedCall(id: user._id, name: user.name, username: user.lastname, image: user.avatarURL, isHandleCall: true, time: Date(), lastname: user.lastname))
            self.sort()
            self.tableView.reloadData()
        }
        //                }
        //            }
        //        }
    }
    
    //    func getCanditantes() {
    //        SocketTaskManager.shared.getCanditantes { (data) in
    //            print(data)
    //        }
    //    }
    //
    //    func handleOffer() {
    //        SocketTaskManager.shared.handleOffer { (roomName, offer) in
    //            self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
    //            self.webRTCClient!.delegate = self
    //            self.vc?.webRTCClient = self.webRTCClient
    //            self.onCall = true
    //            self.roomName = roomName
    //            self.vc?.handleOffer(roomName: roomName)
    //            DispatchQueue.main.async {
    //                self.navigationController?.pushViewController(self.vc!, animated: false)
    //            }
    //            print(self.webRTCClient!.peerConnection?.signalingState)
    //            self.webRTCClient!.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: offer["sdp"]!), completion: { (error) in
    //                print(error?.localizedDescription)
    //            })
    //            print(self.webRTCClient)
    //            self.webRTCClient!.answer { (localSdp) in
    //                self.hasLocalSdp = true
    //                self.signalClient!.sendAnswer(roomName: roomName, sdp: localSdp)
    //            }
    //        }
    //    }
    
    

    func deleteAllData(entity: String) {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        fetchRequest.returnsObjectsAsFaults = false
        do {
            let results = try managedContext!.fetch(fetchRequest)
            for managedObject in results {
                let managedObjectData:NSManagedObject = managedObject as! NSManagedObject
                managedContext!.delete(managedObjectData)
            }
        } catch let error as NSError {
            print("Detele all data in \(entity) error : \(error) \(error.userInfo)")
        }
    }
    
    func stringToDate(date: Date) -> String {
        let parsedDate = date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
            return ("\(day).0\(month)")
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        return ("\(hour):\(minutes)")
    }
    
    
    private func buildSignalingClient() -> SignalingClient {
        return SignalingClient()
    }
}

extension CallListViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

//extension  CallListViewController: SignalClientDelegate {
//    func signalClientDidConnect(_ signalClient: SignalingClient) {
//        self.signalingConnected = true
//    }
//
//    func signalClientDidDisconnect(_ signalClient: SignalingClient) {
//        print("signalClientDidDisconnect")
//        self.signalingConnected = false
//    }
//
//    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription) {
//        print("Received remote sdp")
//        self.webRTCClient?.set(remoteSdp: sdp) { (error) in
//            print(sdp)
//            print(error?.localizedDescription ?? "error chka!!!!!!!!!!!")
//            self.hasRemoteSdp = true
//        }
//    }
//
//    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate) {
//        print("Received remote candidate")
//        self.remoteCandidateCount += 1
//        self.webRTCClient!.set(remoteCandidate: candidate)
//    }
//}

//extension CallListViewController: VideoViewControllerProtocol {
//    func handleClose() {
//
//        //        self.webRTCClient = nil
////        vc?.webRTCClient = nil
//        id = nil
//    }
//}

//extension CallListViewController: WebRTCClientDelegate {
//    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
//        DispatchQueue.main.async {
//            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
//            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
//        print("discovered local candidate")
//        self.localCandidateCount += 1
//        self.signalClient!.send(candidate: candidate, roomName: self.roomName ?? "")
//    }
//
//    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
//        if state == .closed {
//            onCall = false
//            self.webRTCClient = nil
//            vc?.webRTCClient = nil
//            id = nil
//        }
//        print(state)
//        print("did Change Connection State")
//    }
//}

//extension CallListViewController: CXProviderDelegate {
//    func providerDidReset(_ provider: CXProvider) {
//
//      }
//
//      func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
//        guard let call = callManager.callWithUUID(uuid: action.callUUID) else {
//             action.fail()
//             return
//        }
//        id = call.id
//      }
//
//      func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
//      }
//
//      func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
//      }
//
//      func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
//      }
//
//      func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
//    }
//}

extension CallListViewController: CallTableViewDelegate {
    func callSelected(id: String) {
        let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .main)
        vc.id = id
        vc.onContactPage = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

extension CallListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.calls.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell
        cell.calleId = viewModel.calls[indexPath.row].id
        cell.configureCell(call: viewModel.calls[indexPath.row])
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let call = viewModel.calls[indexPath.row]
        if onCall == false  {
            self.delegate?.handleCallClick(id: call.id)
            if viewModel.calls.count >= 15 {
                viewModel.deleteItem()
            }
            viewModel.save(newCall: FetchedCall(id: call.id, name: call.name, username: call.username, image: call.image, isHandleCall: false, time: Date(), lastname: call.lastname))
            self.sort()
            id = call.id
            tableView.reloadData()
        } else if onCall && id != nil {
            if id == call.id {
                self.delegate?.handleClickOnSamePerson()
            }
        }
    }
}
