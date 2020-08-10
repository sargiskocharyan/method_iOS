//
//  VideoViewController.swift
//  Messenger
//
//  Created by Employee1 on 7/14/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import WebRTC

class VideoViewController: UIViewController {
    var roomName: String?
    var webRTCClient: WebRTCClient?
    var cameraPosition = AVCaptureDevice.Position.front
    var isMicrophoneOn = true
    @IBOutlet weak var ourView: UIView!
    let callManager = AppDelegate.shared.callManager
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func endCallButton(_ sender: Any) {
        for call in callManager.calls {
            callManager.end(call: call)
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        #if arch(arm64)
        let localRenderer = RTCMTLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        #else
        let localRenderer = RTCEAGLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
        #endif
        remoteRenderer.tag = 10
        localRenderer.tag = 11
        self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer, cameraPosition: cameraPosition)
        self.webRTCClient?.renderRemoteVideo(to: remoteRenderer)
        if let localVideoView = self.ourView {
            self.embedView(localRenderer, into: localVideoView)
        }
        self.embedView(remoteRenderer, into: self.view)
        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "videoColor")
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        #if arch(arm64)
        let localRenderer = RTCMTLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
        localRenderer.videoContentMode = .scaleAspectFill
        #else
        let localRenderer = RTCEAGLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
        #endif
        localRenderer.tag = 11
        self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer, cameraPosition: cameraPosition)
        
        if cameraPosition == .front {
            cameraPosition = .back
        } else {
            cameraPosition = .front
        }
        self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer, cameraPosition: cameraPosition)
        if let localVideoView = self.ourView {
            self.view.viewWithTag(11)?.removeFromSuperview()
                   self.embedView(localRenderer, into: localVideoView)
               }
    }
    
    @IBAction func speakerOnOff(_ sender: UIButton) {
        if isMicrophoneOn {
            webRTCClient?.muteAudio()
            sender.setImage(UIImage(named: "micOff"), for: .normal)
        } else {
             sender.setImage(UIImage(named: "micOn"), for: .normal)
            webRTCClient?.unmuteAudio()
        }
        isMicrophoneOn = !isMicrophoneOn
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

