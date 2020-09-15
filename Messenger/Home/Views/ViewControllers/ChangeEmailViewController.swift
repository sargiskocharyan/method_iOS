//
//  ChangeEmailViewController.swift
//  Messenger
//
//  Created by Employee1 on 8/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

enum ChangingSubject: String {
    case phone
    case email
}

protocol ChangeEmailViewControllerDelegate: class {
    func setEmail(email: String)
    func setPhone(phone: String)
}

class ChangeEmailViewController: UIViewController  {
    
    //MARK: IBOutlets
    @IBOutlet weak var updateInformationButton: UIButton!
    @IBOutlet weak var codeCustomView: CustomTextField!
    @IBOutlet weak var emailCustomView: CustomTextField!
    
    //MARK: Properties
    var mainRouter: MainRouter?
    var viewModel: ChangeEmailViewModel?
    var isVerifedEmail: Bool?
    var isVerifiedPhone: Bool?
    var changingSubject: ChangingSubject?
    weak var delegate: ChangeEmailViewControllerDelegate?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        emailCustomView.delagate = self
        print(changingSubject as Any)
        disableUpdateInfoButton()
        isVerifedEmail = false
        isVerifiedPhone = false
        codeCustomView.isHidden = true
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if changingSubject == .email {
            updateInformationButton.setTitle("check_mail".localized(), for: .normal)
        } else if changingSubject == .phone {
            emailCustomView.placeholder = "phone"
            updateInformationButton.setTitle("check_phone".localized(), for: .normal)
        }
    }
    
    //MARK: Helper methods
    @IBAction func changeEmailButtonAction(_ sender: Any) {
        if changingSubject == .email {
            if !isVerifedEmail! {
                viewModel?.changeEmail(email: emailCustomView.textField.text!, completion: { (responseObj, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    } else if responseObj != nil {
                        if responseObj?.mailExist == false {
                            DispatchQueue.main.async {
                                self.codeCustomView.isHidden = false
                                self.isVerifedEmail = true
                                self.codeCustomView.textField.text = responseObj?.code
                                self.updateInformationButton.setTitle("confirm_code".localized(), for: .normal)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: "this_email_is_taken".localized())
                            }
                        }
                    }
                })
            } else {
                viewModel?.verifyEmail(email: emailCustomView.textField.text!, code: codeCustomView.textField.text!, completion: { (responseObj, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    } else if responseObj != nil {
                        DispatchQueue.main.async {
                            let user = UserModel(name: responseObj!.user.name, lastname: responseObj!.user.lastname, username: responseObj!.user.username, email: responseObj!.user.email,  token: SharedConfigs.shared.signedUser!.token, id: responseObj!.user.id, avatarURL: responseObj!.user.avatarURL, phoneNumber: responseObj!.user.phoneNumber, birthDate: responseObj!.user.birthDate, gender: responseObj!.user.gender, info: responseObj!.user.info, tokenExpire: SharedConfigs.shared.signedUser?.tokenExpire)
                            UserDataController().populateUserProfile(model: user)
                            self.delegate?.setEmail(email: self.emailCustomView.textField.text!)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
        } else if changingSubject == .phone {
            if !isVerifiedPhone! {
                viewModel?.changePhone(phone: emailCustomView.textField.text!, completion: { (responseObj, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    } else if responseObj != nil {
                        if responseObj?.phonenumberExists == false {
                            DispatchQueue.main.async {
                                self.codeCustomView.isHidden = false
                                self.isVerifiedPhone = true
                                self.codeCustomView.textField.text = responseObj?.code
                                self.updateInformationButton.setTitle("confirm_code".localized(), for: .normal)
                            }
                        } else {
                            DispatchQueue.main.async {
                                self.showErrorAlert(title: "error".localized(), errorMessage: "this_number_is_taken".localized())
                            }
                        }
                    }
                })
            } else {
                viewModel?.verifyPhone(phone: emailCustomView.textField.text!, code: codeCustomView.textField.text!, completion: { (responseObj, error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error".localized(), errorMessage: error!.rawValue)
                        }
                    } else if responseObj != nil {
                        DispatchQueue.main.async {
                            let user = UserModel(name: responseObj!.user.name, lastname: responseObj!.user.lastname, username: responseObj!.user.username, email: responseObj!.user.email,  token: SharedConfigs.shared.signedUser!.token, id: responseObj!.user.id, avatarURL: responseObj!.user.avatarURL, phoneNumber: responseObj!.user.phoneNumber, birthDate: responseObj!.user.birthDate, gender: responseObj!.user.gender, info: responseObj!.user.info, tokenExpire: SharedConfigs.shared.signedUser?.tokenExpire)
                            UserDataController().populateUserProfile(model: user)
                            self.delegate?.setPhone(phone: self.emailCustomView.textField.text!)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            }
        }
    }
    
    func enableUpdateInfoButton() {
        updateInformationButton.backgroundColor = .clear
        updateInformationButton.titleLabel?.textColor = .white
        updateInformationButton.isEnabled = true
    }
    
    func disableUpdateInfoButton() {
        updateInformationButton.isEnabled = false
        updateInformationButton.titleLabel?.textColor = UIColor.white
        updateInformationButton.backgroundColor = UIColor.lightGray
    }
}

//MARK: Extension
extension ChangeEmailViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
        if placeholder == "email".localized() {
            if !emailCustomView.textField.text!.isValidEmail() {
                emailCustomView.errorLabel.text = emailCustomView.errorMessage
                emailCustomView.errorLabel.textColor = .red
                emailCustomView.border.backgroundColor = .red
                disableUpdateInfoButton()
            } else {
                emailCustomView.border.backgroundColor = .blue
                emailCustomView.errorLabel.textColor = .blue
                emailCustomView.errorLabel.text = emailCustomView.successMessage
                enableUpdateInfoButton()
            }
        }
        if placeholder == "phone".localized() {
            if !emailCustomView.textField.text!.isValidNumber() {
                emailCustomView.errorLabel.text = "invalid_phone_number".localized()
                emailCustomView.errorLabel.textColor = .red
                emailCustomView.border.backgroundColor = .red
                disableUpdateInfoButton()
            } else {
                emailCustomView.border.backgroundColor = .blue
                emailCustomView.errorLabel.textColor = .blue
                emailCustomView.errorLabel.text = "correct_phone_number".localized()
                enableUpdateInfoButton()
            }
        }
    }
}
