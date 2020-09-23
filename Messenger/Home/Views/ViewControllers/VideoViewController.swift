//
//  VideoViewController.swift
//  Messenger
//
//  Created by Employee1 on 7/14/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import WebRTC
import AVFoundation
enum VideoVCMode: String {
    case audioCall = "audio"
    case videoCall = "video"
}

class VideoViewController: UIViewController, AVAudioPlayerDelegate {
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print(error?.localizedDescription as Any)
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print(flag)
    }
    
    
    var roomName: String?
    var webRTCClient: WebRTCClient?
    var cameraPosition = AVCaptureDevice.Position.front
    var isMicrophoneOn = true
    var isSpeakerOn = true
    var localRenderer: UIView?
    var isCameraOff = true
    var remoteRenderer: UIView?
    var videoVCMode: VideoVCMode?
    var player: AVAudioPlayer?
    var isCallHandled: Bool?
    @IBOutlet weak var ourView: UIView!
    @IBOutlet weak var cameraOffButton: UIButton!
    @IBOutlet weak var speakerOnOffButton: UIButton!
    @IBOutlet weak var cameraSwitchButton: UIButton!
    let callManager = AppDelegate.shared.callManager
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        if videoVCMode == .videoCall {
            DispatchQueue.main.async {
                self.cameraOffButton.setImage(UIImage(named: "cameraOff"), for: .normal)
            }
            isSpeakerOn = true
            speakerOnOffButton.setImage(UIImage(named: "speakerOn"), for: .normal)
            webRTCClient?.speakerOn()
            #if arch(arm64)
            localRenderer = RTCMTLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
            remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
            (localRenderer! as! RTCMTLVideoView).videoContentMode = .scaleAspectFill
            (remoteRenderer! as! RTCMTLVideoView).videoContentMode = .scaleAspectFill
            ourView.transform = CGAffineTransform(scaleX: -1, y: 1);
            #else
            localRenderer = RTCEAGLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
            remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
            #endif
            remoteRenderer!.tag = 10
            localRenderer!.tag = 11
            self.webRTCClient?.localVideoTrack?.add(localRenderer as! RTCVideoRenderer)
            self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer! as! RTCVideoRenderer, cameraPosition: cameraPosition, completion: {})
            self.webRTCClient?.renderRemoteVideo(to: remoteRenderer! as! RTCVideoRenderer)
            if let localVideoView = self.ourView {
                self.embedView(localRenderer!, into: localVideoView)
            }
            self.embedView(remoteRenderer!, into: self.view)
            self.view.sendSubviewToBack(remoteRenderer!)
            cameraSwitchButton.isEnabled = true
        } else {
            DispatchQueue.main.async {
                self.cameraOffButton.setImage(UIImage(named: "cameraOn"), for: .normal)
            }
            isSpeakerOn = false
            cameraSwitchButton.isEnabled = false
            speakerOnOffButton.setImage(UIImage(named: "speakerOff"), for: .normal)
            webRTCClient?.speakerOff()
            ourView.backgroundColor = .clear
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "videoColor")
        webRTCClient?.webRTCCDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    
    @IBAction func cameraOffOrOnAction(_ sender: UIButton) {
        if videoVCMode == .videoCall {
            if isCameraOff {
                webRTCClient?.stopCaptureLocalVideo(renderer: localRenderer! as! RTCVideoRenderer, completion: {
                    DispatchQueue.main.async {
                        self.localRenderer?.removeFromSuperview()
                        self.ourView.backgroundColor = .clear
                    }
                    DispatchQueue.main.async {
                        sender.setImage(UIImage(named: "cameraOn"), for: .normal)
                        self.cameraSwitchButton.isEnabled = false
                    }
                    self.webRTCClient?.sendData("turn camera off".data(using: .utf8)!)
                    self.isCameraOff = false
                })
            } else {
                embedView(localRenderer!, into: self.ourView)
                webRTCClient?.localVideoTrack?.isEnabled = true
                webRTCClient?.startCaptureLocalVideo(renderer: localRenderer! as! RTCVideoRenderer, cameraPosition: cameraPosition, completion: {})
                isCameraOff = true
                DispatchQueue.main.async {
                    sender.setImage(UIImage(named: "cameraOff"), for: .normal)
                    self.cameraSwitchButton.isEnabled = true
                }
                
                self.webRTCClient?.sendData("turn camera on".data(using: .utf8)!)
            }
        } else {
            videoVCMode = .videoCall
            self.viewWillAppear(false)
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    @IBAction func endCallButton(_ sender: Any) {
        webRTCClient?.sendData("opponent leave call".data(using: .utf8)!)
        endCall()
    }
    
    @IBAction func speakerOnAndOff(_ sender: UIButton) {
        if !isSpeakerOn {
            isSpeakerOn = true
            sender.setImage(UIImage(named: "speakerOn"), for: .normal)
            webRTCClient?.speakerOn()
        } else if isSpeakerOn {
            isSpeakerOn = false
            sender.setImage(UIImage(named: "speakerOff"), for: .normal)
            webRTCClient?.speakerOff()
        }
    }
    func endCall() {
        let tabbar = self.tabBarController as? MainTabBarController
        tabbar?.timer?.invalidate()
        player?.stop()
        for call in callManager.calls {
            callManager.end(call: call)
        }
        (tabBarController as? MainTabBarController)?.onCall = false
        ((tabBarController as? MainTabBarController)?.viewControllers?[0] as? CallListViewController)?.onCall = false
        if roomName != nil {
            SocketTaskManager.shared.leaveRoom(roomName: roomName!)
        }
        callManager.removeAllCalls()
        self.view.viewWithTag(10)?.removeFromSuperview()
        self.view.viewWithTag(11)?.removeFromSuperview()
        webRTCClient?.removeThracks()
        webRTCClient?.peerConnection?.close()
        self.navigationController?.popViewController(animated: false)
    }
    
    func playSound() {
        if !isCallHandled! {
            if let soundURL = Bundle.main.url(forResource: "ringback", withExtension: "mp3") {
                do {
                    player = try AVAudioPlayer(contentsOf: soundURL)
                    player?.prepareToPlay()
                }
                catch {
                    print(error)
                }
            } else {
                print("Unable to locate audio file")
            }
            player?.play()
            player?.volume = 1
            player?.delegate = self
        }
    }
    
    func endCallFromCallkitView(call: Call) {
        webRTCClient?.sendData("opponent leave call".data(using: .utf8)!)
        SocketTaskManager.shared.leaveRoom(roomName: call.roomName)
        self.view.viewWithTag(10)?.removeFromSuperview()
        self.view.viewWithTag(11)?.removeFromSuperview()
        webRTCClient?.removeThracks()
        webRTCClient?.peerConnection?.close()
        self.navigationController?.popViewController(animated: false)
    }
    
    
    func removeFromLocalrenderer() {
        self.view.viewWithTag(123)?.removeFromSuperview()
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        localRenderer!.tag = 11
        localRenderer?.backgroundColor = .clear
        ourView.backgroundColor = .clear
        self.view.viewWithTag(11)?.removeFromSuperview()
        if cameraPosition == .front {
            webRTCClient?.sendData("turn camera to back".data(using: .utf8)!)
            cameraPosition = .back
            self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer! as! RTCVideoRenderer, cameraPosition: cameraPosition, completion: {
                DispatchQueue.main.async {
                    self.ourView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    self.embedView(self.localRenderer!, into: self.ourView)
                }
            })
        } else {
            webRTCClient?.sendData("turn camera to front".data(using: .utf8)!)
            cameraPosition = .front
            self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer! as! RTCVideoRenderer, cameraPosition: cameraPosition, completion: {
                DispatchQueue.main.async {
                    self.ourView.transform = CGAffineTransform(scaleX: -1, y: 1)
                    self.embedView(self.localRenderer!, into: self.ourView)
                }
            })
        }
    }
    
    @IBAction func speakerOnOff(_ sender: UIButton) {
        if isMicrophoneOn {
            webRTCClient?.muteAudio()
            sender.setImage(UIImage(named: "micOff"), for: .normal)
            webRTCClient?.sendData("turn off microphone".data(using: .utf8)!)
        } else {
            sender.setImage(UIImage(named: "micOn"), for: .normal)
            webRTCClient?.sendData("turn on microphone".data(using: .utf8)!)
            webRTCClient?.unmuteAudio()
        }
        isMicrophoneOn = !isMicrophoneOn
    }
    
    func turnOffOtherSideCamera() {
        webRTCClient?.remoteVideoTrack?.isEnabled = false
        DispatchQueue.main.async {
            self.remoteRenderer?.backgroundColor = .clear
        }
    }
    
    func turnOnOtherSideCamera() {
        webRTCClient?.remoteVideoTrack?.isEnabled = true
    }
    
    func closeAll() {
        for call in callManager.calls {
            callManager.end(call: call)
        }
        callManager.removeAllCalls()
        webRTCClient?.removeThracks()
        DispatchQueue.main.async {
            self.view.viewWithTag(10)?.removeFromSuperview()
            self.view.viewWithTag(11)?.removeFromSuperview()
            self.navigationController?.popViewController(animated: false)
        }
    }
    
    func startCall(_ callText: String) {
        let label = UILabel()
        label.tag = 6
        label.text = callText
        label.textColor = UIColor(named: "color")
        label.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(label)
        label.heightAnchor.constraint(equalToConstant: 100).isActive = true
        label.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 1).isActive = true
        label.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1).isActive = true
        label.isUserInteractionEnabled = true
        label.anchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, width: 0, height: 100)
    }
    
    func handleAnswer() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.view.viewWithTag(6)?.removeFromSuperview()
        })
        player?.stop()
    }
    
    func handleCallConnect() {
        player?.stop()
        if self.videoVCMode == .audioCall {
            self.webRTCClient?.speakerOff()
            self.isSpeakerOn = false
        } else {
            self.isSpeakerOn = true
            self.webRTCClient?.speakerOn()
        }
    }
    
    func handleOffer(roomName: String) {
        self.roomName = roomName
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":view]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":view]))
        containerView.layoutIfNeeded()
    }
}

//MARK: Extensions
extension VideoViewController: WebRTCDelegate {
    func removeView() {
        self.handleAnswer()
    }
}
