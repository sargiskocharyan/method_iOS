//
//  EditInformationViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/19/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import DropDown

class EditInformationViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var updateInformationButton: UIButton!
    @IBOutlet weak var usernameView: CustomTextField!
    @IBOutlet weak var nameView: CustomTextField!
    @IBOutlet weak var lastnameView: CustomTextField!
    @IBOutlet weak var universityTextField: UITextField!
    
    //MARK: Properties
    let viewModel = RegisterViewModel()
    var isMore = false
    let dropDown = DropDown()
    let moreOrLessImageView = UIImageView()
    var universities: [University] = []
    let gradientColor = CAGradientLayer()
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        nameView.delagate = self
        lastnameView.delagate = self
        usernameView.delagate = self
        addDropDown()
        getUniversities()
        nameView.textField.text = SharedConfigs.shared.signedUser?.name
        lastnameView.textField.text = SharedConfigs.shared.signedUser?.lastname
        usernameView.textField.text = SharedConfigs.shared.signedUser?.username
        setUniversityName()
        universityTextField.placeholder = "select_university".localized()
        updateInformationButton.setTitle("update_information".localized(), for: .normal)
        self.hideKeyboardWhenTappedAround()
    }
    
    
    
    override func viewDidLayoutSubviews() {
        universityTextField.underlined()
        nameView.handleRotate()
        lastnameView.handleRotate()
        usernameView.handleRotate()
        updateInformationButton.setGradientBackground(view: self.view, gradientColor)
    }
    
    //MARK: Helper methods
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
        if nameView.textField.text != " " && lastnameView.textField.text != "" && usernameView.textField.text != "" && id != nil {
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
        let button = UIButton(frame: universityTextField.frame)
        button.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        universityTextField.addSubview(moreOrLessImageView)
        self.universityTextField.addSubview(button)
        moreOrLessImageView.frame = CGRect(x: universityTextField.frame.maxX - 35, y: universityTextField.frame.maxY - 30, width: 30, height: 30)
        moreOrLessImageView.image = UIImage(named: "more")
        moreOrLessImageView.isUserInteractionEnabled = true
        dropDown.anchorView = button
        dropDown.direction = .any
        
        dropDown.bottomOffset = CGPoint(x: 0, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.universityTextField.text = item
            self.moreOrLessImageView.image = UIImage(named: "more")
            self.isMore = false
        }
        dropDown.width = button.frame.width
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
        
    }
}
