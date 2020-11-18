//
//  ConfigureChannelMessagesViewController.swift
//  Messenger
//
//  Created by Employee3 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import AVKit

class ConfigureChannelMessagesViewController {
    var vc: ChannelMessagesViewController!
    var mainRouter: MainRouter!
    
    init(mainRouter: MainRouter) {
        vc = mainRouter.channelMessagesViewController
    }
    
    func configureTableView(indexPath: IndexPath) -> UITableViewCell {
        let tap = UILongPressGestureRecognizer(target: self, action: #selector(handleTap))
        let tapOnImage = CustomTapGesture(target: self, action: #selector(handleTapOnImage), indexPath: indexPath)
        let tapOnVideo = CustomTapGesture(target: self, action: #selector(handleTapOnVideo), indexPath: indexPath)
        if vc.channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            if vc.channelMessages.array![indexPath.row].type == MessageType.image.rawValue {
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SentMediaMessageTableViewCell
                cell.configureSendImageMessageTableViewCellInChannel(vc.channelMessages.array![indexPath.row], tap, isPreview: vc.isPreview, channelInfo: vc.channelInfo, tapOnImage: tapOnImage, tmpImage: vc.sendImageTmp)
                return cell
            } else if vc.channelMessages.array![indexPath.row].type == MessageType.video.rawValue  {
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: "sendImageMessage", for: indexPath) as! SentMediaMessageTableViewCell
                cell.configureSendVideoMessageTableViewCellInChannel(vc.channelMessages.array![indexPath.row], vc.channelInfo, tap, isPreview: vc.isPreview, tapOnVideo: tapOnVideo, thumbnail: vc.sendThumbnail)
                return cell
            } else {
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: "sendMessageCell", for: indexPath) as! SentMessageTableViewCell
                cell.configureSendMessageTableViewCellInChannel(vc.channelInfo, vc.channelMessages.array![indexPath.row], tap, isPreview: vc.isPreview)
                return cell
            }
        } else {
            if vc.channelMessages.array![indexPath.row].type == MessageType.image.rawValue {
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: "receiveImageMessage", for: indexPath) as! RecievedMediaMessageTableViewCell
                cell.configureRecieveImageMessageTableViewCellInChannel(vc.channelInfo, isPreview: vc.isPreview, message: vc.channelMessages.array![indexPath.row], tapOnImage: tapOnImage)
                return cell
            } else if vc.channelMessages.array![indexPath.row].type == MessageType.video.rawValue {
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: "receiveImageMessage", for: indexPath) as! RecievedMediaMessageTableViewCell
                cell.configureRecieveVideoMessageTableViewCellInChannel(vc.channelInfo, tap, message: vc.channelMessages.array![indexPath.row], isPreview: vc.isPreview, tapOnVideo: tapOnVideo)
                return cell
            } else {
                let cell = vc.tableView.dequeueReusableCell(withIdentifier: "receiveMessageCell", for: indexPath) as! RecievedMessageTableViewCell
                cell.configureRecieveMessageTableViewCellInChannel(vc.channelMessages.array![indexPath.row], vc.channelInfo, vc.isPreview)
                return cell
            }
        }
    }
    
    @objc func handleTap(gestureReconizer: UILongPressGestureRecognizer) {
        if gestureReconizer.state == UIGestureRecognizer.State.began {
            let touchPoint = gestureReconizer.location(in: vc.tableView)
            if let indexPath = vc.tableView.indexPathForRow(at: touchPoint) {
                let cell = vc.tableView.cellForRow(at: indexPath) as? SentMessageTableViewCell
                self.vc.showAlert(title: nil, message: nil, buttonTitle1: "delete".localized(), buttonTitle2: "edit".localized(), buttonTitle3: "cancel".localized()) {
                    self.vc.viewModel?.deleteChannelMessageBySender(ids: [cell?.id ?? ""], completion: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.vc.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                            }
                        }
                    })
                } completion2: {
                    self.vc.mode = .edit
                    self.vc.sendButton.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
                    self.vc.indexPath = indexPath
                    self.vc.inputTextField.text = cell?.messageLabel.text
                } completion3: {}
            }
        }
    }
    
    func heightForRowAt(indexPath: IndexPath) -> CGFloat {
        let size: CGSize?
        let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
        if (vc.channelMessages.array![indexPath.row].senderId == SharedConfigs.shared.signedUser?.id) {
            size = CGSize(width: self.vc.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: vc.channelMessages.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            if vc.channelMessages.array![indexPath.row].type == MessageType.text.rawValue {
                return frame.height + 52
            }  else if vc.channelMessages.array![indexPath.row].type == MessageType.call.rawValue {
                return 80
            } else if vc.channelMessages.array![indexPath.row].type == MessageType.image.rawValue || vc.channelMessages.array![indexPath.row].type == MessageType.video.rawValue {
                return frame.height + 230
            }
        } else {
            size = CGSize(width: self.vc.view.frame.width * 0.6 - 100, height: 1500)
            let frame = NSString(string: vc.channelMessages.array![indexPath.row].text ?? "").boundingRect(with: size!, options: options, attributes: nil, context: nil)
            if vc.channelMessages.array![indexPath.row].type == MessageType.text.rawValue {
                return frame.height + 30
            } else if vc.channelMessages.array![indexPath.row].type == MessageType.call.rawValue {
                return 80
            } else if vc.channelMessages.array![indexPath.row].type == MessageType.image.rawValue || vc.channelMessages.array![indexPath.row].type == MessageType.video.rawValue {
                return frame.height + 230 
            }
        }
        return UITableView.automaticDimension
    }
    
    func setupInputComponents() {
        vc.messageInputContainerView.addSubview(vc.inputTextField)
        vc.messageInputContainerView.addSubview(vc.sendButton)
        vc.messageInputContainerView.layer.borderWidth = 1
        vc.messageInputContainerView.layer.borderColor = UIColor(white: 0.5, alpha: 0.5).cgColor
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
        uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: vc, action: #selector(vc.handleUploadTap1)))
        vc.messageInputContainerView.addSubview(uploadImageView)
        uploadImageView.leftAnchor.constraint(equalTo: vc.messageInputContainerView.leftAnchor).isActive = true
        uploadImageView.centerYAnchor.constraint(equalTo: vc.messageInputContainerView.centerYAnchor).isActive = true
        uploadImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        uploadImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        vc.inputTextField.translatesAutoresizingMaskIntoConstraints = false
        vc.inputTextField.rightAnchor.constraint(equalTo: vc.view.rightAnchor, constant: -37).isActive = true
        vc.inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 5).isActive = true
        vc.inputTextField.bottomAnchor.constraint(equalTo: vc.messageInputContainerView.bottomAnchor, constant: 0).isActive = true
        vc.inputTextField.heightAnchor.constraint(equalToConstant: 48).isActive = true
        vc.inputTextField.isUserInteractionEnabled = true
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
    
    @objc func handleTapOnImage(gestureReconizer: CustomTapGesture) {
        let viewUnderImageView = UIView()
        viewUnderImageView.tag = 23
        viewUnderImageView.backgroundColor = UIColor.white
        self.vc.view.addSubview(viewUnderImageView)
        viewUnderImageView.translatesAutoresizingMaskIntoConstraints = false
        viewUnderImageView.leadingAnchor.constraint(equalTo: self.vc.view.leadingAnchor, constant: 0).isActive = true
        viewUnderImageView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.vc.view.trailingAnchor, multiplier: 1).isActive = true
        viewUnderImageView.bottomAnchor.constraint(equalTo: self.vc.view.bottomAnchor, constant: 0).isActive = true
        viewUnderImageView.topAnchor.constraint(equalTo: self.vc.view.topAnchor, constant: 0).isActive = true
        let imageView = UIImageView()
        viewUnderImageView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: self.vc.view.leadingAnchor, constant: 0).isActive = true
        imageView.trailingAnchor.constraint(equalToSystemSpacingAfter: self.vc.view.trailingAnchor, multiplier: 1).isActive = true
        imageView.centerYAnchor.constraint(equalTo: self.vc.view.centerYAnchor).isActive = true
        imageView.topAnchor.constraint(equalTo: self.vc.view.topAnchor, constant: 80).isActive = true
        ImageCache.shared.getImage(url: vc.channelMessages.array?[gestureReconizer.indexPath.row].image?.imageURL ?? "", id: vc.channelMessages.array?[gestureReconizer.indexPath.row]._id ?? "", isChannel: true) { (image) in
            imageView.image = image
        }
        let closeButton = UIButton()
        closeButton.setImage(UIImage(named: "closeColor"), for: .normal)
        closeButton.addTarget(self, action: #selector(handleCloseAction), for: .touchUpInside)
        viewUnderImageView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.trailingAnchor.constraint(equalTo: self.vc.view.trailingAnchor, constant: -10).isActive = true
        closeButton.topAnchor.constraint(equalTo: self.vc.view.topAnchor, constant: 30).isActive = true
    }
    
    @objc func handleCloseAction() {
        self.vc.view.viewWithTag(23)?.removeFromSuperview()
    }
    
    @objc func handleTapOnVideo(gestureReconizer: CustomTapGesture) {
        VideoCache.shared.getVideo(videoUrl: vc.channelMessages.array?[gestureReconizer.indexPath.row].video ?? "") { (videoURL) in
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
            }
        }
    }
    
    func setLineOnHeaderView()  {
        let line = UIView()
        vc.headerView.addSubview(line)
        line.translatesAutoresizingMaskIntoConstraints = false
        line.rightAnchor.constraint(equalTo: self.vc.view.rightAnchor, constant: 0).isActive = true
        line.bottomAnchor.constraint(equalTo: vc.headerView.bottomAnchor, constant: 0).isActive = true
        line.widthAnchor.constraint(equalToConstant: self.vc.view.frame.width).isActive = true
        line.heightAnchor.constraint(equalToConstant: 1).isActive = true
        line.backgroundColor = UIColor(red: 209/255, green: 209/255, blue: 209/255, alpha: 1)
    }
    
    func addConstraints() {
        vc.view.addSubview(vc.messageInputContainerView)
        vc.messageInputContainerView.translatesAutoresizingMaskIntoConstraints = false
        vc.bottomConstraint = vc.messageInputContainerView.bottomAnchor.constraint(equalTo: vc.view.bottomAnchor, constant: 0)
        vc.bottomConstraint?.isActive = true
        vc.messageInputContainerView.rightAnchor.constraint(equalTo: vc.view.rightAnchor, constant: 1).isActive = true
        vc.messageInputContainerView.leftAnchor.constraint(equalTo: vc.view.leftAnchor, constant: -1).isActive = true
        vc.messageInputContainerView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        vc.messageInputContainerView.isUserInteractionEnabled = true
        vc.messageInputContainerView.bottomAnchor.constraint(equalTo: vc.view.safeAreaLayoutGuide.bottomAnchor, constant: 0).isActive = true
        vc.tableViewBottomConstraint.constant = 48
        vc.sendButton.addTarget(vc, action: #selector(vc.sendMessage), for: .touchUpInside)
    }
    
    @objc func deleteMessages() {
        if vc.arrayOfSelectedMesssgae.count > 0 {
            vc.showAlertBeforeDeleteMessage()
        } else {
            self.vc.check = !self.vc.check
            self.vc.isPreview = self.vc.check
            UIView.setAnimationsEnabled(false)
            self.vc.tableView.beginUpdates()
            self.vc.tableView.reloadData()
            self.vc.tableView.endUpdates()
            self.vc.inputTextField.placeholder = "enter_message".localized()
            self.vc.universalButton.setTitle("edit".localized(), for: .normal)
            self.vc.tableView.allowsMultipleSelection = false
            self.vc.tableView.allowsSelection = false
            self.vc.sendButton.isHidden = false
            self.removeDeleteButton()
        }
    }
    
    func removeDeleteButton()  {
        DispatchQueue.main.async {
            self.vc.view.viewWithTag(333)?.removeFromSuperview()
        }
    }
    
    func setDeleteMessageButton()  {
        vc.inputTextField.addSubview(vc.deleteMessageButton)
        vc.deleteMessageButton.translatesAutoresizingMaskIntoConstraints = false
        vc.deleteMessageButton.setTitle("delete".localized(), for: .normal)
        vc.deleteMessageButton.setTitleColor(.white, for: .normal)
        vc.deleteMessageButton.tag = 333
        vc.deleteMessageButton.titleLabel?.font = UIFont.systemFont(ofSize: 20.0)
        vc.deleteMessageButton.backgroundColor = UIColor(red: 128/255, green: 94/255, blue: 250/255, alpha: 1)
        vc.deleteMessageButton.rightAnchor.constraint(equalTo: vc.view.rightAnchor, constant: 0).isActive = true
        vc.deleteMessageButton.leftAnchor.constraint(equalTo: vc.messageInputContainerView.leftAnchor, constant: 0).isActive = true
        vc.deleteMessageButton.bottomAnchor.constraint(equalTo: vc.messageInputContainerView.bottomAnchor, constant: 0).isActive = true
        vc.deleteMessageButton.heightAnchor.constraint(equalToConstant: 48).isActive = true
        vc.deleteMessageButton.addTarget(self, action: #selector(deleteMessages), for: .touchUpInside)
    }
    
    func setView(_ str: String) {
        if vc.channelMessages.array?.count == 0 {
            DispatchQueue.main.async {
                let noResultView = UIView(frame: self.vc.view.frame)
                self.vc.tableView.addSubview(noResultView)
                noResultView.tag = 26
                noResultView.backgroundColor = UIColor(named: "imputColor")
                let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.vc.view.frame.width * 0.8, height: 50))
                noResultView.addSubview(label)
                label.translatesAutoresizingMaskIntoConstraints = false
                label.centerYAnchor.constraint(equalTo: self.vc.view.centerYAnchor, constant: 0).isActive = true
                label.centerXAnchor.constraint(equalTo: self.vc.view.centerXAnchor, constant: 0).isActive = true
                label.center = self.vc.view.center
                label.text = str
                label.textColor = .lightGray
                label.textAlignment = .center
            }
        } else {
            removeView()
        }
    }
    
    func removeView() {
        DispatchQueue.main.async {
            self.vc.view.viewWithTag(26)?.removeFromSuperview()
        }
    }
}
