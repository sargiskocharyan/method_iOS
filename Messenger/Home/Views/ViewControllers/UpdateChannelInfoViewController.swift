//
//  UpdateChannelInfoViewController.swift
//  Messenger
//
//  Created by Employee3 on 10/5/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class UpdateChannelInfoViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var updateInfoButton: UIButton!
    @IBOutlet weak var descriptionCustomView: CustomTextField!
    @IBOutlet weak var nameCustomView: CustomTextField!
    
    var viewModel: UpdateChannelInfoViewModel?
    var mainRouter: MainRouter?
    var isChangingName = false
    var name: String?
    var descriptionch: String?
    var channelInfo: ChannelInfo?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        disableUpdateInfoButton()
        hideKeyboardWhenTappedAround()
        nameCustomView.delagate = self
        descriptionCustomView.delagate = self
        nameCustomView.textField.delegate = self
        descriptionCustomView.textField.delegate = self
        descriptionCustomView.textField.text = channelInfo?.channel?.description
        nameCustomView.textField.text = channelInfo?.channel?.name
        nameCustomView.textField.addTarget(self, action: #selector(nameTextFieldAction), for: .editingChanged)
        descriptionCustomView.textField.addTarget(self, action: #selector(descriptionTextFieldAction), for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateInfoButton.setTitle("update_information".localized(), for: .normal)
        descriptionCustomView.placeholder = "description".localized()
    }
    
    @objc func nameTextFieldAction() {
        nameCustomView.errorLabel.isHidden = (nameCustomView.textField.text == "")
        isChangingName = true
        checkFields()
    }
    
    @objc func descriptionTextFieldAction() {
        descriptionCustomView.errorLabel.isHidden = (nameCustomView.textField.text == "")
        isChangingName = false
        checkFields()
    }
    
    @IBAction func updateButtonAction(_ sender: Any) {
        viewModel?.updateChannelInfo(id: channelInfo!.channel!._id, name: name, description: descriptionch) { (channel, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                }
            } else if channel != nil {
                self.channelInfo = ChannelInfo(channel: channel, role: 0)
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                    self.mainRouter?.adminInfoViewController?.channelInfo = self.channelInfo
                    self.mainRouter?.adminInfoViewController?.setInfo()
                    self.mainRouter?.channelMessagesViewController?.channelInfo = self.channelInfo
                    if (self.mainRouter?.channelListViewController?.channelsInfo.elementsEqual((self.mainRouter!.channelListViewController!.channels))) == true {
                        for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                            if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                                self.mainRouter!.channelListViewController!.channels[i] = self.channelInfo!
                            }
                        }
                        self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.channels)!
                        DispatchQueue.main.async {
                            self.mainRouter?.channelListViewController?.tableView.reloadData()
                        }
                    } else {
                        for i in 0..<self.mainRouter!.channelListViewController!.channels.count {
                            if self.mainRouter!.channelListViewController!.channels[i].channel?._id == self.channelInfo?.channel?._id {
                                self.mainRouter!.channelListViewController!.channels[i] = self.channelInfo!
                            }
                        }
                        for i in 0..<self.mainRouter!.channelListViewController!.foundChannels.count {
                            if self.mainRouter!.channelListViewController!.foundChannels[i].channel?._id == self.channelInfo?.channel?._id {
                                self.mainRouter!.channelListViewController!.foundChannels[i] = self.channelInfo!
                                break
                            }
                        }
                        self.mainRouter?.channelListViewController?.channelsInfo = (self.mainRouter?.channelListViewController?.foundChannels)!
                        DispatchQueue.main.async {
                            self.mainRouter?.channelListViewController?.tableView.reloadData()
                        }
                    }
                }
            }
        }
    }
    
    func checkName(completion: @escaping (Bool?)->()) {
        if channelInfo?.channel?.name != nameCustomView.textField.text {
            if nameCustomView.textField.text!.count >= 3 {
                if isChangingName {
                    self.nameCustomView.errorLabel.text = ""
                    self.nameCustomView.errorLabel.textColor = .red
                    viewModel?.checkChannelName(name: nameCustomView.textField.text!, completion: { (response, error) in
                        if error == nil && response != nil {
                            if response!.channelNameExists == true {
                                DispatchQueue.main.async {
                                    self.name = nil
                                    self.nameCustomView.errorLabel.textColor = .red
                                    self.nameCustomView.errorLabel.text = "this_name_of_channel_is_taken".localized()
                                    completion(false)
                                }
                            } else {
                                DispatchQueue.main.async {
                                    self.nameCustomView.errorLabel.text = "correct_name".localized()
                                    self.nameCustomView.errorLabel.textColor = .blue
                                    self.name = self.nameCustomView.textField.text
                                    completion(true)
                                }
                            }
                        }
                    })
                } else {
                    completion(true)
                }
            } else {
                self.nameCustomView.errorLabel.text = "incorrect_name".localized()
                self.nameCustomView.errorLabel.textColor = .red
                name = nil
                completion(false)
            }
        } else {
            self.nameCustomView.errorLabel.text = ""
            name = nil
            completion(nil)
        }
    }
    func disableUpdateInfoButton() {
        updateInfoButton.isEnabled = false
        updateInfoButton.titleLabel?.textColor = UIColor.white
        updateInfoButton.backgroundColor = UIColor.lightGray
    }
    
    func enableUpdateInfoButton() {
        updateInfoButton.backgroundColor = .clear
        updateInfoButton.titleLabel?.textColor = .white
        updateInfoButton.isEnabled = true
    }
    
    func checkDescription() -> Bool? {
        if channelInfo?.channel?.description != descriptionCustomView.textField.text {
            if descriptionCustomView.textField.text!.count > 3 && descriptionCustomView.textField.text!.count < 100 {
                self.descriptionCustomView.errorLabel.textColor = .blue
                descriptionCustomView.errorLabel.text = ""
                descriptionch = descriptionCustomView.textField.text
                return true
            } else if descriptionCustomView.textField.text?.count == 0 {
                descriptionCustomView.errorLabel.text = ""
                descriptionch = descriptionCustomView.textField.text
                return true
            } else {
                self.descriptionCustomView.errorLabel.textColor = .red
                descriptionCustomView.errorLabel.text = "must_contain_4_letters".localized()
                descriptionch = nil
                return false
            }
        } else {
            descriptionCustomView.errorLabel.text = ""
            descriptionch = nil
            return nil
        }
    }
    
    func checkFields() {
        let checkDescription = self.checkDescription()
        checkName() { (isAllWell) in
            if isAllWell == true && checkDescription == true {
                self.enableUpdateInfoButton()
            } else if checkDescription == true && isAllWell != false {
                self.enableUpdateInfoButton()
            } else if isAllWell == true && checkDescription != false {
                self.enableUpdateInfoButton()
            } else {
                self.disableUpdateInfoButton()
            }
        }
    }
}


extension UpdateChannelInfoViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
        
        if placeholder == "name".localized() {
            
            //            if !nameView.textField.text!.isValidNameOrLastname() {
            //                nameView.errorLabel.text = nameView.errorMessage
            //                nameView.errorLabel.textColor = .red
            //                nameView.border.backgroundColor = .red
            //            } else {
            //                nameView.border.backgroundColor = .blue
            //                nameView.errorLabel.textColor = .blue
            //                nameView.errorLabel.text = nameView.successMessage
            //            }
        }
        if placeholder == "info" {
            
            //            if !lastnameView.textField.text!.isValidNameOrLastname() {
            //                lastnameView.errorLabel.text = lastnameView.errorMessage
            //                lastnameView.errorLabel.textColor = .red
            //                lastnameView.border.backgroundColor = .red
            //            } else {
            //                lastnameView.border.backgroundColor = .blue
            //                lastnameView.errorLabel.textColor = .blue
            //                lastnameView.errorLabel.text = lastnameView.successMessage
            //            }
        }
    }
}
