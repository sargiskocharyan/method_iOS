//
//  ChannelMessagesViewController.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import Photos
import AVKit

enum MessageMode {
    case edit
    case main
}

class ChannelMessagesViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    //MARK: @IBOutlets
    @IBOutlet weak var nameOfChannelButton: UIButton!
    @IBOutlet weak var universalButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var deleteMessagesButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    //MARK: Properties
    var mainRouter: MainRouter?
    var viewModel: ChannelMessagesViewModel?
    var viewConfigurator: ConfigureChannelMessagesViewController!
    var channelMessages: ChannelMessages = ChannelMessages(array: [], statuses: [])
    var channelInfo: ChannelInfo!
    var isPreview: Bool?
    var check: Bool!
    var arrayOfSelectedMesssgae: [String] = []
    var bottomConstraint: NSLayoutConstraint?
    var indexPath: IndexPath?
    var isLoadedMessages = false
    var mode: MessageMode!
    let viewonCell = UIView()
    let deleteMessageButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.inputColor
        return button
    }()
    let messageInputContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.inputColor
        return view
    }()
    let inputTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = ""
        return textField
    }()
    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage.init(named: "send"), for: .normal)
        return button
    }()
    var selectedImage: UIImage?
    var sendAsset: AVURLAsset?
    var sendThumbnail: UIImage?
    var sendImageTmp: UIImage?
    
    //MARK: LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()
        viewConfigurator = ConfigureChannelMessagesViewController(mainRouter: mainRouter!)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        self.getChannelMessages()
        mode = .main
        selectedImage = nil
        setObservers()
        tableView.rowHeight = UITableView.automaticDimension
//        tableView.estimatedRowHeight = 30
        isPreview = true
        check = true
        viewConfigurator.setLineOnHeaderView()
        headerView.backgroundColor = UIColor(red: 255/255, green: 255/255, blue: 255/255, alpha: 1)
        tableView.allowsSelection = false
//        tableView.allowsMultipleSelection = false
        viewonCell.tag = 12
        
        deleteMessagesButton.isHidden = true
        editButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
        navigationController?.navigationBar.isHidden = true
        nameOfChannelButton.setTitle(channelInfo?.channel?.name, for: .normal)

        inputTextField.placeholder = "enter_message".localized()
        checkChannelRole()
        setInputMessage()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }
    //MARK: Helper methods
    
    @IBAction func deleteMessages(_ sender: Any) {
        viewModel?.deleteChannelMessageBySender(ids: arrayOfSelectedMesssgae, completion: { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            }
        })
        cancel()
    }
    
    @IBAction func editMessage(_ sender: Any) {
        mode = .edit
//        sendButton.setImage(UIImage.init(systemName: "checkmark.circle.fill"), for: .normal)
        let indexPath = tableView.indexPathForSelectedRow
        self.indexPath = indexPath
        let cell = tableView.cellForRow(at: indexPath ?? IndexPath()) as? SentMessageTableViewCell
        inputTextField.text = cell?.messageLabel.text
        let _ = tableView.delegate?.tableView?(tableView!, willDeselectRowAt: indexPath ?? IndexPath())
        cancel()
    }
    
    func cancel() {
        deleteMessagesButton.isHidden = true
        editButton.isHidden = true
        arrayOfSelectedMesssgae = []
    }
    
    @objc func handleUploadTap1() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        imagePickerController.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
        return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        var selectedImageFromPicker: UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        if let selectedImage = selectedImageFromPicker {
            viewConfigurator.setSendImageView(image: selectedImage)
            self.selectedImage = selectedImage
            self.sendImageTmp = selectedImage
            dismiss(animated: true, completion: nil)
            return
        }
        if let videoURL = info["UIImagePickerControllerReferenceURL"] as? NSURL {
            PHPhotoLibrary.requestAuthorization({ (status: PHAuthorizationStatus) -> Void in
                ()
                if PHPhotoLibrary.authorizationStatus() == PHAuthorizationStatus.authorized {
                    do {
                        self.sendAsset = AVURLAsset(url: videoURL as URL , options: nil)
                        _ = AVAsset(url: videoURL as URL)
                        let imgGenerator = AVAssetImageGenerator(asset: self.sendAsset!)
                        imgGenerator.appliesPreferredTrackTransform = true
                        let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                        let thumbnail = UIImage(cgImage: cgImage)
                        self.sendThumbnail = thumbnail
                        DispatchQueue.main.async {
                            self.viewConfigurator.setSendImageView(image: thumbnail)
                        }
                    } catch let error {
                        print("*** Error: \(error.localizedDescription)")
                    }
                }
                self.dismiss(animated: true, completion: nil)
            })
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func setInputMessage() {
        if channelInfo.channel?.openMode == true && channelInfo.role != 3 {
            viewConfigurator.addConstraints()
            viewConfigurator.setupInputComponents()
        } else if channelInfo.channel?.openMode == false && (channelInfo.role == 1 || channelInfo.role == 0) {
            viewConfigurator.addConstraints()
            viewConfigurator.setupInputComponents()
        }
    }
    
    func checkChannelRole() {
        if (channelInfo.role == 0 || channelInfo.role == 1) {
            if isLoadedMessages {
                if channelMessages.array?.count != nil && channelMessages.array!.count > 0 {
                    check = true
                    universalButton.isHidden = false
                    universalButton.setTitle("edit".localized(), for: .normal)
                }
            }
        } else if channelInfo.role == 2 {
            check = false
            universalButton.isHidden = true
        } else {
            messageInputContainerView.removeFromSuperview()
            check = false
            universalButton.isHidden = false
            universalButton.setTitle("join".localized(), for: .normal)
        }
    }
    
    func getnewMessage(message: Message, _ name: String?, _ lastname: String?, _ username: String?, isSenderMe: Bool, uuid: String) {
        if message.owner == channelInfo.channel?._id {
            if message.senderId != SharedConfigs.shared.signedUser?.id {
                self.channelMessages.array?.append(message)
                self.viewConfigurator.removeView()
                self.tableView.insertRows(at: [IndexPath(row: channelMessages.array!.count - 1, section: 0)], with: .automatic)
                let indexPath = IndexPath(item: (self.channelMessages.array!.count) - 1, section: 0)
                self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
            } else {
                for i in 0..<self.channelMessages.array!.count {
                    if self.channelMessages.array![i]._id == uuid {
                        self.channelMessages.array![i] = message
                        if message.senderId == SharedConfigs.shared.signedUser?.id {
                            let ind = IndexPath(row: channelMessages.array!.count - 1, section: 0)
                            if message.type == "text" {
                                let cell = tableView.cellForRow(at: ind) as? SentMessageTableViewCell
                                cell?.readMessage.text = "sent".localized()
                            } else if message.type == "image" || message.type == "video" {
                                let cell = tableView.cellForRow(at: ind) as? SentMediaMessageTableViewCell
                                cell?.readMessageLabel.text = "sent".localized()
                            }
                        }
                    }
                }
                if message.type == MessageType.image.rawValue {
                    self.sendImageTmp = nil
                } else if message.type == MessageType.video.rawValue {
                    self.sendThumbnail = nil
                }
            }
        }
    }
    
    func prepareTableView(messageType: MessageType, uuID: String, text: String){
        self.channelMessages.array?.append(Message(call: nil, type: messageType.rawValue, _id: uuID, reciever: nil, text: text, createdAt: nil, updatedAt: nil, owner: nil, senderId: SharedConfigs.shared.signedUser?.id, image: Image(imageName: nil, imageURL: nil), video: nil))
        self.tableView.insertRows(at: [IndexPath(row: channelMessages.array!.count - 1, section: 0)], with: .automatic)
        let indexPath = IndexPath(item: (self.channelMessages.array!.count) - 1, section: 0)
        self.tableView?.scrollToRow(at: indexPath, at: .bottom, animated: true)
        let _ = IndexPath(row: channelMessages.array!.count - 1, section: 0)
    }
    
    func sendImage() {
        let sendImageCopy = self.selectedImage
        self.selectedImage = nil
        let text = inputTextField.text
        inputTextField.text = ""
        let uuId = UUID().uuidString
        prepareTableView(messageType: MessageType.image, uuID: uuId, text: text!)
        ChannelNetworkManager().sendImageInChannel(tmpImage: sendImageCopy, channelId: self.channelInfo.channel?._id ?? "", text: text!, tempUUID: uuId, boundary: uuId) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            }
        }
    }
    
    func sendVideo() {
        let sendAssetCopy = self.sendAsset
        self.sendAsset = nil
        let text = inputTextField.text
        inputTextField.text = ""
        let uuId = UUID().uuidString
        prepareTableView(messageType: MessageType.video, uuID: uuId, text: text!)
        self.viewModel?.encodeVideo(at: sendAssetCopy?.url.absoluteURL ?? URL(fileURLWithPath: "")) { (url, error) in
            if let url = url {
                do {
                    let data = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.viewModel?.sendVideoInChannel(data: data, channelId: self.channelInfo.channel?._id ?? "", text: text ?? "", uuid: uuId, completion: { (err) in
                            if err != nil {
                                DispatchQueue.main.async {
                                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.localizedDescription)
                                }
                            }
                        })
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    func sendText() {
        let text = inputTextField.text
        inputTextField.text = ""
        let uuId = UUID().uuidString
        prepareTableView(messageType: MessageType.text, uuID: uuId, text: text!)
        SocketTaskManager.shared.sendChanMessage(message: text!, channelId: channelInfo!.channel!._id, uuid: uuId)
    }
    
    @objc func sendMessage() {
        if mode == .edit {
            mode = .main
            sendButton.setImage(UIImage.init(named: "send"), for: .normal)
            if inputTextField.text != "" {
                if let cell = tableView.cellForRow(at: indexPath!) as? SentMessageTableViewCell {
                    self.viewModel?.editChannelMessageBySender(id: cell.id!, text: self.inputTextField.text!, completion: { (error) in
                        if error != nil {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                            }
                        } else {
                            DispatchQueue.main.async {
                                cell.messageLabel.text = self.inputTextField.text
                                self.inputTextField.text = ""
                                
                            }
                        }
                    })
                }
            }
        } else {
            view.viewWithTag(14)?.removeFromSuperview()
            if selectedImage != nil {
                sendImage()
            } else if sendAsset != nil {
                sendVideo()
            } else if inputTextField.text != nil {
                sendText()
            }
        }
        self.viewConfigurator.removeView()
    }
    
    func showAlertBeforeDeleteMessage() {
        self.showAlert(title: nil, message: "are_you_sure_want_to_delete_selected_messages".localized(), buttonTitle1: "delete".localized(), buttonTitle2: "cancel".localized(), buttonTitle3: nil, completion1: {
            if self.arrayOfSelectedMesssgae.count == 0 {
                self.deleteMessageButton.isEnabled = false
            } else {
                self.deleteMessageButton.isEnabled = true
            }
            self.viewModel?.deleteChannelMessages(id: (self.channelInfo?.channel!._id)!, ids: self.arrayOfSelectedMesssgae, completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    self.channelMessages.array = self.channelMessages.array?.filter({ (message) -> Bool in
                        return !(self.arrayOfSelectedMesssgae.contains(message._id!))
                    })
                    DispatchQueue.main.async {
                        UIView.setAnimationsEnabled(false)
                        self.tableView.reloadData()
                    }
                }
                self.check = !self.check
                self.isPreview = self.check
                DispatchQueue.main.async {
                    UIView.setAnimationsEnabled(false)
                    self.tableView.beginUpdates()
                    self.tableView.reloadData()
                    self.tableView.endUpdates()
                    self.universalButton.setTitle("edit".localized(), for: .normal)
                    self.inputTextField.placeholder = "enter_message".localized()
                    self.tableView.allowsMultipleSelection = false
                    self.tableView.allowsSelection = false
                    self.sendButton.isHidden = false
                    self.viewConfigurator.removeDeleteButton()
                }
                self.arrayOfSelectedMesssgae = []
                if self.channelMessages.array?.count == 0 {
                    self.viewConfigurator.setView("there_is_no_messages")
                    DispatchQueue.main.async {
                        self.universalButton.isHidden = true
                    }
                }
            })
        }, completion2: nil, completion3: nil)
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            bottomConstraint?.constant = isKeyboardShowing ? -keyboardFrame!.height  : -(UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)
            tableViewBottomConstraint.constant = isKeyboardShowing ? keyboardFrame!.height + 48 : 48
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: { (completed) in
                if isKeyboardShowing {
                    if (self.channelMessages.array != nil && (self.channelMessages.array?.count)! > 1) {
                        let indexPath1 = IndexPath(item: (self.channelMessages.array?.count)! - 1, section: 0)
                        self.tableView?.scrollToRow(at: indexPath1, at: .bottom, animated: true)
                    }
                }
            })
        }
    }
    
    @IBAction func nameOfChannelButtonAction(_ sender: Any) {
        DispatchQueue.main.async {
            switch self.channelInfo?.role {
            case 0:
                self.mainRouter?.showAdminInfoViewController(channelInfo: self.channelInfo!)
            case 1:
                self.mainRouter?.showModeratorInfoViewController(channelInfo: self.channelInfo!)
            default:
                self.mainRouter?.showChannelInfoViewController(channelInfo: self.channelInfo!)
            }
        }
    }
    
    @IBAction func backButtonAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func subscribeToChannel() {
        viewModel?.subscribeToChannel(id: channelInfo!.channel!._id, completion: { (subResponse, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else {
                SharedConfigs.shared.signedUser?.channels?.append(self.channelInfo.channel!._id)
                self.channelInfo?.role = 2
                if self.channelInfo.channel?.openMode ?? false {
                    DispatchQueue.main.async {
                        self.viewConfigurator.addConstraints()
                        self.viewConfigurator.setupInputComponents()
                    }
                }
                if self.mainRouter?.channelListViewController?.mode == .main {
                    self.mainRouter?.channelListViewController?.channels.append(self.channelInfo!)
                    self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
                    DispatchQueue.main.async {
                        self.mainRouter?.channelListViewController?.tableView.reloadData()
                    }
                } else {
                    self.mainRouter?.channelListViewController?.channels.append(self.channelInfo!)
                    for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                        if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                            self.mainRouter!.channelListViewController!.foundChannels[i].role = 2
                            break
                        }
                    }
                    self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
                    DispatchQueue.main.async {
                        self.mainRouter?.channelListViewController?.tableView.reloadData()
                    }
                }
                DispatchQueue.main.async {
                    self.mainRouter?.channelListViewController?.tableView.reloadData()
                    self.universalButton.isHidden = true
                }
                
            }
        })
    }
    
    @IBAction func universalButtonAction(_ sender: Any) {
        if channelInfo?.role == 3 {
            subscribeToChannel()
        }  else if channelInfo?.role == 0 || channelInfo?.role == 1 {
            check = !check
            isPreview = check
            DispatchQueue.main.async {
                self.tableView.allowsMultipleSelection = true
                UIView.setAnimationsEnabled(false)
                self.tableView.beginUpdates()
                self.tableView.reloadData()
                self.tableView.endUpdates()
                if !self.isPreview! {
                    self.viewConfigurator.setDeleteMessageButton()
                    self.inputTextField.placeholder = ""
                    self.universalButton.setTitle("cancel".localized(), for: .normal)
                    self.tableView.allowsMultipleSelection = true
                    self.sendButton.isHidden = true
                } else {
                    self.sendButton.isHidden = false
                    self.tableView.allowsMultipleSelection = false
                    self.inputTextField.placeholder = "enter_message".localized()
                    self.tableView.allowsSelection = false
                    self.universalButton.setTitle("edit".localized(), for: .normal)
                    self.viewConfigurator.removeDeleteButton()
                }
            }
        }
    }
    
    func getChannelMessages() {
        viewModel?.getChannelMessages(id: self.channelInfo!.channel!._id, dateUntil: "", completion: { (messages, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if messages != nil {
                self.isLoadedMessages = true
                self.channelMessages = messages!
                if messages?.array?.count != 0 {
                    self.channelMessages.array!.reverse()
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        if self.channelInfo.role == 0 || self.channelInfo.role == 1 {
                            self.check = true
                            self.universalButton.isHidden = false
                            self.universalButton.setTitle("edit".localized(), for: .normal)
                        }
                        if self.channelMessages.array!.count > 0 {
                            self.tableView.scrollToRow(at: IndexPath(row: self.channelMessages.array!.count - 1, section: 0), at: .top, animated: false)
                        }
                    }
                } else {
                    self.viewConfigurator.setView("there_is_no_publication_yet".localized())
                    DispatchQueue.main.async {
                        if self.channelInfo.role == 0 || self.channelInfo.role == 1 {
                            self.universalButton.isHidden = true
                        }
                    }
                }
            }
        })
    }
    
    func handleMessageEdited(message: Message) {
        if message.owner == channelInfo.channel?._id {
            for i in 0..<(channelMessages.array?.count ?? 0) {
                if channelMessages.array?[i]._id == message._id {
                    channelMessages.array?[i] = message
                    DispatchQueue.main.async {
                        if message.senderId == SharedConfigs.shared.signedUser?.id {
                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SentMessageTableViewCell)?.messageLabel.text = message.text
                        } else {
                            (self.tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? RecievedMessageTableViewCell)?.messageLabel.text = message.text
                        }
                    }
                    break
                }
            }
        }
    }
    
    func handleChannelMessageDeleted(messages: [Message]) {
        for message in messages {
            if message.owner == channelInfo.channel?._id {
                var i = 0
                DispatchQueue.main.async {
                    while i < self.channelMessages.array?.count ?? 0 {
                        if self.channelMessages.array?[i]._id == message._id {
                            self.channelMessages.array?.remove(at: i)
                            self.tableView.deleteRows(at: [IndexPath(row: i, section: 0)], with: .automatic)
                            if self.channelMessages.array?.count == 0 {
                                self.viewConfigurator.setView("there_is_no_publication_yet".localized())
                            }
                        } else {
                            i += 1
                        }
                    }
                }
            }
        }
        arrayOfSelectedMesssgae = []
    }
}

//MARK: Extensions
extension ChannelMessagesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelMessages.array!.count
    }
    
    //MARK: HeightForRowAt indexPath
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        return viewConfigurator.heightForRowAt(indexPath: indexPath)
//    }
    
    //MARK: WillDeselectRowAt indexPath
    func tableView(_ tableView: UITableView, willDeselectRowAt indexPath: IndexPath) -> IndexPath? {
        if channelMessages.array?[indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            arrayOfSelectedMesssgae = arrayOfSelectedMesssgae.filter({ (id) -> Bool in
                return  id != channelMessages.array![indexPath.row]._id
            })
            if arrayOfSelectedMesssgae.isEmpty {
                deleteMessagesButton.isHidden = true
                editButton.isHidden = true
                tableView.allowsMultipleSelection = false
            } else if arrayOfSelectedMesssgae.count == 1 {
                editButton.isHidden = false
            }
            (tableView.cellForRow(at: indexPath) as? CellProtocol)?.deselect()
        }
        return indexPath
    }
//
//    //MARK: DidSelectRowAt indexPath
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if channelMessages.array?[indexPath.row].senderId == SharedConfigs.shared.signedUser?.id {
            if let message = channelMessages.array?[indexPath.row]._id {
                arrayOfSelectedMesssgae.append(message)
            }
            if arrayOfSelectedMesssgae.count != 1 {
                editButton.isHidden = true
            }
            (tableView.cellForRow(at: indexPath) as? CellProtocol)?.select()
        }
    }
    
    //MARK: CellForRowAt indexPath
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        view.viewWithTag(12)?.removeFromSuperview()
        return viewConfigurator.configureTableView(indexPath: indexPath)
    }
}


