//
//  UpdateChannelInfoViewController.swift
//  Messenger
//
//  Created by Employee3 on 10/5/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class UpdateChannelInfoViewController: UIViewController {

    @IBOutlet weak var updateInfoButton: UIButton!
    @IBOutlet weak var descriptionCustomView: CustomTextField!
    @IBOutlet weak var nameCustomView: CustomTextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        nameCustomView.delagate = self
        descriptionCustomView.delagate = self
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
