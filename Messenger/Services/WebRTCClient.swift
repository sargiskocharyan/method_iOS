//
//  WebRTCClient.swift
//  WebRTC
//
//  Created by Stasel on 20/05/2018.
//  Copyright © 2018 Stasel. All rights reserved.
//

import Foundation
import WebRTC

protocol WebRTCClientDelegate: class {
    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate)
    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState)
    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data)
}

protocol WebRTCDelegate {
    func removeView()
}

final class WebRTCClient: NSObject {
    
    // The `RTCPeerConnectionFactory` is in charge of creating new RTCPeerConnection instances.
    // A new RTCPeerConnection should be created every new call, but the factory is shared.
     static let factory: RTCPeerConnectionFactory = {
        RTCInitializeSSL()
        let videoEncoderFactory = RTCDefaultVideoEncoderFactory()
        let videoDecoderFactory = RTCDefaultVideoDecoderFactory()
        return RTCPeerConnectionFactory(encoderFactory: videoEncoderFactory, decoderFactory: videoDecoderFactory)
    }()
    
    weak var delegate: WebRTCClientDelegate?
    var peerConnection: RTCPeerConnection?
    private let rtcAudioSession =  RTCAudioSession.sharedInstance()
    private let audioQueue = DispatchQueue(label: "audio")
    private let mediaConstrains = [kRTCMediaConstraintsOfferToReceiveAudio: kRTCMediaConstraintsValueTrue,
                                   kRTCMediaConstraintsOfferToReceiveVideo: kRTCMediaConstraintsValueTrue]    
    var videoCapturer: RTCVideoCapturer?
    var localVideoTrack: RTCVideoTrack?
    var remoteVideoTrack: RTCVideoTrack?
    private var localDataChannel: RTCDataChannel?
    //    private var remoteDataChannel: RTCDataChannel?
    private var audioTrackGlobal: RTCAudioTrack?
    var webRTCCDelegate: WebRTCDelegate?
    var stream: RTCMediaStream?
    var frontCamera: AVCaptureDevice?
    var backCamera: AVCaptureDevice?
    var frontFormat: AVCaptureDevice.Format?
    var backFormat: AVCaptureDevice.Format?
    var frontFps: AVFrameRateRange?
    var backFps: AVFrameRateRange?
    @available(*, unavailable)
    override init() {
        fatalError("WebRTCClient:init is unavailable")
    }
    
    required init(iceServers: [String]) {
        let config = RTCConfiguration()
        config.iceServers = [RTCIceServer(urlStrings: iceServers)]
        config.sdpSemantics = .unifiedPlan
        config.continualGatheringPolicy = .gatherContinually
        let constraints = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: ["DtlsSrtpKeyAgreement":kRTCMediaConstraintsValueTrue])
        self.peerConnection = WebRTCClient.factory.peerConnection(with: config, constraints: constraints, delegate: nil)
        super.init()
        self.createMediaSenders()
        self.configureAudioSession()
        self.peerConnection!.delegate = self
        frontCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .front })
        backCamera = (RTCCameraVideoCapturer.captureDevices().first { $0.position == .back })
        frontFormat = (RTCCameraVideoCapturer.supportedFormats(for: frontCamera!).sorted { (f1, f2) -> Bool in
            let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
            let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
            return width1 < width2
        }).last
        backFormat = (RTCCameraVideoCapturer.supportedFormats(for: backCamera!).sorted { (f1, f2) -> Bool in
            let width1 = CMVideoFormatDescriptionGetDimensions(f1.formatDescription).width
            let width2 = CMVideoFormatDescriptionGetDimensions(f2.formatDescription).width
            return width1 < width2
        }).last
        frontFps = (frontFormat!.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last)
        backFps = (backFormat!.videoSupportedFrameRateRanges.sorted { return $0.maxFrameRate < $1.maxFrameRate }.last)
    }
    
    // MARK: Signaling
    func offer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void) {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        self.peerConnection?.offer(for: constrains) { (sdp, error) in
            print(error?.localizedDescription as Any)
            guard let sdp = sdp else {
                return
            }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (error) in
                completion(sdp)
            })
        }
    }
    
    func answer(completion: @escaping (_ sdp: RTCSessionDescription) -> Void)  {
        let constrains = RTCMediaConstraints(mandatoryConstraints: self.mediaConstrains, optionalConstraints: nil)
        
        self.peerConnection?.answer(for: constrains) { (sdp, error) in
            print(error?.localizedDescription as Any)
            guard let sdp = sdp else {
                return
            }
            self.peerConnection?.setLocalDescription(sdp, completionHandler: { (error) in
                print(error?.localizedDescription as Any)
                completion(sdp)
            })
        }
    }
    
    func set(remoteSdp: RTCSessionDescription, completion: @escaping (Error?) -> ()) {
        self.peerConnection?.setRemoteDescription(remoteSdp, completionHandler: completion)
    }
    
    func set(remoteCandidate: RTCIceCandidate) {
        self.peerConnection?.add(remoteCandidate)
    }
    
    // MARK: Media
    
    func addRenderer(renderer: RTCVideoRenderer) {
        localVideoTrack?.add(renderer)
    }
    
    func startCaptureLocalVideo(renderer: RTCVideoRenderer, cameraPosition: AVCaptureDevice.Position, completion: @escaping () ->()) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
            return
        }
        if cameraPosition == .back {
                capturer.startCapture(with: self.backCamera!, format: self.backFormat!, fps: Int(self.backFps!.maxFrameRate)) { (error) in
                    completion()
                    return
            }
            
        } else if cameraPosition == .front {
                capturer.startCapture(with: self.frontCamera!, format: self.frontFormat!, fps: Int(self.frontFps!.maxFrameRate)) { (error) in
                    completion()
                    return
                }
        }
        
    }
    
    func stopCaptureLocalVideo(renderer: RTCVideoRenderer, completion: @escaping () -> ()) {
        guard let capturer = self.videoCapturer as? RTCCameraVideoCapturer else {
                   return
               }
        localVideoTrack?.isEnabled = false
        capturer.stopCapture {
//            self.localVideoTrack?.remove(renderer)
//            self.stream?.removeVideoTrack(self.localVideoTrack!)
//            self.peerConnection?.remove(self.stream!)
//            self.localVideoTrack = nil
//            self.videoCapturer = nil
            completion()
            return
        }
    }

    
    
    func renderRemoteVideo(to renderer: RTCVideoRenderer) {
        self.remoteVideoTrack?.add(renderer)
        webRTCCDelegate?.removeView()
    }
    
    private func configureAudioSession() {
        self.rtcAudioSession.lockForConfiguration()
        do {
            try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
            try self.rtcAudioSession.setMode(AVAudioSession.Mode.voiceChat.rawValue)
        } catch let error {
            debugPrint("Error changeing AVAudioSession category: \(error)")
        }
        self.rtcAudioSession.unlockForConfiguration()
    }

    private func createMediaSenders() {
        let streamId = "stream"
        
        // Audio
        let audioTrack = self.createAudioTrack()
        audioTrackGlobal = audioTrack
        self.peerConnection?.add(audioTrackGlobal!, streamIds: [streamId])
        
        // Video
        let videoTrack = self.createVideoTrack()
        self.localVideoTrack = videoTrack
        
        self.peerConnection?.add(videoTrack, streamIds: [streamId])
        self.remoteVideoTrack = self.peerConnection?.transceivers.first { $0.mediaType == .video }?.receiver.track as? RTCVideoTrack
        
        // Data
        if let dataChannel = createDataChannel() {
            self.localDataChannel = dataChannel
            self.localDataChannel!.delegate = self
        }
    }
    
    private func createAudioTrack() -> RTCAudioTrack {
        let audioConstrains = RTCMediaConstraints(mandatoryConstraints: nil, optionalConstraints: nil)
        let audioSource = WebRTCClient.factory.audioSource(with: audioConstrains)
        let audioTrack = WebRTCClient.factory.audioTrack(with: audioSource, trackId: "audio0")
        return audioTrack
    }
    
    
    func removeThracks() {
        stream?.removeVideoTrack(self.localVideoTrack!)
        stream?.removeVideoTrack(self.remoteVideoTrack!)
        stream?.removeAudioTrack(audioTrackGlobal!)
    }
    
    
    
    func createVideoTrack() -> RTCVideoTrack {
        let videoSource = WebRTCClient.factory.videoSource()
        
        #if TARGET_OS_SIMULATOR
        self.videoCapturer = RTCFileVideoCapturer(delegate: videoSource)
        #else
        self.videoCapturer = RTCCameraVideoCapturer(delegate: videoSource)
        #endif
        
        let videoTrack = WebRTCClient.factory.videoTrack(with: videoSource, trackId: "video0")
        return videoTrack
    }
    
    // MARK: Data Channels
    private func createDataChannel() -> RTCDataChannel? {
        let config = RTCDataChannelConfiguration()
        config.channelId = 1
        config.isOrdered = true
        config.isNegotiated = true
        config.maxPacketLifeTime = 30000
        guard let dataChannel = self.peerConnection?.dataChannel(forLabel: "1", configuration: config) else {
            debugPrint("Warning: Couldn't create data channel.")
            return nil
        }
        return dataChannel
    }
    
    func sendData(_ data: Data) {
        let buffer = RTCDataBuffer(data: data, isBinary: true)
//        print("\n\nsendData \(self.localDataChannel)")
        self.localDataChannel!.sendData(buffer)
    }
}

extension WebRTCClient: RTCPeerConnectionDelegate {
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange stateChanged: RTCSignalingState) {
        debugPrint("peerConnection new signaling state: \(stateChanged)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didAdd stream: RTCMediaStream) {
        self.stream = stream
        debugPrint("peerConnection did add stream")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove stream: RTCMediaStream) {
        self.stream = nil
        debugPrint("peerConnection did remove stream")
    }
    
    func peerConnectionShouldNegotiate(_ peerConnection: RTCPeerConnection) {
        debugPrint("peerConnection should negotiate")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceConnectionState) {
        debugPrint("peerConnection new connection state: \(newState)")
        self.delegate?.webRTCClient(self, didChangeConnectionState: newState)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCIceGatheringState) {
        debugPrint("peerConnection new gathering state: \(newState)")
        
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didChange newState: RTCPeerConnectionState) {
         debugPrint("peerConnection new RTCPeerConnectionState state: \(newState)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didGenerate candidate: RTCIceCandidate) {
        self.delegate?.webRTCClient(self, didDiscoverLocalCandidate: candidate)
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didRemove candidates: [RTCIceCandidate]) {
        debugPrint("peerConnection did remove candidate(s)")
    }
    
    func peerConnection(_ peerConnection: RTCPeerConnection, didOpen dataChannel: RTCDataChannel) {
        debugPrint("peerConnection did open remote data channel")
        dataChannel.delegate = self
        self.localDataChannel = dataChannel
        
    }
}

// MARK:- Audio control
extension WebRTCClient {
    func muteAudio() {
        self.setAudioEnabled(false)
    }
    
    func unmuteAudio() {
        self.setAudioEnabled(true)
    }
    
    func speakerOff() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.none)
            } catch let error {
                debugPrint("Error setting AVAudioSession category: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    func speakerOn() {
        self.audioQueue.async { [weak self] in
            guard let self = self else {
                return
            }
            self.rtcAudioSession.lockForConfiguration()
            do {
                try self.rtcAudioSession.setCategory(AVAudioSession.Category.playAndRecord.rawValue)
                try self.rtcAudioSession.overrideOutputAudioPort(.speaker)
                try self.rtcAudioSession.setActive(true)
            } catch let error {
                debugPrint("Couldn't force audio to speaker: \(error)")
            }
            self.rtcAudioSession.unlockForConfiguration()
        }
    }
    
    private func setAudioEnabled(_ isEnabled: Bool) {
        let audioTracks = self.peerConnection?.transceivers.compactMap { return $0.sender.track as? RTCAudioTrack }
        audioTracks?.forEach { $0.isEnabled = isEnabled }
    }
}

extension WebRTCClient: RTCDataChannelDelegate {
    func dataChannelDidChangeState(_ dataChannel: RTCDataChannel) {
        print("dataChannel did change state: \(dataChannel.readyState)")
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didReceiveMessageWith buffer: RTCDataBuffer) {
        self.delegate?.webRTCClient(self, didReceiveData: buffer.data)
    }
    
    func dataChannel(_ dataChannel: RTCDataChannel, didChangeBufferedAmount amount: UInt64) {
        print("Amount \(amount)")
        print("didChangeBufferedAmount")
    }
    
}
