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
import Network

let defaultSignalingServerUrl = URL(string: Environment.socketUrl)!
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
    func handleCallClick(id: String, name: String, mode: VideoVCMode)
    func handleClickOnSamePerson()
}

class CallListViewController: UIViewController, AVAudioPlayerDelegate {
    
    //MARK: Properties
    private let config = Config.default
    private var roomName: String?
    var onCall: Bool = false
    weak var delegate: CallListViewDelegate?
    var id: String?
    var viewModel: RecentMessagesViewModel?
    var calls: [CallHistory] = []
    var removedCalls: [String] = []
    var activeCall: FetchedCall?
    var tabbar: MainTabBarController?
    var count = 0
    var otherContactsCount = 0
    static let callCellIdentifier = "callCell"
    var mainRouter: MainRouter?
    var badge: Int?
    var sortedDictionary: [(CallHistory, Int)] = []
    var activity = UIActivityIndicatorView(style: .medium)
    let refreshControl = UIRefreshControl()
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    
    //MARK: Lifecycles
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            if let tabItems = self.tabbar?.tabBar.items {
                let tabItem = tabItems[0]
                tabItem.badgeValue = nil
            }
        }
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        navigationItem.title = "calls".localized()
        let count = SharedConfigs.shared.missedCalls.count
        if count > 0 && viewModel!.calls.count > 0 {
            let missed = viewModel?.calls.filter({ (call) -> Bool in
                return call.status == CallStatus.missed.rawValue
            })
            tabbar?.viewModel?.checkCallAsSeen(callId: missed![0]._id!, readOne: false, completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    DispatchQueue.main.async {
                        let nc = self.tabbar!.viewControllers![2] as! UINavigationController
                        let profile = nc.viewControllers[0] as? ProfileViewController
                        profile?.changeNotificationNumber()
                    }
                }
            })
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabbar = tabBarController as? MainTabBarController
        tableView.delegate = self
        tableView.dataSource = self
        let vc = tabbar!.viewControllers![3] as! UINavigationController
        let profileVC = vc.viewControllers[0] as! ProfileViewController
        profileVC.delegate = self
        tableView.tableFooterView = UIView()
        addResfreshControl()
        setActivity()
        getCallHistory {}
        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
    }
    
    //MARK: Helper methods
    @objc func addButtonTapped() {
        mainRouter?.showContactsViewFromCallList()
    }
    
    @objc func refreshCallHistory() {
        getCallHistory {
            self.refreshControl.endRefreshing()
        }
    }
    
    func addResfreshControl() {
           if #available(iOS 10.0, *) {
               tableView.refreshControl = refreshControl
           } else {
               tableView.addSubview(refreshControl)
           }
           refreshControl.addTarget(self, action: #selector(refreshCallHistory), for: .valueChanged)
       }
    
    func stringToDate(date:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        if parsedDate == nil {
            return nil
        } else {
            return parsedDate
        }
    }
    
    func setActivity() {
        self.view.addSubview(self.activity)
        self.activity.tag = 200
        self.activity.translatesAutoresizingMaskIntoConstraints = false
        self.activity.topAnchor.constraint(equalTo: self.tableView.topAnchor, constant: 0).isActive = true
        self.activity.rightAnchor.constraint(equalTo: self.tableView.rightAnchor, constant: 0).isActive = true
        self.activity.widthAnchor.constraint(equalTo: self.tableView.widthAnchor, multiplier: 1).isActive = true
        self.activity.heightAnchor.constraint(equalTo: self.tableView.heightAnchor, multiplier: 1).isActive = true
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<viewModel!.calls.count {
            for j in i..<viewModel!.calls.count {
                let firstDate = stringToDate(date: viewModel!.calls[i].createdAt!)
                let secondDate = stringToDate(date: viewModel!.calls[j].createdAt!)
                if firstDate!.compare(secondDate!).rawValue == -1 {
                    let temp = viewModel!.calls[i]
                    viewModel!.calls[i] = viewModel!.calls[j]
                    viewModel!.calls[j] = temp
                }
            }
        }
    }
    
    func removeCalls(isReceiverWe: Bool, callMode: CallStatus, id: String) {
        removedCalls = []
          if isReceiverWe {
              for i in 0..<(viewModel?.calls.count)! {
                  if viewModel?.calls[i].caller == id && viewModel?.calls[i].status == callMode.rawValue && viewModel?.calls[i].status == CallStatus.missed.rawValue {
                    removedCalls.append((viewModel?.calls[i]._id)!)
                  } else if viewModel?.calls[i].caller == id && callMode.rawValue != CallStatus.missed.rawValue && viewModel?.calls[i].status != CallStatus.missed.rawValue {
                    removedCalls.append((viewModel?.calls[i]._id)!)
                  }
              }
          } else {
            for call in viewModel!.calls {
                if call.caller == SharedConfigs.shared.signedUser?.id && call.receiver == id {
                    removedCalls.append(call._id!)
                }
            }
        }
      }
    
    func addNoCallView() {
        let label = UILabel()
        label.text = "you_have_no_calls".localized()
        label.tag = 20
        label.textAlignment = .center
        label.textColor = .lightGray
        self.tableView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        label.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
    }
    
    func handleCall(id: String) {
        self.id = id
        DispatchQueue.main.async {
            self.view.viewWithTag(20)?.removeFromSuperview()   
        }
    }
    
    func getCallHistory(completion: @escaping (()->())) {
        DispatchQueue.main.async {
            self.activity.startAnimating()
        }
        self.tabbar?.viewModel?.getCallHistory(completion: { (calls, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if calls != nil {
                DispatchQueue.main.async {
                    if calls?.count == 0 {
                        self.addNoCallView()
                        self.activity.stopAnimating()
                        completion()
                    } else {
                        self.view.viewWithTag(200)?.removeFromSuperview()
                        self.viewModel?.saveCalls(calls: calls!, completion: { (calls, error) in
                            if calls != nil || calls?.count == 0 {
                                self.viewModel!.calls = calls!
                                self.sort()
                                self.groupCalls()
                                self.tableView.reloadData()
                            }
                            completion()
                        })
                    }
                }
            }
        })
    }
    
    func removeView() {
        DispatchQueue.main.async {
            self.view.viewWithTag(20)?.removeFromSuperview()
        }
    }
    
    func groupCalls() {
        var callsArray = viewModel?.calls
        var dictionary: Dictionary<CallHistory, Int> = [:]
        while callsArray?.count != 0 {
            var countOfCalls = 1
            var i = 1
            while i < callsArray!.count {
                if callsArray![0].caller == SharedConfigs.shared.signedUser?.id && callsArray![0].caller == callsArray![i].caller && callsArray![0].receiver == callsArray![i].receiver {
                    countOfCalls += 1
                    callsArray?.remove(at: i)
                } else if callsArray![0].receiver == SharedConfigs.shared.signedUser?.id && callsArray![0].status == callsArray![i].status && callsArray![0].status == CallStatus.missed.rawValue && callsArray![0].caller == callsArray![i].caller {
                    countOfCalls += 1
                    callsArray?.remove(at: i)
                } else if callsArray![0].receiver == SharedConfigs.shared.signedUser?.id && callsArray![0].status != CallStatus.missed.rawValue && callsArray![i].status != CallStatus.missed.rawValue && callsArray![0].caller == callsArray![i].caller {
                    countOfCalls += 1
                    callsArray?.remove(at: i)
                } else {
                    i += 1
                }
            }
            dictionary[callsArray![0]] = countOfCalls
            callsArray?.remove(at: 0)
        }
        
        sortedDictionary = dictionary.sorted { (arg0, arg1) -> Bool in
            return stringToDate(date: arg0.key.callSuggestTime!)!.compare(stringToDate(date: arg1.key.callSuggestTime!)!).rawValue == 1
        }
    }
    
    func getCallHistoryFromDB() {
        viewModel?.getHistory(completion: { (callsFromDB) in
            self.tableView.reloadData()
        })
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
    
    func showEndedCall(_ callHistory: CallHistory) {
        viewModel?.save(newCall: callHistory, completion: {
            if self.tableView != nil {
                self.sort()
                self.groupCalls()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                if callHistory.status == CallStatus.missed.rawValue {
                    if AppDelegate.shared.isVoIPCallStarted != nil && AppDelegate.shared.isVoIPCallStarted! {
                        AppDelegate.shared.isVoIPCallStarted = false
                        SocketTaskManager.shared.disconnect{}
                        
                    }
                } else {
                    AppDelegate.shared.isVoIPCallStarted = false
                }
            }
        })
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
    
    func getUser(_ cell: CallTableViewCell, _ indexPath: Int) {
        viewModel!.getuserById(id: cell.calleId!) { (user, error) in
            DispatchQueue.main.async {
                if error != nil {
                    cell.configureCell(contact: User(name: nil, lastname: nil, _id: cell.calleId!, username: nil, avaterURL: nil, email: nil, info: nil, phoneNumber: nil, birthday: nil, address: nil, gender: nil, missedCallHistory: nil, channels: nil), call: self.sortedDictionary[indexPath].0, count: self.sortedDictionary[indexPath].1)
                } else if user != nil {
                    var newArray = self.tabbar?.contactsViewModel?.otherContacts
                    newArray?.append(user!)
                    self.tabbar?.viewModel!.saveOtherContacts(otherContacts: newArray!, completion: { (users, error) in
                        self.tabbar?.contactsViewModel!.otherContacts = users!
                    })
                    cell.configureCell(contact: user!, call: self.sortedDictionary[indexPath].0, count: self.sortedDictionary[indexPath].1)
                }
            }
        }
    }
}

// MAARK: Extensions
extension CallListViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension CallListViewController: CallTableViewDelegate {
    
    func callSelected(id: String, duration: String, callStartTime: Date?, callStatus: String, type: String, name: String, avatarURL: String, isReceiverWe: Bool) {
        var status: CallStatus?
        if callStatus == "ongoing" {
            status = .ongoing
        } else if callStatus == "missed" {
            status = .missed
        } else if callStatus == "accepted" {
            status = .accepted
        } else {
            status = .cancelled
        }
        mainRouter?.showCallDetailViewController(id: id, name: name, duration: duration, time: callStartTime!, callMode: status!, avatarURL: avatarURL, isReceiverWe: isReceiverWe)
    }
    
}

extension CallListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sortedDictionary.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.callCellIdentifier, for: indexPath) as! CallTableViewCell
        cell.calleId = sortedDictionary[indexPath.row].0.caller == SharedConfigs.shared.signedUser?.id ? sortedDictionary[indexPath.row].0.receiver : sortedDictionary[indexPath.row].0.caller
        var existsInContactList = false
        count = tabbar!.contactsViewModel!.contacts.count
        otherContactsCount = tabbar!.contactsViewModel!.otherContacts.count
        for i in 0..<count {
            if tabbar?.contactsViewModel!.contacts[i]._id == cell.calleId {
                existsInContactList = true
                cell.configureCell(contact: tabbar!.contactsViewModel!.contacts[i], call: sortedDictionary[indexPath.row].0, count: sortedDictionary[indexPath.row].1)
                break
            }
        }
        if existsInContactList == false {
            for i in 0..<otherContactsCount {
                if tabbar?.contactsViewModel!.otherContacts[i]._id == cell.calleId {
                    existsInContactList = true
                    cell.configureCell(contact: tabbar!.contactsViewModel!.otherContacts[i], call: sortedDictionary[indexPath.row].0, count: sortedDictionary[indexPath.row].1)
                    break
                }
            }
            if existsInContactList == false {
                getUser(cell, indexPath.row)
            }
        }
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        self.sort()
        tableView.beginUpdates()
        var callMode: CallStatus = .accepted
        if viewModel?.calls[indexPath.row].status == CallStatus.missed.rawValue {
            callMode = .missed
        } else if viewModel?.calls[indexPath.row].status == CallStatus.accepted.rawValue {
            callMode = .accepted
        } else if viewModel?.calls[indexPath.row].status == CallStatus.cancelled.rawValue {
            callMode = .cancelled
        }
        let isreceiverMe = viewModel?.calls[indexPath.row].receiver == SharedConfigs.shared.signedUser?.id
        removeCalls(isReceiverWe: isreceiverMe, callMode: callMode, id: isreceiverMe ? (viewModel?.calls[indexPath.row].caller)! : (viewModel?.calls[indexPath.row].receiver)!)
        tabbar?.viewModel?.removeCall(id: removedCalls, completion: { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else {
                DispatchQueue.main.async {
                    self.viewModel!.deleteItem(id: self.removedCalls, completion: { (error)   in
                        self.sortedDictionary.remove(at: indexPath.row)
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                         tableView.endUpdates()
                        if self.viewModel!.calls.count == 0 {
                            self.addNoCallView()
                        } else {
                            self.view.viewWithTag(20)?.removeFromSuperview()
                        }
                    })
                }
            }
        })
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 76
    }
    
    func saveCall(startDate: Date?) {
        if startDate == nil {
            activeCall?.callDuration = 0
        } else {
            let userCalendar = Calendar.current
            let requestedComponent: Set<Calendar.Component> = [.hour, .minute, .second]
            let timeDifference = userCalendar.dateComponents(requestedComponent, from: startDate!, to: Date())
            let hourToSeconds = timeDifference.hour! * 3600
            let minuteToSeconds = timeDifference.minute! * 60
            let seconds = timeDifference.second!
            activeCall?.callDuration = hourToSeconds + minuteToSeconds + seconds
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        count = tabbar!.contactsViewModel!.contacts.count
        otherContactsCount = tabbar!.contactsViewModel!.otherContacts.count
        let call = sortedDictionary[indexPath.row].0
        activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: SharedConfigs.shared.signedUser!.id)
        activeCall?.time = Date()
        activeCall?.isHandleCall = false
        let calleeId = call.caller == SharedConfigs.shared.signedUser?.id ? call.receiver : call.caller
        if onCall == false  {
            self.delegate?.handleCallClick(id: (call.receiver == SharedConfigs.shared.signedUser?.id ? call.caller : call.receiver)!, name: (tableView.cellForRow(at: indexPath) as! CallTableViewCell).nameLabel.text ?? "", mode: .videoCall)
        } else if onCall && id != nil {
            if id == calleeId {
                self.delegate?.handleClickOnSamePerson()
            }
        }
    }
}

extension CallListViewController: ProfileViewControllerDelegate {
    func changeLanguage(key: String) {
        self.tableView.reloadData()
    }
}
