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
    @IBOutlet weak var updateInformationButton: UIButton!
    @IBOutlet weak var usernameView: CustomTextField!
    @IBOutlet weak var nameView: CustomTextField!
    @IBOutlet weak var lastnameView: CustomTextField!
    @IBOutlet weak var universityTextField: UITextField!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewOnScroll: UIView!
    @IBOutlet weak var phoneCustomView: CustomTextField!
    
    //MARK: Properties
    let viewModel = RegisterViewModel()
    var isMore = false
    let dropDown = DropDown()
    let moreOrLessImageView = UIImageView()
    var universities: [University] = []
    var constant = 0
    let button = UIButton()
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        constant = Int(stackViewTopConstraint.constant)
        nameView.delagate = self
        nameView.textField.delegate = self
        lastnameView.textField.delegate = self
        usernameView.textField.delegate = self
        lastnameView.delagate = self
        usernameView.delagate = self
        phoneCustomView.delagate = self
        addDropDown()
        getUniversities()
        nameView.textField.text = SharedConfigs.shared.signedUser?.name
        lastnameView.textField.text = SharedConfigs.shared.signedUser?.lastname
        usernameView.textField.text = SharedConfigs.shared.signedUser?.username
        setUniversityName()
        universityTextField.underlinedUniversityTextField()
        universityTextField.placeholder = "select_university".localized()
        updateInformationButton.setTitle("update_information".localized(), for: .normal)
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
        dropDown.hide()
        moreOrLessImageView.image = UIImage(named: "more")
        if size.width > size.height {
            constant = 50
        } else {
            constant = 100
        }
    }
    
    override func viewDidLayoutSubviews() {
        dropDown.width = button.frame.width
        nameView.handleRotate()
        lastnameView.handleRotate()
        usernameView.handleRotate()
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
        if self.view.frame.height - (CGFloat(constant) + customView.frame.maxY + 44) < keyboardFrame!.height {
            stackViewTopConstraint.constant = CGFloat(isKeyboardShowing ? constant - (Int(keyboardFrame!.height) - Int((self.view.frame.height - (CGFloat(constant) + customView.frame.maxY + 15 + 44)))) : constant)
        } else {
            stackViewTopConstraint.constant = CGFloat(constant)
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
    
    func addImage() {
        universityTextField.addSubview(moreOrLessImageView)
        moreOrLessImageView.image = UIImage(named: "more")
        moreOrLessImageView.topAnchor.constraint(equalTo: universityTextField.topAnchor, constant: 20).isActive = true
        moreOrLessImageView.rightAnchor.constraint(equalTo: universityTextField.rightAnchor, constant: 0).isActive = true
        moreOrLessImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        moreOrLessImageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        moreOrLessImageView.isUserInteractionEnabled = true
        moreOrLessImageView.anchor(top: universityTextField.topAnchor, paddingTop: 20, bottom: universityTextField.bottomAnchor, paddingBottom: 15, left: nil, paddingLeft: 0, right: universityTextField.rightAnchor, paddingRight: 0, width: 25, height: 10)
    }
    
    func addButton() {
        button.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        self.universityTextField.addSubview(button)
        button.topAnchor.constraint(equalTo: universityTextField.topAnchor, constant: 0).isActive = true
        button.rightAnchor.constraint(equalTo: universityTextField.rightAnchor, constant: 0).isActive = true
        button.leftAnchor.constraint(equalTo: universityTextField.leftAnchor, constant: 0).isActive = true
        button.heightAnchor.constraint(equalToConstant: universityTextField.frame.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: universityTextField.frame.width).isActive = true
        button.anchor(top: universityTextField.topAnchor, paddingTop: 0, bottom: universityTextField.bottomAnchor, paddingBottom: 0, left: universityTextField.leftAnchor, paddingLeft: 0, right: universityTextField.rightAnchor, paddingRight: 0, width: universityTextField.frame.width, height: universityTextField.frame.height)
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
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.name
                    })
                case AppLangKeys.Rus:
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameRU
                    })
                case AppLangKeys.Eng:
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameEN
                    })
                default:
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameEN
                    })
                }
            }
        }
    }
    
    @objc func imageTapped() {
        checkFields()
        if isMore {
            isMore = false
            dropDown.hide()
            moreOrLessImageView.image = UIImage(named: "more")
        }
        else {
            isMore = true
            dropDown.show()
            moreOrLessImageView.image = UIImage(named: "less")
        }
    }
    
    func addDropDown() {
           addButton()
           addImage()
           dropDown.anchorView = button
           dropDown.direction = .any
           dropDown.bottomOffset = CGPoint(x: 0, y:((dropDown.anchorView?.plainView.bounds.height)! + universityTextField.frame.height + 5 - 25))
           dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
               self.universityTextField.text = item
               self.moreOrLessImageView.image = UIImage(named: "more")
               self.isMore = false
           }
           dropDown.width = universityTextField.frame.width
           let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.universityTextField.frame.height))
           universityTextField.rightView = paddingView
           universityTextField.rightViewMode = UITextField.ViewMode.always
       }
    
}

//MARK: Extension
extension EditInformationViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
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
