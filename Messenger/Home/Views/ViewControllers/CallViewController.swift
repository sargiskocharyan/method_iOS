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

class CallViewController: UIViewController {
    
    //MARK: Properties
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
    var viewModel = RecentMessagesViewModel()
    let vc = VideoViewController.instantiate(fromAppStoryboard: .main)
    var calls: [NSManagedObject] = []
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        guard let appDelegate =
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CallEntity")
        do {
            calls = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        self.sort()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBarController.center.delegate = self
        callManager = AppDelegate.shared.callManager
        tableView.delegate = self
        tableView.dataSource = self
        self.webRTCClient = WebRTCClient(iceServers: self.config.webRTCIceServers)
        self.signalClient = self.buildSignalingClient()
        self.webRTCClient?.delegate = self
        self.signalClient?.delegate = self
        self.webRTCClient?.speakerOn()
        handleCallAccepted()
        handleAnswer()
        handleCall()
        getCanditantes()
        handleOffer()
    }
    
    //MARK: Helper methods
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<calls.count {
            for j in i..<calls.count {
                let firstDate = calls[i].value(forKey: "time") as! Date
                let secondDate = calls[j].value(forKey: "time") as! Date
                if firstDate.compare(secondDate).rawValue == -1 {
                    let temp = calls[i]
                    calls[i] = calls[j]
                    calls[j] = temp
                }
            }
        }
    }
    
    func handleCallAccepted() {
        SocketTaskManager.shared.handleCallAccepted { (callAccepted, roomName) in
            print("callAccepted")
            print(callAccepted, roomName)
            self.roomName = roomName
            if callAccepted {
                self.webRTCClient?.offer { (sdp) in
                    print(sdp)
                    self.vc.roomName = roomName
                    self.signalClient!.sendOffer(sdp: sdp, roomName: roomName)
                    self.vc.handleAnswer()
                }
            }
        }
    }
    
    func handleAnswer() {
        SocketTaskManager.shared.handleAnswer { (data) in
            self.webRTCClient?.answer { (localSdp) in
                self.hasLocalSdp = true
            }
        }
    }
    
    func handleCall() {
        SocketTaskManager.shared.handleCall { (id) in
            let backgroundTaskIdentifier =
                UIApplication.shared.beginBackgroundTask(expirationHandler: nil)
            
            DispatchQueue.main.asyncAfter(deadline: .now()) {
                AppDelegate.shared.displayIncomingCall(
                    id: id, uuid: UUID(),
                    handle: "araa ekeq e!fdgfdgfdgdfdfgdfdfdgfd!!",
                    hasVideo: true
                ) { _ in
                    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
                }
            }
            self.viewModel.getuserById(id: id) { (user, error) in
                if (error != nil) {
                    if error == NetworkResponse.authenticationError {
                        UserDataController().logOutUser()
                        DispatchQueue.main.async {
                            let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                            let nav = UINavigationController(rootViewController: vc)
                            let window: UIWindow? = UIApplication.shared.windows[0]
                            window?.rootViewController = nav
                            window?.makeKeyAndVisible()
                        }
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    return
                } else if user != nil {
                    DispatchQueue.main.async {
                        self.save(name: user!.name ?? "", lastname: user!.lastname ?? "", username: user!.username ?? "", id: user!._id, time: Date(), image: user!.avatarURL ?? "", isHandleCall: true)
                        self.sort()
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }
    
    func getCanditantes() {
        SocketTaskManager.shared.getCanditantes { (data) in
            print(data)
        }
    }
    
    func handleOffer() {
        SocketTaskManager.shared.handleOffer { (roomName, offer) in
            self.webRTCClient?.set(remoteSdp: RTCSessionDescription(type: RTCSdpType.offer, sdp: offer["sdp"]!), completion: { (error) in
                print(error?.localizedDescription)
            })
            self.webRTCClient?.answer { (localSdp) in
                self.hasLocalSdp = true
                self.signalClient!.sendAnswer(roomName: roomName, sdp: localSdp)
                DispatchQueue.main.async {
                    let vc = VideoViewController.instantiate(fromAppStoryboard: .main)
                    vc.webRTCClient = self.webRTCClient
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
     func save(name: String, lastname: String, username: String, id: String, time: Date, image: String, isHandleCall: Bool) {
         guard let appDelegate = AppDelegate.shared as? AppDelegate else {
             return
         }
         let managedContext = appDelegate.persistentContainer.viewContext
         let entity = NSEntityDescription.entity(forEntityName: "CallEntity", in: managedContext)!
         let call = NSManagedObject(entity: entity, insertInto: managedContext)
         call.setValue(name, forKeyPath: "name")
         call.setValue(lastname, forKeyPath: "lastname")
         call.setValue(username, forKeyPath: "username")
         call.setValue(id, forKeyPath: "id")
         call.setValue(image, forKeyPath: "image")
         call.setValue(time, forKeyPath: "time")
         call.setValue(isHandleCall, forKeyPath: "isHandleCall")
         do {
             try managedContext.save()
             calls.append(call)
         } catch let error as NSError {
             print("Could not save. \(error), \(error.userInfo)")
         }
     }
    
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
            print(sdp)
            print(error?.localizedDescription ?? "error chka!!!!!!!!!!!")
            self.hasRemoteSdp = true
        }
    }
    
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
      print("did Change Connection State")
    }
}

extension CallViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
           return calls.count
       }
       
       func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
           let cell = tableView.dequeueReusableCell(withIdentifier: "callCell", for: indexPath) as! CallTableViewCell
           cell.configureCell(call: calls[indexPath.row])
           return cell
       }
       
      
       
       func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
           return 76
       }
    
       
       func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
           let call = calls[indexPath.row]
           SocketTaskManager.shared.call(id: call.value(forKey: "id") as! String)
           callManager.startCall(handle: call.value(forKey: "id") as! String, videoEnabled: true)
           save(name: call.value(forKey: "name") as! String, lastname: call.value(forKey: "lastname") as! String, username: call.value(forKey: "username") as! String, id: call.value(forKey: "id") as! String, time: Date(), image: call.value(forKey: "image") as! String, isHandleCall: false)
           self.sort()
           tableView.reloadData()
           vc.webRTCClient = self.webRTCClient
           self.vc.startCall()
           self.navigationController?.pushViewController(vc, animated: true)
       }
}
