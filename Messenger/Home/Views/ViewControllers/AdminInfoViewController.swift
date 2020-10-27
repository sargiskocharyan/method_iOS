//
//  AdminInfoViewController.swift
//  Messenger
//
//  Created by Employee3 on 10/2/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import AVFoundation

class AdminInfoViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var urlView: UIView!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var cameraView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var urlLabel: UILabel!
    @IBOutlet weak var urlTextLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var descriptionTextLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var subscribersTextLabel: UILabel!
    @IBOutlet weak var moderatorsTextLabel: UILabel!
    @IBOutlet weak var changeAdminTextLabel: UILabel!
    @IBOutlet weak var channelLogoImageView: UIImageView!
    @IBOutlet weak var moderatorsView: UIView!
    @IBOutlet weak var subscribersView: UIView!
    @IBOutlet weak var changeAdminView: UIView!
    @IBOutlet weak var channelDescriptionLabel: UILabel!
    @IBOutlet weak var chanelDescriptionLabelBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionBottomConstraint: NSLayoutConstraint!
    
    
    //MARK: Properties
    var channelInfo: ChannelInfo?
    var mainRouter: MainRouter?
    var viewModel: ChannelInfoViewModel?
    var moderators: [ChannelSubscriber] = []
    var imagePicker = UIImagePickerController()
    var myConstraint: NSLayoutConstraint!
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        myConstraint = chanelDescriptionLabelBottomConstraint
        configureView()
        addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        setInfo()
        setImage()
        setCornerRadius(view: activityIndicator)
    }
    
    //MARK: Helper methods
    func setImage() {
        activityIndicator.startAnimating()
        ImageCache.shared.getImage(url: channelInfo?.channel?.avatarURL ?? "", id: channelInfo!.channel!._id, isChannel: true) { (image) in
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.channelLogoImageView.image = image
            }
        }
    }
        
    @IBAction func cameraButtonAction(_ sender: Any) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                print("Permission allowed")
            } else {
                print("Permission don't allowed")
            }
        }
        let alert = UIAlertController(title: nil, message: "choose_one_of_this_app_to_upload_photo".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "camera".localized(), style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "album".localized(), style: .default, handler: { (_) in
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .default, handler: nil))
        self.present(alert, animated: true)
    }
    
    @IBAction func deleteChannelAction(_ sender: Any) {
        let alert = UIAlertController(title: nil, message: "are_you_sure_you_want_to_delete_channel".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok", style: .default, handler: { (action) in
            self.viewModel?.deleteChannel(id: self.channelInfo!.channel!._id, completion: { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error".localized(), errorMessage: "esim")
                    }
                } else {
                    let filteredChannels = SharedConfigs.shared.signedUser?.channels?.filter({ (channelId) -> Bool in
                        return self.channelInfo?.channel?._id != channelId
                    })
                    SharedConfigs.shared.signedUser?.channels = filteredChannels
                    if self.mainRouter?.channelListViewController?.mode == .main {
                        for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                            if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                                self.mainRouter!.channelListViewController!.channels.remove(at: i)
                                break
                            }
                        }
                        self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
                        DispatchQueue.main.async {
                            self.mainRouter?.channelListViewController?.tableView.reloadData()
                             self.navigationController?.popToRootViewController(animated: true)
                        }
                    } else {
                        for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                            if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                                self.mainRouter!.channelListViewController!.channels.remove(at: i)
                                break
                            }
                        }
                        for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                            if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                                self.mainRouter!.channelListViewController!.foundChannels.remove(at: i)
                                break
                            }
                        }
                        self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
                        DispatchQueue.main.async {
                            self.mainRouter?.channelListViewController?.tableView.reloadData()
                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    }
                }
                
            })
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
    func updateImage(_ avatarURL: String?) {
        if self.mainRouter?.channelListViewController?.mode == .main {
            for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.channels[i].channel?.avatarURL = avatarURL
                }
            }
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        } else {
            for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.channels[i].channel?.avatarURL = avatarURL
                }
            }
            for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.foundChannels[i].channel?.avatarURL = avatarURL
                    break
                }
            }
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        activityIndicator.startAnimating()
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        viewModel!.uploadImage(image: image, id: channelInfo!.channel!._id) { (error, avatarURL) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                self.channelInfo?.channel?.avatarURL = avatarURL
                ImageCache.shared.getImage(url: avatarURL ?? "", id: SharedConfigs.shared.signedUser?.id ?? "", isChannel: true) { (image) in
                    DispatchQueue.main.async {
                        self.channelLogoImageView.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
                self.updateImage(avatarURL)
            }
        }
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer? = nil) {
        if SharedConfigs.shared.signedUser?.avatarURL == nil {
            return
        }
        let imageView = UIImageView(image: channelLogoImageView.image)
        let closeButton = UIButton()
        imageView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: 20).isActive = true
        closeButton.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: -10).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: 25).isActive = true
        closeButton.isUserInteractionEnabled = true
        closeButton.setImage(UIImage(named: "closeColor"), for: .normal)
        imageView.backgroundColor = UIColor(named: "imputColor")
        let deleteImageButton = UIButton()
        imageView.addSubview(deleteImageButton)
        deleteImageButton.translatesAutoresizingMaskIntoConstraints = false
        deleteImageButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -40).isActive = true
        deleteImageButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        deleteImageButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        deleteImageButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        deleteImageButton.isUserInteractionEnabled = true
        deleteImageButton.setImage(UIImage(named: "trash"), for: .normal)
        deleteImageButton.addTarget(self, action: #selector(deleteAvatar), for: .touchUpInside)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tag = 3
        closeButton.addTarget(self, action: #selector(dismissFullscreenImage), for: .touchUpInside)
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 0).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: 0).isActive = true
        imageView.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    func deleteImage() {
        if self.mainRouter?.channelListViewController?.mode == .main {
            for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.channels[i].channel?.avatarURL = nil
                }
            }
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        } else {
            for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.channels[i].channel?.avatarURL = nil
                }
            }
            for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                    self.mainRouter!.channelListViewController!.foundChannels[i].channel?.avatarURL = nil
                    break
                }
            }
            self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
            DispatchQueue.main.async {
                self.mainRouter?.channelListViewController?.tableView.reloadData()
            }
        }
    }
    
    @objc func deleteAvatar() {
        viewModel!.deleteChannelLogo(id: channelInfo!.channel!._id) { (error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
                return
            } else {
                self.channelInfo?.channel?.avatarURL = nil
                DispatchQueue.main.async {
                    self.dismissFullscreenImage()
                    self.channelLogoImageView.image = UIImage(named: "groupPeople")
                }
                self.deleteImage()
            }
        }
    }
    
    @objc func dismissFullscreenImage() {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        view.viewWithTag(3)?.removeFromSuperview()
    }
    
    @IBAction func editInfoButtonAction(_ sender: UIButton) {
        mainRouter?.showUpdateChannelInfoViewController(channelInfo: channelInfo!)
    }
    
    func addGestures() {
        let tapSubscribers = UITapGestureRecognizer(target: self, action: #selector(self.handleSubscribersTap(_:)))
        subscribersView.addGestureRecognizer(tapSubscribers)
        let tapModerators = UITapGestureRecognizer(target: self, action: #selector(self.handleModeratorsTap(_:)))
        moderatorsView.addGestureRecognizer(tapModerators)
        let tapChangeAdmin = UITapGestureRecognizer(target: self, action: #selector(self.handleChangeAdminTab(_:)))
        changeAdminView.addGestureRecognizer(tapChangeAdmin)
        let tapUrlView = UILongPressGestureRecognizer(target: self, action: #selector(self.handleUrlViewTap(_:)))
        urlView.addGestureRecognizer(tapUrlView)
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.handleImageTap(_:)))
        channelLogoImageView.isUserInteractionEnabled = true
        channelLogoImageView.addGestureRecognizer(tapImage)
    }
    
    @objc func handleUrlViewTap(_ sender: UILongPressGestureRecognizer? = nil) {
        if sender?.state == UIGestureRecognizer.State.began {
            UIPasteboard.general.string = channelInfo?.channel?.publicUrl
            self.showToast(message: "url_copied_in_clipboard", font: .systemFont(ofSize: 15.0))
        }
    }
    
    @objc func handleSubscribersTap(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showSubscribersListViewControllerFromAdminInfo(id: channelInfo?.channel?._id ?? "")
    }
    
    @objc func handleModeratorsTap(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showModeratorListViewController(id: channelInfo!.channel!._id, isChangeAdmin: false)
    }
    
    @objc func handleChangeAdminTab(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showModeratorListViewController(id: channelInfo!.channel!._id, isChangeAdmin: true)
    }
    
    func configureView() {
        setBorder(view: urlView)
        setBorder(view: descriptionView)
        setBorder(view: subscribersView)
        setBorder(view: moderatorsView)
        setBorder(view: changeAdminView)
        setCornerRadius(view: channelLogoImageView)
        setCornerRadius(view: cameraView)
    }
    
    func setInfo() {
        if channelInfo?.channel?.openMode == true {
            channelDescriptionLabel.text = "all_members_can_post".localized()
        } else {
            channelDescriptionLabel.text = "only_admin_can_post".localized()
        }
        nameLabel.text = channelInfo?.channel?.name
        if channelInfo?.channel?.description?.count ?? 0 > 0 {
            descriptionLabel.text = channelInfo?.channel?.description
            descriptionBottomConstraint.priority = UILayoutPriority(rawValue: 1000)
            chanelDescriptionLabelBottomConstraint.isActive = false
        } else {
            chanelDescriptionLabelBottomConstraint = myConstraint
            chanelDescriptionLabelBottomConstraint.isActive = true
            chanelDescriptionLabelBottomConstraint.constant = 10.0
            descriptionBottomConstraint.priority = UILayoutPriority(rawValue: 250)
        }
        urlLabel.text = channelInfo?.channel?.publicUrl
        descriptionTextLabel.text = "description".localized()
        urlTextLabel.text = "URL"
        subscribersTextLabel.text = "subscribers".localized()
        moderatorsTextLabel.text = "moderators".localized()
        changeAdminTextLabel.text = "change_admin".localized()
        deleteButton.setTitle("delete_channel".localized(), for: .normal)
    }
    
    func setCornerRadius(view: UIView) {
        view.layer.cornerRadius = view.frame.height / 2
        view.clipsToBounds = true
    }
    
    func setBorder(view: UIView) {
        view.layer.borderColor = UIColor.lightGray.cgColor
        view.layer.borderWidth = 1
    }
}
