//
//  SignalClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC
struct Payload: Encodable {
    let type = "offer"
    let sdp: String
}
protocol SignalClientDelegate: class {
    func signalClientDidConnect(_ signalClient: SignalingClient)
    func signalClientDidDisconnect(_ signalClient: SignalingClient)
    func signalClient(_ signalClient: SignalingClient, didReceiveRemoteSdp sdp: RTCSessionDescription)
    func signalClient(_ signalClient: SignalingClient, didReceiveCandidate candidate: RTCIceCandidate)
}

final class SignalingClient {
    
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()
    private let socketTaskManager = SocketTaskManager.shared
    weak var delegate: SignalClientDelegate?
    
    init() {
        self.socketTaskManager.delegate = self
    }

//    func connect() {
//        self.socketTaskManager.connect {
//            print("Connected")
//        }
//    }
    
    func sendOffer(sdp rtcSdp: RTCSessionDescription, roomName: String) {
        let json = [
            "type": "offer",
            "sdp": "\(rtcSdp.sdp)"
        ]
        self.socketTaskManager.offer(roomName: roomName, payload: json)
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate, roomName: String) {
        print(rtcIceCandidate)
        let json: Dictionary<String, Any> = ["candidate": rtcIceCandidate.sdp, "sdpMid": rtcIceCandidate.sdpMid as Any, "sdpMLineIndex": rtcIceCandidate.sdpMLineIndex]
        self.socketTaskManager.send(data: json, roomName: roomName)
    }
    
    func sendAnswer(roomName: String, sdp: RTCSessionDescription) {
        let json = ["type": "answer", "sdp": sdp.sdp]
        SocketTaskManager.shared.answer(roomName: roomName, answer: json)
    }
}

extension SignalingClient: SocketIODelegate {
    func receiveCandidate(remoteCandidate: RTCIceCandidate) {
        self.delegate?.signalClient(self, didReceiveCandidate: remoteCandidate)
    }

    func receiveData(sdp: String) {
        self.delegate?.signalClient(self, didReceiveRemoteSdp: RTCSessionDescription(type: .answer, sdp: sdp))
    }
}
