//
//  VideoViewController.swift
//  Messenger
//
//  Created by Employee1 on 7/14/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import WebRTC

protocol VideoViewControllerProtocol: class {
    func handleClose()
}

class VideoViewController: UIViewController {
    var roomName: String?
    var webRTCClient: WebRTCClient?
    weak var delegate: VideoViewControllerProtocol?
    @IBOutlet weak var ourView: UIView!
    let callManager = AppDelegate.shared.callManager
    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func endCallButton(_ sender: Any) {
        //
//        if roomName == nil {
            for call in callManager.calls {
                callManager.end(call: call)
            }
             
            callManager.removeAllCalls()
            self.view.viewWithTag(10)?.removeFromSuperview()
            self.view.viewWithTag(11)?.removeFromSuperview()
            //            SocketTaskManager.shared.leaveRoom(roomName: roomName!)
               webRTCClient?.removeThracks()
            webRTCClient?.peerConnection?.close()
            //            webRTCClient?.peerConnection!.remove((webRTCClient?.stream)!)
          //  delegate?.handleClose()
            
            self.navigationController?.popViewController(animated: false)
            //            webRTCClient = nil
            
//        } else {
//
//
//        }

        // self.view.backgroundColor = .white
        //        webRTCClient?.peerConnection = nil
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        // navigationController?.navigationBar.isHidden = true
        //        self.webRTCClient?.delegate = self
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
        remoteRenderer.tag = 10
        localRenderer.tag = 11
        self.webRTCClient?.startCaptureLocalVideo(renderer: localRenderer)
        self.webRTCClient?.renderRemoteVideo(to: remoteRenderer)
        if let localVideoView = self.ourView {
            self.embedView(localRenderer, into: localVideoView)
        }
        self.embedView(remoteRenderer, into: self.view)
        self.view.sendSubviewToBack(remoteRenderer)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ROOMNAME \(roomName)")
        print(webRTCClient)
//        webRTCClient?.delegate = self
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    func startCall() {
        print("startCall")
        let label = UILabel()
        label.tag = 6
        label.text = "Calling..."
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = true
        view.addSubview(label)
        label.heightAnchor.constraint(equalToConstant: 100).isActive = true
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
    
    func handleOffer(roomName: String) {
        print("handleOffer")
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
//extension VideoViewController: WebRTCClientDelegate {
//    func webRTCClient(_ client: WebRTCClient, didReceiveData data: Data) {
//        DispatchQueue.main.async {
//            let message = String(data: data, encoding: .utf8) ?? "(Binary: \(data.count) bytes)"
//            let alert = UIAlertController(title: "Message from WebRTC", message: message, preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
//            self.present(alert, animated: true, completion: nil)
//        }
//    }
//
//    func webRTCClient(_ client: WebRTCClient, didDiscoverLocalCandidate candidate: RTCIceCandidate) {
//        print("discovered local candidate")
//    }
//
//    func webRTCClient(_ client: WebRTCClient, didChangeConnectionState state: RTCIceConnectionState) {
//        if state == .closed {
//            if roomName != nil {
//                for call in callManager.calls {
//                    callManager.end(call: call)
//                }
//                callManager.removeAllCalls()
//                webRTCClient?.removeThracks()
//                SocketTaskManager.shared.leaveRoom(roomName: roomName!)
//                roomName = nil
//                webRTCClient = nil
//                 self.delegate?.handleClose()
//                DispatchQueue.main.async {
//                    self.view.viewWithTag(10)?.removeFromSuperview()
//                    self.view.viewWithTag(11)?.removeFromSuperview()
//                    self.navigationController?.popViewController(animated: false)
//                }
//
//            }
//        }
//        print(state)
//        print("did Change Connection State")
//    }
//}
