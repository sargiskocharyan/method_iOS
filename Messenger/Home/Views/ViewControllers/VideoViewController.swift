//
//  VideoViewController.swift
//  Messenger
//
//  Created by Employee1 on 7/14/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import WebRTC

//class VideoViewController: UIViewController {
//
//    @IBOutlet private weak var localVideoView: UIView?
//    private let webRTCClient: WebRTCClient?
//
////    init(webRTCClient: WebRTCClient) {
////        self.webRTCClient = webRTCClient
////        super.init(nibName: String(describing: VideoViewController.self), bundle: Bundle.main)
////    }
//
//    @available(*, unavailable)
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//
////    override func viewDidLoad() {
////        super.viewDidLoad()
////
////        #if arch(arm64)
////            // Using metal (arm64 only)
////            let localRenderer = RTCMTLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
////            let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
////            localRenderer.videoContentMode = .scaleAspectFill
////            remoteRenderer.videoContentMode = .scaleAspectFill
////        #else
////            // Using OpenGLES for the rest
////            let localRenderer = RTCEAGLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
////            let remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
////        #endif
////
////        self.webRTCClient.startCaptureLocalVideo(renderer: localRenderer)
////        self.webRTCClient.renderRemoteVideo(to: remoteRenderer)
////
////        if let localVideoView = self.localVideoView {
////            self.embedView(localRenderer, into: localVideoView)
////        }
////        self.embedView(remoteRenderer, into: self.view)
////        self.view.sendSubviewToBack(remoteRenderer)
////    }
//
////    private func embedView(_ view: UIView, into containerView: UIView) {
////        containerView.addSubview(view)
////        view.translatesAutoresizingMaskIntoConstraints = false
////        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|",
////                                                                    options: [],
////                                                                    metrics: nil,
////                                                                    views: ["view":view]))
////
////        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|",
////                                                                    options: [],
////                                                                    metrics: nil,
////                                                                    views: ["view":view]))
////        containerView.layoutIfNeeded()
////    }
//
//    @IBAction private func backDidTap(_ sender: Any) {
//        self.dismiss(animated: true)
//    }
//}


class VideoViewController: UIViewController {
    var roomName: String?
    var webRTCClient: WebRTCClient?
    @IBOutlet weak var ourView: UIView!
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func endCallButton(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
        if roomName != nil {
            SocketTaskManager.shared.leaveRoom(roomName: roomName!)
        }
    }
    
       override func viewWillAppear(_ animated: Bool) {
           super.viewWillAppear(animated)
           tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
       }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if arch(arm64)
        // Using metal (arm64 only)
        let localRenderer = RTCMTLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCMTLVideoView(frame: self.view.frame)
        localRenderer.videoContentMode = .scaleAspectFill
        remoteRenderer.videoContentMode = .scaleAspectFill
        #else
        // Using OpenGLES for the rest
        let localRenderer = RTCEAGLVideoView(frame: self.ourView?.frame ?? CGRect.zero)
        let remoteRenderer = RTCEAGLVideoView(frame: self.view.frame)
        #endif
        self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer)
        self.webRTCClient?.renderRemoteVideo(to: remoteRenderer)
        
        if let localVideoView = self.ourView {
            self.embedView(localRenderer, into: localVideoView)
        }
        self.embedView(remoteRenderer, into: self.view)
        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    
    
    func startCall() {
        print("startCall")
        let label = UILabel()
        label.tag = 6
        label.text = "Calling..."
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(label)
        label.heightAnchor.constraint(equalToConstant: 100).isActive = true
//        label.widthAnchor.constraint(equalToConstant: 200).isActive = true
        label.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 1).isActive = true
        label.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1).isActive = true
        label.isUserInteractionEnabled = true
        label.anchor(top: nil, paddingTop: 0, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: nil, paddingRight: 0, width: 0, height: 100)
    }
    
    func handleAnswer() {
        print("handleAnswer")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            self.view.viewWithTag(6)?.removeFromSuperview()
        })
    }
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":view]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":view]))
        containerView.layoutIfNeeded()
    }
}
