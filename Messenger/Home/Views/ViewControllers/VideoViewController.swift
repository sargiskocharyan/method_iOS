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
    
    var webRTCClient: WebRTCClient?
    @IBOutlet weak var ourView: UIView!
    
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            let localRenderer = RTCEAGLVideoView(frame: self.localVideoView?.frame ?? CGRect.zero)
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
    
    private func embedView(_ view: UIView, into containerView: UIView) {
        containerView.addSubview(view)
        view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view":view]))
        containerView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view":view]))
        containerView.layoutIfNeeded()
    }
}
