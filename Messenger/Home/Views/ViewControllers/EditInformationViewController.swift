//
//  EditInformationViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/19/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import DropDown

class EditInformationViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var birdthdateView: CustomTextField!
    @IBOutlet weak var addressView: CustomTextField!
    @IBOutlet weak var updateInformationButton: UIButton!
    @IBOutlet weak var usernameView: CustomTextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var nameView: CustomTextField!
    @IBOutlet weak var lastnameView: CustomTextField!
    @IBOutlet weak var universityTextField: UITextField!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewOnScroll: UIView!
    @IBOutlet weak var phoneCustomView: CustomTextField!
    
    //MARK: Properties
    let viewModel = RegisterViewModel()
    var isMoreUniversity = false
    var isMoreGender = false
    let universityDropDown = DropDown()
    let editInformatioViewModel = EditInformationViewModel()
    let genderDropDown = DropDown()
    let universityMoreOrLessImageView = UIImageView()
    let genderMoreOrLessImageView = UIImageView()
    var universities: [University] = []
    var constant: CGFloat = 0
    let universityButton = UIButton()
    let genderButton = UIButton()
    let socketTaskManager = SocketTaskManager.shared
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        constant = stackViewTopConstraint.constant
        nameView.delagate = self
        nameView.textField.delegate = self
        lastnameView.textField.delegate = self
        usernameView.textField.delegate = self
        lastnameView.delagate = self
        usernameView.delagate = self
        phoneCustomView.delagate = self
        birdthdateView.delagate = self
        addUniversityDropDown()
        getUniversities()
        addGenderDropDown()
        nameView.textField.text = SharedConfigs.shared.signedUser?.name
        lastnameView.textField.text = SharedConfigs.shared.signedUser?.lastname
        usernameView.textField.text = SharedConfigs.shared.signedUser?.username
        setUniversityName()
        universityTextField.underlinedUniversityTextField()
        genderTextField.underlinedUniversityTextField()
        universityTextField.placeholder = "select_university".localized()
        updateInformationButton.setTitle("update_information".localized(), for: .normal)
        genderTextField.placeholder = "select_gender".localized()
        self.hideKeyboardWhenTappedAround()
        setObservers()
        updateInformationButton.isEnabled = false
        updateInformationButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        updateInformationButton.titleLabel?.textColor = UIColor.lightGray
        nameView.textField.addTarget(self, action: #selector(nameTextFieldAction), for: .editingChanged)
        usernameView.textField.addTarget(self, action: #selector(usernameTextFieldAction), for: .editingChanged)
        lastnameView.textField.addTarget(self, action: #selector(lastnameTextFieldAction), for: .editingChanged)
        phoneCustomView.textField.addTarget(self, action: #selector(phoneTextFieldAction), for: .editingChanged)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        universityDropDown.hide()
        genderDropDown.hide()
        universityMoreOrLessImageView.image = UIImage(named: "more")
        genderMoreOrLessImageView.image = UIImage(named: "more")
        if size.width > size.height {
            constant = 50
        } else {
            constant = 100
        }
    }
    
    override func viewDidLayoutSubviews() {
        universityDropDown.width = universityButton.frame.width
        genderDropDown.width = genderTextField.frame.width
        nameView.handleRotate()
        lastnameView.handleRotate()
        usernameView.handleRotate()
        if universityDropDown.isHidden {
            isMoreUniversity = false
        } else {
            isMoreUniversity = true
        }
    }
    
    //MARK: Helper methods
    @objc func phoneTextFieldAction() {
        checkFields()
    }

    func checkFields() {
        var id: String?
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            id = self.universities.first { (university) -> Bool in
                university.name == self.universityTextField.text!
                }?._id
        case AppLangKeys.Rus:
            id = self.universities.first { (university) -> Bool in
                university.nameRU == self.universityTextField.text!
                }?._id
        default:
            id = self.universities.first { (university) -> Bool in
                university.nameEN == self.universityTextField.text!
                }?._id
        }
        if (nameView.textField.text?.isValidNameOrLastname())! && (lastnameView.textField.text?.isValidNameOrLastname())! && (usernameView.textField.text?.isValidUsername())! && id != nil {
            updateInformationButton.backgroundColor = .clear
            updateInformationButton.titleLabel?.textColor = .white
            updateInformationButton.isEnabled = true
        } else {
            updateInformationButton.isEnabled = false
            updateInformationButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
            updateInformationButton.titleLabel?.textColor = UIColor.lightGray
        }
    }
    
    @objc func nameTextFieldAction() {
        checkFields()
    }
    
    @objc func usernameTextFieldAction() {
        checkFields()
    }
    
    @objc func lastnameTextFieldAction() {
       checkFields()
    }
    
    func raiseStackView(_ keyboardFrame: CGRect?, _ isKeyboardShowing: Bool, _ customView: UIView) {
        if self.view.frame.height - (constant + customView.frame.maxY + 44) < keyboardFrame!.height {
            stackViewTopConstraint.constant = isKeyboardShowing ? constant - (keyboardFrame!.height - (self.view.frame.height - (constant + customView.frame.maxY + 85))) : constant
        } else {
            stackViewTopConstraint.constant = constant
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
              if let userInfo = notification.userInfo {
                  let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
                  let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
                
                if usernameView.textField.isFirstResponder {
                    raiseStackView(keyboardFrame, isKeyboardShowing, usernameView)
                } else if lastnameView.textField.isFirstResponder {
                    raiseStackView(keyboardFrame, isKeyboardShowing, lastnameView)
                } else if nameView.textField.isFirstResponder {
                    raiseStackView(keyboardFrame, isKeyboardShowing, nameView)
                }
                
                  UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                      self.view.layoutIfNeeded()
                  }, completion: nil)
              }
          }
          
          func setObservers() {
              NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
              NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
          }
    
    
    @IBAction func deactivateAccountAction(_ sender: Any) {
        let alert = UIAlertController(title: "attention".localized(), message: "are_you_sure_want_to_deactivate_your_account_you_can_activate_account_again".localized(), preferredStyle: .alert)
               alert.addAction(UIAlertAction(title: "deactivate".localized(), style: .default, handler: { (_) in
                   self.editInformatioViewModel.deactivateAccount { (error) in
                       if error != nil {
                           if error == NetworkResponse.authenticationError {
                               DispatchQueue.main.async {
                                   UserDataController().logOutUser()
                                   let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                                   let nav = UINavigationController(rootViewController: vc)
                                   let window: UIWindow? = UIApplication.shared.windows[0]
                                   window?.rootViewController = nav
                                   window?.makeKeyAndVisible()
                               }
                           } else {
                               DispatchQueue.main.async {
                                   let alert = UIAlertController(title: "error_message".localized(), message: error!.rawValue, preferredStyle: .alert)
                                   alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                                   self.present(alert, animated: true)
                               }
                           }
                       } else {
                           DispatchQueue.main.async {
                               UserDataController().logOutUser()
                               let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                               let nav = UINavigationController(rootViewController: vc)
                               let window: UIWindow? = UIApplication.shared.windows[0]
                               window?.rootViewController = nav
                               window?.makeKeyAndVisible()
                           }
                       }
                       self.socketTaskManager.disconnect()
                   }
               }))
               alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
               self.present(alert, animated: true)
    }
    
    
    @IBAction func deleteAccountAction(_ sender: Any) {
        let alert = UIAlertController(title: "attention".localized(), message: "are_you_sure_want_to_delete_your_account_your_infrtion_will_be_lost".localized(), preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "delete".localized(), style: .default, handler: { (_) in
            self.editInformatioViewModel.deleteAccount { (error) in
                if error != nil {
                    if error == NetworkResponse.authenticationError {
                        DispatchQueue.main.async {
                            UserDataController().logOutUser()
                            let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                            let nav = UINavigationController(rootViewController: vc)
                            let window: UIWindow? = UIApplication.shared.windows[0]
                            window?.rootViewController = nav
                            window?.makeKeyAndVisible()
                        }
                    } else {
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "error_message".localized(), message: error!.rawValue, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    }
                } else {
                    DispatchQueue.main.async {
                        UserDataController().logOutUser()
                        let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                        let nav = UINavigationController(rootViewController: vc)
                        let window: UIWindow? = UIApplication.shared.windows[0]
                        window?.rootViewController = nav
                        window?.makeKeyAndVisible()
                    }
                }
                self.socketTaskManager.disconnect()
            }
        }))
        alert.addAction(UIAlertAction(title: "cancel".localized(), style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
    
//    @objc func deleteAccount() {
//        print(<#T##items: Any...##Any#>)
//    }
    
    func addImage(textField: UITextField, imageView: UIImageView) {
        textField.addSubview(imageView)
        imageView.image = UIImage(named: "more")
        imageView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 25).isActive = true
        imageView.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.isUserInteractionEnabled = true
        imageView.anchor(top: textField.topAnchor, paddingTop: 30, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: textField.rightAnchor, paddingRight: 0, width: 25, height: 20)
    }
    
    func addButtonOnUniversityTextField(button: UIButton, textField: UITextField) {
        button.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        addConstraintsOnButton(button: button, textField: textField)
    }
    
    func addButtonOnGenderTextField(button: UIButton, textField: UITextField) {
        button.addTarget(self, action: #selector(tappedGenderTextField), for: .touchUpInside)
        addConstraintsOnButton(button: button, textField: textField)
    }
    
    @objc func tappedGenderTextField() {
        checkFields()
               if isMoreGender {
                   isMoreGender = false
                   genderDropDown.hide()
                   genderMoreOrLessImageView.image = UIImage(named: "more")
               }
               else {
                   isMoreGender = true
                   genderDropDown.show()
                   genderMoreOrLessImageView.image = UIImage(named: "less")
               }
    }
    
    func addConstraintsOnButton(button: UIButton, textField: UITextField) {
        textField.addSubview(button)
        button.topAnchor.constraint(equalTo: textField.topAnchor, constant: 0).isActive = true
        button.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: 0).isActive = true
        button.leftAnchor.constraint(equalTo: textField.leftAnchor, constant: 0).isActive = true
        button.heightAnchor.constraint(equalToConstant: textField.frame.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: textField.frame.width).isActive = true
        button.anchor(top: textField.topAnchor, paddingTop: 0, bottom: textField.bottomAnchor, paddingBottom: 0, left: textField.leftAnchor, paddingLeft: 0, right: textField.rightAnchor, paddingRight: 0, width: textField.frame.width, height: textField.frame.height)
        
    }
    
    @IBAction func universityTextFieldAction(_ sender: Any) {
        checkFields()
    }
    
    
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        var id: String?
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            id = self.universities.first { (university) -> Bool in
                university.name == self.universityTextField.text!
                }?._id
        case AppLangKeys.Rus:
            id = self.universities.first { (university) -> Bool in
                university.nameRU == self.universityTextField.text!
                }?._id
        default:
            id = self.universities.first { (university) -> Bool in
                university.nameEN == self.universityTextField.text!
                }?._id
        }
        if (nameView.textField.text?.isValidNameOrLastname())! && (lastnameView.textField.text?.isValidNameOrLastname())! && (usernameView.textField.text?.isValidUsername())! && id != nil {
            viewModel.updateUser(name: nameView.textField.text!, lastname: lastnameView.textField.text!, username: usernameView.textField.text!, university: (id)!) { (user, error) in
                if error != nil {
                    if error == NetworkResponse.authenticationError {
                        DispatchQueue.main.async {
                            let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                            vc.modalPresentationStyle = .fullScreen
                            self.present(vc, animated: true, completion: nil)
                        }
                    }
                } else if user != nil {
                    DispatchQueue.main.async {
                        let userModel: UserModel = UserModel(name: user!.name, lastname: user!.lastname, username: user!.username, email: user!.email, university: user!.university, token: SharedConfigs.shared.signedUser?.token ?? "", id: user!.id)
                        UserDataController().populateUserProfile(model: userModel)
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                let alert = UIAlertController(title: "error_message".localized(), message: "please_fill_all_fields".localized(), preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                self.present(alert, animated: true)
            }
        }
    }
    
    func setUniversityName() {
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            universityTextField.text = SharedConfigs.shared.signedUser?.university?.name
        case AppLangKeys.Rus:
            universityTextField.text = SharedConfigs.shared.signedUser?.university?.nameRU
        case AppLangKeys.Eng:
            universityTextField.text = SharedConfigs.shared.signedUser?.university?.nameEN
        default:
            universityTextField.text = SharedConfigs.shared.signedUser?.university?.nameEN
        }
    }
    
    func getUniversities() {
        viewModel.getUniversities { (responseObject, error) in
            if(error != nil) {
                if error == NetworkResponse.authenticationError {
                    let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                    let nav = UINavigationController(rootViewController: vc)
                    let window: UIWindow? = UIApplication.shared.windows[0]
                    window?.rootViewController = nav
                    window?.makeKeyAndVisible()
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else if responseObject != nil {
                self.universities = responseObject!
                switch SharedConfigs.shared.appLang {
                case AppLangKeys.Arm:
                    self.universityDropDown.dataSource = self.universities.map({ (university) -> String in
                        university.name
                    })
                case AppLangKeys.Rus:
                    self.universityDropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameRU
                    })
                case AppLangKeys.Eng:
                    self.universityDropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameEN
                    })
                default:
                    self.universityDropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameEN
                    })
                }
            }
        }
    }
    
    @objc func imageTapped() {
        checkFields()
        if isMoreUniversity {
            isMoreUniversity = false
            universityDropDown.hide()
            universityMoreOrLessImageView.image = UIImage(named: "more")
        }
        else {
            isMoreUniversity = true
            universityDropDown.show()
            universityMoreOrLessImageView.image = UIImage(named: "less")
        }
    }
    
    func addUniversityDropDown() {
        addButtonOnUniversityTextField(button: universityButton, textField: universityTextField)
        addImage(textField: universityTextField, imageView: universityMoreOrLessImageView)
        universityDropDown.anchorView = universityButton
        universityDropDown.direction = .any
        universityDropDown.bottomOffset = CGPoint(x: 0, y:((universityDropDown.anchorView?.plainView.bounds.height)! + universityTextField.frame.height + 5 - 25))
        universityDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.universityTextField.text = item
            self.universityMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreUniversity = false
        }
        universityDropDown.width = universityTextField.frame.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.universityTextField.frame.height))
        universityTextField.rightView = paddingView
        universityTextField.rightViewMode = UITextField.ViewMode.always
        universityDropDown.cancelAction = { [unowned self] in
            self.universityMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreUniversity = false
        }
    }
    
    func addGenderDropDown() {
        addButtonOnGenderTextField(button: genderButton, textField: genderTextField)
        addImage(textField: genderTextField, imageView: genderMoreOrLessImageView)
        genderDropDown.anchorView = genderButton
        genderDropDown.direction = .any
        genderDropDown.dataSource = ["Male", "Female"]
        genderDropDown.bottomOffset = CGPoint(x: 0, y:((genderDropDown.anchorView?.plainView.bounds.height)! + genderTextField.frame.height + 5 - 25))
        genderDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.genderTextField.text = item
            self.genderMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreGender = false
        }
        genderDropDown.width = genderTextField.frame.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.universityTextField.frame.height))
        genderTextField.rightView = paddingView
        genderTextField.rightViewMode = UITextField.ViewMode.always
        genderDropDown.cancelAction = { [unowned self] in
            self.genderMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreGender = false
        }

    }
    
    
}

//MARK: Extension
extension EditInformationViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
        
        if placeholder == "Birthdate(d/m/yyyy)" {
            if !birdthdateView.textField.text!.isValidDate(){
                birdthdateView.errorLabel.text = birdthdateView.errorMessage
                birdthdateView.errorLabel.textColor = .red
                birdthdateView.border.backgroundColor = .red
            } else {
                birdthdateView.border.backgroundColor = .blue
                birdthdateView.errorLabel.textColor = .blue
                birdthdateView.errorLabel.text = birdthdateView.successMessage
            }
        }
        
        if placeholder == "name".localized() {
            if !nameView.textField.text!.isValidNameOrLastname() {
                nameView.errorLabel.text = nameView.errorMessage
                nameView.errorLabel.textColor = .red
                nameView.border.backgroundColor = .red
            } else {
                nameView.border.backgroundColor = .blue
                nameView.errorLabel.textColor = .blue
                nameView.errorLabel.text = nameView.successMessage
            }
        }
        if placeholder == "lastname".localized() {
            if !lastnameView.textField.text!.isValidNameOrLastname() {
                lastnameView.errorLabel.text = lastnameView.errorMessage
                lastnameView.errorLabel.textColor = .red
                lastnameView.border.backgroundColor = .red
            } else {
                lastnameView.border.backgroundColor = .blue
                lastnameView.errorLabel.textColor = .blue
                lastnameView.errorLabel.text = lastnameView.successMessage
            }
        }
        if placeholder == "username".localized() {
            if !usernameView.textField.text!.isValidUsername() {
                usernameView.errorLabel.text = usernameView.errorMessage
                usernameView.errorLabel.textColor = .red
                usernameView.border.backgroundColor = .red
            } else {
                usernameView.border.backgroundColor = .blue
                usernameView.errorLabel.textColor = .blue
                usernameView.errorLabel.text = usernameView.successMessage
            }
        }
        if placeholder == "number".localized() {
                  if !phoneCustomView.textField.text!.isValidNumber() {
                      phoneCustomView.errorLabel.text = phoneCustomView.errorMessage
                      phoneCustomView.errorLabel.textColor = .red
                      phoneCustomView.border.backgroundColor = .red
                  } else {
                      phoneCustomView.border.backgroundColor = .blue
                      phoneCustomView.errorLabel.textColor = .blue
                      phoneCustomView.errorLabel.text = phoneCustomView.successMessage
                  }
              }
        
    }
}
