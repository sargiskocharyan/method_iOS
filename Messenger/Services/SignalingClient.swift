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

    func connect() {
        self.socketTaskManager.connect()
    }
    
//    func sendAnswer(sdp rtcSdp: RTCSessionDescription, roomName: String) {
//           let json = [
//               "type": "answer",
//               "sdp": "\(rtcSdp.sdp)"
//           ]
//           self.socketTaskManager.answer(roomName: roomName, payload: json)
//       }
    
    func sendOffer(sdp rtcSdp: RTCSessionDescription, roomName: String) {
        let json = [
            "type": "offer",
            "sdp": "\(rtcSdp.sdp)"
        ]
        self.socketTaskManager.offer(roomName: roomName, payload: json)
    }
    
    func send(candidate rtcIceCandidate: RTCIceCandidate, roomName: String) {
//        let message = MessageData.candidate(IceCandidate(from: rtcIceCandidate))
        print(rtcIceCandidate)
        let json: Dictionary = ["candidate": rtcIceCandidate.sdp, "sdpMid": rtcIceCandidate.sdpMid, "sdpMLineIndex": rtcIceCandidate.sdpMLineIndex] as [String : Any]
        do {
//            let dataMessage = try self.encoder.encode(message)
//            print(String(data: dataMessage, encoding: .utf8))
            print(json)
            self.socketTaskManager.send(data: json, roomName: roomName)
        }
        catch {
            debugPrint("Warning: Could not encode candidate: \(error)")
        }
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
//extension SignalingClient: WebSocketProviderDelegate {
//    func webSocketDidConnect(_ webSocket: WebSocketProvider) {
//        self.delegate?.signalClientDidConnect(self)
//    }
//    
//    func webSocketDidDisconnect(_ webSocket: WebSocketProvider) {
//        self.delegate?.signalClientDidDisconnect(self)
//        
//        // try to reconnect every two seconds
//        DispatchQueue.global().asyncAfter(deadline: .now() + 2) {
//            debugPrint("Trying to reconnect to signaling server...")
//            self.webSocket.connect()
//        }
//    }
//    
//    func webSocket(_ webSocket: WebSocketProvider, didReceiveData data: Data) {
//        let message: MessageData
//        do {
//            message = try self.decoder.decode(MessageData.self, from: data)
//        }
//        catch {
//            debugPrint("Warning: Could not decode incoming message: \(error)")
//            return
//        }
//        print(111)
//        print(message)
//        switch message {
//        case .candidate(let iceCandidate):
//            self.delegate?.signalClient(self, didReceiveCandidate: iceCandidate.rtcIceCandidate)
//        case .sdp(let sessionDescription):
//            self.delegate?.signalClient(self, didReceiveRemoteSdp: sessionDescription.rtcSessionDescription)
//        }
//
//    }
//}
