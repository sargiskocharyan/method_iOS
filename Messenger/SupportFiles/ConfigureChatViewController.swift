//
//  ConfigureChatViewController.swift
//  Messenger
//
//  Created by Employee3 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
import UIKit
import Photos
import AVKit

class ConfigureChatViewController {
    var mainRouter: MainRouter!
    var vc: ChatViewController!
    let sendMessageCellIdentifier = "sendMessageCell"
    let receiveMessageCellIdentifier = "receiveMessageCell"
    init (mainRouter: MainRouter) {
        self.mainRouter = mainRouter
        vc = mainRouter.chatViewController
    }
    
    func setBigImageView(_ gestureReconizer: CustomTapGesture, message: Message?) {
        let viewUnderImageView = UIView()
        viewUnderImageView.tag = 23
        vc.navigationController?.navigationBar.isHidden = true
        viewUnderImageView.backgroundColor = UIColor.white
        vc.view.addSubview(viewUnderImageView)
        viewUnderImageView.translatesAutoresizingMaskIntoConstraints = false
        viewUnderImageView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0).isActive = true
        viewUnderImageView.trailingAnchor.constraint(equalToSystemSpacingAfter: vc.view.trailingAnchor, multiplier: 1).isActive = true
        viewUnderImageView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0).isActive = true
        viewUnderImageView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 0).isActive = true
        let imageView = UIImageView()
        viewUnderImageView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: vc.view.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalToSystemSpacingAfter: vc.view.trailingAnchor, multiplier: 1).isActive = true
        imageView.centerYAnchor.constraint(equalTo: vc.view.centerYAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 80).isActive = true
        ImageCache.shared.getImage(url: message?.image?.imageURL ?? "", id: message?._id ?? "", isChannel: true) { (image) in
            DispatchQueue.main.async {
                imageView.image = image
            }
        }
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "closeColor"), for: .normal)
        closeButton.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
        viewUnderImageView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.trailingAnchor.constraint(equalTo: vc.view.trailingAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: vc.view.topAnchor, constant: 30).isActive = true
    }
    
    @objc func handleCloseAction(view: UIView, vc: ChatViewController) {
        view.viewWithTag(23)?.removeFromSuperview()
        self.vc.navigationController?.navigationBar.isHidden = false
    }
    
    func setLabel(text: String, view: UIView, superView: UIView) {
        let label = UILabel()
        label.text = text
        label.tag = 13
        label.textAlignment = .center
        label.textColor = .darkGray
        superView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0).isActive = true
        label.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0).isActive = true
        label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
    }
    
    func removeLabel() {
        vc.view.viewWithTag(13)?.removeFromSuperview()
    }
    
    func tappedSendMessageCell(_ indexPath: IndexPath) {
        let cell = vc.tableView.cellForRow(at: indexPath) as? SentMessageTableViewCell
        self.vc.showAlert(title: nil, message: nil, buttonTitle1: "delete".localized(), buttonTitle2: "edit".localized(), buttonTitle3: "cancel".localized(), completion1: {
            self.vc.viewModel?.deleteChatMessages(arrayMessageIds: [cell?.id ?? ""], completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.vc.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                }
            })
        }, completion2: {
            self.vc.mode = .edit
            self.vc.indexPath = indexPath
            self.vc.inputTextField.text = cell?.messageLabel.text
        }, completion3: nil)
    }
    
    func setupInputComponents() {
        vc.messageInputContainerView.layer.borderWidth = 1
        vc.messageInputContainerView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
        vc.messageInputContainerView.addSubview(vc.inputTextField)
        vc.messageInputContainerView.addSubview(vc.sendButton)
        vc.inputTextField.translatesAutoresizingMaskIntoConstraints = false
        vc.inputTextField.rightAnchor.constraint(equalTo: vc.view.rightAnchor, constant: -32).isActive = true
        vc.inputTextField.leftAnchor.constraint(equalTo: vc.messageInputContainerView.leftAnchor, constant: 44).isActive = true
        vc.inputTextField.bottomAnchor.constraint(equalTo: vc.messageInputContainerView.bottomAnchor, constant: 0).isActive = true
        vc.inputTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        vc.inputTextField.isUserInteractionEnabled = true
        vc.sendButton.translatesAutoresizingMaskIntoConstraints = false
        vc.sendButton.rightAnchor.constraint(equalTo: vc.messageInputContainerView.rightAnchor, constant: -10).isActive = true
        vc.sendButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        vc.sendButton.topAnchor.constraint(equalTo: vc.messageInputContainerView.topAnchor, constant: 10).isActive = true
        vc.sendButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        vc.sendButton.isUserInteractionEnabled = true
        let uploadImageView = UIImageView()
        uploadImageView.isUserInteractionEnabled = true
        uploadImageView.image = UIImage(named: "upload_image_icon")
        uploadImageView.translatesAutoresizingMaskIntoConstraints = false
        vc.messageInputContainerView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: vc.messageInputContainerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: vc.messageInputContainerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 42).isActive = true
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: vc, action: #selector(vc.handleUploadTap)))
    }
    
    func getImage() {
        ImageCache.shared.getImage(url: vc.avatar ?? "", id: vc.id!, isChannel: false) { (userImage) in
            self.vc.image = userImage
        }
    }

    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        vc.tabbar?.videoVC?.isCallHandled = false
        if !vc.tabbar!.onCall {
            vc.tabbar!.handleCallClick(id: vc.id!, name: vc.name ?? vc.username ?? "", mode: .videoCall)
            vc.tabbar!.callsVC?.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: vc.id!)
        } else {
            vc.tabbar!.handleClickOnSamePerson()
        }
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        let size: CGSize?
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if (vc.allMessages?.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id) {
            size = CGSize(width: self.vc.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: vc.allMessages?.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            if vc.allMessages?.array![indexPath.row].type == "text" {
                return frame.height + 52
            }  else if vc.allMessages?.array![indexPath.row].type == "call" {
                return 80
            } else if vc.allMessages?.array![indexPath.row].type == "image" || vc.allMessages?.array![indexPath.row].type == "video" {
                return frame.height + 230
            }
        } else {
            size = CGSize(width: self.vc.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: vc.allMessages?.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            if vc.allMessages?.array![indexPath.row].type == "text" {
                return frame.height + 30
            } else if vc.allMessages?.array![indexPath.row].type == "call" {
                return 80
            } else if vc.allMessages?.array![indexPath.row].type == "image" || vc.allMessages?.array![indexPath.row].type == "video" {
                return frame.height + 230 //UITableView.automaticDimension
            }
        }
        return UITableView.automaticDimension
    }
    
    func tappedSendImageMessageCell(_ indexPath: IndexPath) {
        let cell = vc.tableView.cellForRow(at: indexPath) as? SentMediaMessageTableViewCell
        self.vc.showAlert(title: nil, message: nil, buttonTitle1: "delete".localized(), buttonTitle2: "cancel".localized(), buttonTitle3: nil, completion1: {
            self.vc.viewModel?.deleteChatMessages(arrayMessageIds: [cell?.id ?? ""], completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.vc.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                }
            })
        }, completion2: nil, completion3: nil)
    }
    
    func tappedSendCallCell(_ indexPath: IndexPath) {
        let cell = vc.tableView.cellForRow(at: indexPath) as? SentCallTableViewCell
        self.vc.showAlert(title: nil, message: nil, buttonTitle1: "delete".localized(), buttonTitle2: "cancel".localized(), buttonTitle3: nil, completion1: {
            self.vc.viewModel?.deleteChatMessages(arrayMessageIds: [cell?.id ?? ""], completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.vc.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                }
            })
        }, completion2: nil, completion3: nil)
    }
    
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    @objc func handleTap1(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureReconizer.location(in: vc.tableView)
            if let indexPath = vc.tableView.indexPathForRow(at: touchPoint) {
                if vc.allMessages!.array![indexPath.row].type == "text" {
                    self.tappedSendMessageCell(indexPath)
                } else if vc.allMessages!.array![indexPath.row].type == "image" {
                    tappedSendImageMessageCell(indexPath)
                } else {
                    tappedSendCallCell(indexPath)
                }
            }
        }
    }
    
    func configureSentMessageCell(message: Message, longTapGesture: UILongPressGestureRecognizer, tapOnImage: UITapGestureRecognizer, tapOnVideo: UITapGestureRecognizer, indexPath: IndexPath) -> UITableViewCell {
        if message.type == "text" {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: sendMessageCellIdentifier, for: indexPath) as! SentMessageTableViewCell
            cell.configureSendMessageTableViewCell(message: message, statuses: vc.allMessages!.statuses ?? [], longTapGesture)
            return cell
        } else if message.type == "call" {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: "sendCallCell", for: indexPath) as! SentCallTableViewCell
            cell.configureSendCallTableViewCell(vc.allMessages!.array![indexPath.row], longTapGesture)
            return cell
        } else if message.type == "image" {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SentMediaMessageTableViewCell
            cell.configureSendImageMessageTableViewCell(vc.allMessages!.array![indexPath.row], longTapGesture, tapOnImage, tmpImage: vc.sendImageTmp)
            return cell
        } else {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SentMediaMessageTableViewCell
            cell.configureSendVideoMessageTableViewCell(message, longTapGesture, tapOnVideo, thumbnail: vc.sendThumbnail)
            return cell
        }
    }
    
    func configureReceivedMessageCell(message: Message, longTapGesture: UILongPressGestureRecognizer, tapOnImage: UITapGestureRecognizer, tapOnVideo: UITapGestureRecognizer, indexPath: IndexPath) -> UITableViewCell {
        if message.type == "text" {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: self.receiveMessageCellIdentifier, for: indexPath) as! RecievedMessageTableViewCell
            cell.configureRecieveMessageTableViewCell(longTapGesture, vc.allMessages!.array![indexPath.row], image: self.vc.image!)
            return cell
        }  else if vc.allMessages?.array![indexPath.row].type == "call" {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: "receiveCallCell", for: indexPath) as! RecievedCallTableViewCell
            cell.configureRecieveCallTableViewCell(vc.allMessages!.array![indexPath.row], image: self.vc.image!, longTapGesture)
            return cell
        } else if vc.allMessages?.array![indexPath.row].type == "image" {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: "receiveImageMessage", for: indexPath) as! RecievedMediaMessageTableViewCell
            cell.configureRecieveImageMessageTableViewCell(vc.allMessages!.array![indexPath.row], longTapGesture, tapOnImage, image: self.vc.image!)
            return cell
        } else {
            let cell = vc.tableView.dequeueReusableCell(withIdentifier: "receiveImageMessage", for: indexPath) as! RecievedMediaMessageTableViewCell
            cell.configureRecieveVideoMessageTableViewCell(vc.allMessages!.array![indexPath.row], longTapGesture, tapOnVideo)
            return cell
        }
    }
    
    @objc func handleTapOnImage(gestureReconizer: CustomTapGesture) {
        self.vc.navigationController?.navigationBar.isHidden = true
        setBigImageView(gestureReconizer, message: vc.allMessages!.array![gestureReconizer.indexPath.row])
    }
    
    
    
    @objc func handleTapOnVideo(gestureReconizer: CustomTapGesture) {
        VideoCache.shared.getVideo(videoUrl: vc.allMessages?.array?[gestureReconizer.indexPath.row].video ?? "") { (videoURL) in
            if let videoURL = videoURL {
                DispatchQueue.main.async {
                    try! AVAudioSession.sharedInstance().setCategory(.playback)
                    let player = AVPlayer(url: videoURL)
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.vc.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.vc.showErrorAlert(title: "error".localized(), errorMessage: "please_try_later".localized())
                }
            }
        }
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(vc!, selector: #selector(vc.handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(vc!, selector: #selector(vc.handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func configureTableView(indexPath: IndexPath) -> UITableViewCell {
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap1(gestureReconizer:)))
        let tapOnImage = CustomTapGesture(target: self, action: #selector(handleTapOnImage), indexPath: indexPath)
        let tapOnVideo = CustomTapGesture(target: self, action: #selector(handleTapOnVideo), indexPath: indexPath)
        if vc.allMessages?.array?[indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            return configureSentMessageCell(message: vc.allMessages!.array![indexPath.row], longTapGesture: tap, tapOnImage: tapOnImage, tapOnVideo: tapOnVideo, indexPath: indexPath)
        } else {
            return configureReceivedMessageCell(message: vc.allMessages!.array![indexPath.row], longTapGesture: tap, tapOnImage: tapOnImage, tapOnVideo: tapOnVideo, indexPath: indexPath)
        }
    }
    
    func handleFinishImagePicking(info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            setSendImageView(image: selectedImage)
            vc.sendImage = selectedImage
            vc.sendImageTmp = selectedImage
            vc.dismiss(animated: true, completion: nil)
            return
        }
        if let videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL {
            print(videoURL)
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
                if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                    print("creating 2")
                    do {
                        self.vc.sendAsset = AVURLAsset(url: videoURL as URL , options: nil)
                        _ = AVAsset(url: videoURL as URL)
                        let imgGenerator = AVAssetImageGenerator(asset: self.vc.sendAsset!)
                        imgGenerator.appliesPreferredTrackTransform = true
                        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                        let thumbnail = UIImage(cgImage: cgImage)
                        DispatchQueue.main.async {
                            self.vc.sendThumbnail = thumbnail
                            self.setSendImageView(image: thumbnail)
                        }
                    } catch let error {
                        print("*** Error: \(error.localizedDescription)")
                    }
                }
                
            })
        }
        vc.dismiss(animated: true, completion: nil)
    }
    
    func setTitle() {
        if vc.name != nil {
            self.vc.title = vc.name
        } else if vc.username != nil {
            self.vc.title = vc.username
        } else {
            self.vc.title = "dynamics_user".localized()
        }
    }
    
    func addConstraints() {
        vc.view.addSubview(vc.messageInputContainerView)
        vc.messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        vc.bottomConstraint = vc.messageInputContainerView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0)
        vc.bottomConstraint?.isActive = true
        vc.messageInputContainerView.rightAnchor.constraint(equalTo: vc.view.rightAnchor, constant: 0).isActive = true
        vc.messageInputContainerView.leftAnchor.constraint(equalTo: vc.view.leftAnchor, constant: 0).isActive = true
        vc.messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        vc.messageInputContainerView.isUserInteractionEnabled = true
        vc.messageInputContainerView.bottomAnchor.constraint(equalTo: self.vc.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        vc.sendButton.addTarget(vc, action: #selector(vc.sendMessage), for: .touchUpInside)
    }
    
    func setSendImageView(image: UIImage) {
        let viewOfImage = UIView()
        vc.tableView.addSubview(viewOfImage)
        viewOfImage.tag = 14
        viewOfImage.translatesAutoresizingMaskIntoConstraints = false
        viewOfImage.leftAnchor.constraint(equalTo: self.vc.tableView.leftAnchor, constant: 10).isActive = true
        viewOfImage.bottomAnchor.constraint(equalTo: vc.messageInputContainerView.topAnchor, constant: -5).isActive = true
        viewOfImage.widthAnchor.constraint(equalToConstant: 100).isActive = true
        viewOfImage.heightAnchor.constraint(equalToConstant: 100).isActive = true
        let sendingImage = UIImageView()
        viewOfImage.addSubview(sendingImage)
        sendingImage.translatesAutoresizingMaskIntoConstraints = false
        sendingImage.leftAnchor.constraint(equalTo: self.vc.tableView.leftAnchor, constant: 10).isActive = true
        sendingImage.bottomAnchor.constraint(equalTo: viewOfImage.bottomAnchor, constant: 0).isActive = true
        sendingImage.topAnchor.constraint(equalTo: viewOfImage.topAnchor, constant: 0).isActive = true
        sendingImage.rightAnchor.constraint(equalTo: viewOfImage.rightAnchor, constant: 0).isActive = true
        sendingImage.clipsToBounds = true
        sendingImage.image = image
        sendingImage.layer.cornerRadius = 20
    }
    
    func removeSendImageView() {
        self.vc.view.viewWithTag(14)?.removeFromSuperview()
    }

}
