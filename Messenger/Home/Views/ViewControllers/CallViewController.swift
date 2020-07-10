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

class ProviderDelegate: NSObject {
  // 1.
  private let callManager: CallManager
  private let provider: CXProvider
  
  init(callManager: CallManager) {
    self.callManager = callManager
    // 2.
    provider = CXProvider(configuration: ProviderDelegate.providerConfiguration)
    
    
    super.init()
    // 3.
    provider.setDelegate(self, queue: nil)
  }
    func reportIncomingCall(
      uuid: UUID,
      handle: String,
      hasVideo: Bool = false,
      completion: ((Error?) -> Void)?
    ) {
      // 1.
      let update = CXCallUpdate()
      update.remoteHandle = CXHandle(type: .phoneNumber, value: handle)
      update.hasVideo = hasVideo
      
      // 2.
      provider.reportNewIncomingCall(with: uuid, update: update) { error in
        if error == nil {
          // 3.
          let call = Call(uuid: uuid, handle: handle)
          self.callManager.add(call: call)
        }
        
        // 4.
        completion?(error)
      }
    }
  
  // 4.
  static var providerConfiguration: CXProviderConfiguration = {
    let providerConfiguration = CXProviderConfiguration(localizedName: "Hotline")
    
    providerConfiguration.supportsVideo = true
    providerConfiguration.maximumCallsPerCallGroup = 1
    providerConfiguration.supportedHandleTypes = [.phoneNumber]
    
    return providerConfiguration
  }()
}

class CallViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        MainTabBarController.center.delegate = self
    }
}

extension ProviderDelegate: CXProviderDelegate {
  func providerDidReset(_ provider: CXProvider) {
    print("Stopping audio")
    
    for call in callManager.calls {
      call.end()
    }
    
    callManager.removeAllCalls()
  }
}

class CallManager {
  var callsChangedHandler: (() -> Void)?
  
  private(set) var calls: [Call] = []

  func callWithUUID(uuid: UUID) -> Call? {
    guard let index = calls.index(where: { $0.uuid == uuid }) else {
      return nil
    }
    return calls[index]
  }
  
  func add(call: Call) {
    calls.append(call)
    call.stateChanged = { [weak self] in
      guard let self = self else { return }
      self.callsChangedHandler?()
    }
    callsChangedHandler?()
  }
  
  func remove(call: Call) {
    guard let index = calls.index(where: { $0 === call }) else { return }
    calls.remove(at: index)
    callsChangedHandler?()
  }
  
  func removeAllCalls() {
    calls.removeAll()
    callsChangedHandler?()
  }
}



enum CallState {
  case connecting
  case active
  case held
  case ended
}

enum ConnectedState {
  case pending
  case complete
}

class Call {
  let uuid: UUID
  let outgoing: Bool
  let handle: String
  
  var state: CallState = .ended {
    didSet {
      stateChanged?()
    }
  }
  
  var connectedState: ConnectedState = .pending {
    didSet {
      connectedStateChanged?()
    }
  }
  
  var stateChanged: (() -> Void)?
  var connectedStateChanged: (() -> Void)?
  
  init(uuid: UUID, outgoing: Bool = false, handle: String) {
    self.uuid = uuid
    self.outgoing = outgoing
    self.handle = handle
  }
  
  func start(completion: ((_ success: Bool) -> Void)?) {
    completion?(true)

    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
      self.state = .connecting
      self.connectedState = .pending
      
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
        self.state = .active
        self.connectedState = .complete
      }
    }
  }
  
  func answer() {
    state = .active
  }
  
  func end() {
    state = .ended
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
