//
//  CreateAccountAlertViewController.swift
//  Messenger
//
//  Created by Employee1 on 10/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class CreateAccountAlertViewController: UIViewController {
    
    @IBOutlet weak var channelModeLabel: UILabel!
    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var createAlertLabel: UILabel!
    @IBOutlet weak var enterNameOfChannelLabel: UILabel!

    @IBOutlet weak var enterChannelNameView: CustomTextField!
    var mainRouter: MainRouter?
    var channelMode: Bool?
    var viewModel: ChannelListViewModel?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        channelMode = true
        createButton.isEnabled = false
        createAlertLabel.text = "create_channel".localized()
        enterNameOfChannelLabel.text = "enter_name_of_channel".localized()
        channelModeLabel.text = "private".localized()
        cancelButton.setTitle("cancel".localized(), for: .normal)
        createButton.setTitle("create".localized(), for: .normal)
        enterChannelNameView.textField.addTarget(self, action: #selector(nameTyping), for: .editingChanged)
        enterChannelNameView.placeholder = "name".localized()
    }
    
    @objc func nameTyping() {
            checkName { (isAllWell) in
                if isAllWell! {
                    self.createButton.isEnabled = true
                } else {
                    self.createButton.isEnabled = false
                }
        }
    }
    
    @IBAction func `switch`(_ sender: UISwitch) {
        channelMode = sender.isOn
    }
    
    @IBAction func cancelButtonAction(_ sender: Any) {
        parent?.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func createButtonAction(_ sender: Any) {
        mainRouter?.channelListViewController?.createChannel(name: enterChannelNameView.textField.text!, mode: !channelMode!, completion: {
            DispatchQueue.main.async {
                self.parent?.dismiss(animated: true, completion: nil)
            }
        })
    }
    
    func checkName(completion: @escaping (Bool?)->()) {
        if enterChannelNameView.textField.text!.count >= 3 {
            viewModel?.checkChannelName(name: enterChannelNameView.textField.text!, completion: { (response, error) in
                if error == nil && response != nil {
                    if response!.channelNameExists == true {
                        DispatchQueue.main.async {
                            self.enterChannelNameView.borderColor = .red
                            self.enterChannelNameView.errorLabel.text = "this_name_of_channel_is_taken".localized()
                            completion(false)
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.enterChannelNameView.errorLabel.text = "currect_name".localized()
                            self.enterChannelNameView.borderColor = .blue
                            completion(true)
                        }
                    }
                }
            })
            
        } else {
            enterChannelNameView.errorLabel.text = "incorrect_name".localized()
            enterChannelNameView.borderColor = .red
            completion(false)
        }
    }

}
