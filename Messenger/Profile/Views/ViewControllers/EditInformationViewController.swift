//
//  EditInformationViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/19/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import DropDown

class EditInformationViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var birdthdateView: CustomTextField!
    @IBOutlet weak var hidePersonalDataLabel: UILabel!
    @IBOutlet weak var updateInformationButton: UIButton!
    @IBOutlet weak var usernameView: CustomTextField!
    @IBOutlet weak var nameView: CustomTextField!
    @IBOutlet weak var lastnameView: CustomTextField!
    @IBOutlet weak var hideDataSwitch: UISwitch!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewOnScroll: UIView!
    @IBOutlet weak var genderView: CustomTextField!
    @IBOutlet weak var infoView: CustomTextField!
    @IBOutlet weak var deleteAccountButton: UIButton!
    @IBOutlet weak var deactivateAccountButton: UIButton!
    
    //MARK: Properties
    var viewModel: RegisterViewModel?
    var isMoreUniversity = false
    var isMoreGender = false
    let universityDropDown = DropDown()
    let editInformatioViewModel = EditInformationViewModel()
    let genderDropDown = DropDown()
    let genderMoreOrLessImageView = UIImageView()
    var universities: [University] = []
    var constant: CGFloat = 0
    let universityButton = UIButton()
    let genderButton = UIButton()
    let signedUser = SharedConfigs.shared.signedUser
    let datePicker = UIDatePicker()
    var didSomethingChanges: Bool = false
    var gender: String? = nil
    var birthDate: String? = nil
    var name: String?
    var lastname: String?
    var username: String?
    var universityId: String?
    var info: String?
    var mainRouter: MainRouter?
    var isChangingUsername = false
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        addGestureOnBirthdayView()
        constant = stackViewTopConstraint.constant
        setDelegates()
        addGenderDropDown()
        
        self.hideKeyboardWhenTappedAround()
        setObservers()
        
        disableUpdateInfoButton()
        addTargets()
        hideDataSwitch.isOn = SharedConfigs.shared.isHidden
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        deleteAccountButton.setTitle("delete_account".localized(), for: .normal)
        deactivateAccountButton.setTitle("deactivate_account".localized(), for: .normal)
        hidePersonalDataLabel.text = "hide_personal_data".localized()
        setLabelTexts()
        setTopLabels()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        genderDropDown.hide()
        genderMoreOrLessImageView.image = UIImage(named: "more")
        if size.width > size.height {
            constant = 50
        } else {
            constant = 100
        }
    }
    
    override func viewDidLayoutSubviews() {
        genderDropDown.width = genderView.textField.frame.width
        nameView.handleRotate()
        lastnameView.handleRotate()
        usernameView.handleRotate()
    }
    
    //MARK: Helper methods
    @objc func phoneTextFieldAction() {
        checkFields()
    }
    
    func setDelegates() {
        nameView.delagate = self
        nameView.textField.delegate = self
        lastnameView.textField.delegate = self
        usernameView.textField.delegate = self
        lastnameView.delagate = self
        genderView.delagate = self
        usernameView.delagate = self
        infoView.delagate = self
        birdthdateView.delagate = self
    }
    
    func addTargets() {
        nameView.textField.addTarget(self, action: #selector(nameTextFieldAction), for: .editingChanged)
        usernameView.textField.addTarget(self, action: #selector(usernameTextFieldAction), for: .editingChanged)
        lastnameView.textField.addTarget(self, action: #selector(lastnameTextFieldAction), for: .editingChanged)
        infoView.textField.addTarget(self, action: #selector(infoTextFieldAction), for: .editingChanged)
        birdthdateView.textField.addTarget(self, action: #selector(birthDateTextFieldAction), for: .editingChanged)
    }
    
    func disableUpdateInfoButton() {
        updateInformationButton.isEnabled = false
        updateInformationButton.titleLabel?.textColor = UIColor.white
        updateInformationButton.backgroundColor = UIColor.lightGray
    }
    
    func addGestureOnBirthdayView() {
        birdthdateView.isUserInteractionEnabled = true
        let tapBirthdate = UITapGestureRecognizer(target: self, action: #selector(self.handleBirthDateViewTap(_:)))
        birdthdateView.textField.addGestureRecognizer(tapBirthdate)
    }
    
    
    func setLabelTexts() {
        nameView.textField.text = SharedConfigs.shared.signedUser?.name
        lastnameView.textField.text = SharedConfigs.shared.signedUser?.lastname
        usernameView.textField.text = SharedConfigs.shared.signedUser?.username
        genderView.textField.text = SharedConfigs.shared.signedUser?.gender
        infoView.textField.text = signedUser?.info
        genderView.textField.text = signedUser?.gender?.lowercased().localized()
        birdthdateView.textField.text = stringToDate(date: SharedConfigs.shared.signedUser?.birthDate) ?? ""
        updateInformationButton.setTitle("update_information".localized(), for: .normal)
    }
    
    func checkGender(_ signedUser: UserModel?) -> Bool? {
        if  signedUser?.gender?.lowercased() != genderView.textField.text?.lowercased() {
            if genderView.textField.text?.isEmpty == true {
                gender = nil
                return nil
            } else {
                gender = genderView.textField.text!.lowercased()
                return true
            }
        }
        gender = nil
        return nil
    }
    
    func setTopLabels() {
        if nameView.textField.text?.isEmpty == false {
            nameView.topLabel.text = "name".localized()
        }
        if lastnameView.textField.text?.isEmpty == false {
            lastnameView.topLabel.text = "lastname".localized()
        }
        if usernameView.textField.text?.isEmpty == false {
            usernameView.topLabel.text = "username".localized()
        }
        if birdthdateView.textField.text?.isEmpty == false {
            birdthdateView.topLabel.text = "birth_date".localized()
        }
        if genderView.textField.text?.isEmpty == false {
            genderView.topLabel.text = "gender".localized()
        }
        if infoView.textField.text?.isEmpty == false {
            infoView.topLabel.text = "info".localized()
        }
    }
    
    func checkInfo(_ signedUser: UserModel?) -> Bool? {
        if  signedUser?.info != infoView.textField.text {
            if (infoView.textField.text?.isEmpty == true) {
                if (signedUser?.info == nil && infoView.textField.text?.isEmpty == true) {
                    info = nil
                    return nil
                } else {
                    info = infoView.textField.text!
                    return true
                }
            } else {
                info = infoView.textField.text
                return true
            }
        }
        info = nil
        return nil
    }
    
    func checkBirthdate(_ signedUser: UserModel?) -> Bool? {
        if  stringToDate(date: SharedConfigs.shared.signedUser?.birthDate) != birdthdateView.textField.text {
            if signedUser?.birthDate == nil && birdthdateView.textField.text?.isEmpty == true {
                birthDate = nil
                return nil
            } else {
                birthDate = birdthdateView.textField.text!
                return true
            }
        }
        birthDate = nil
        return nil
    }
    
    func checkName(_ signedUser: UserModel?) -> Bool? {
        if signedUser?.name != nameView.textField.text {
            if (nameView.textField.text?.isValidNameOrLastname())! || nameView.textField.text?.isEmpty == true {
                if (signedUser?.name == nil && nameView.textField.text?.isEmpty == true) {
                    name = nil
                    return nil
                } else {
                    name = nameView.textField.text!
                    return true
                }
            } else {
                name = nil
                return false
            }
        }
        name = nil
        return nil
    }
    
    func checkUsername(_ signedUser: UserModel?, completion: @escaping (Bool?)->()) {
        if signedUser?.username?.lowercased() != usernameView.textField.text?.lowercased() {
            if (usernameView.textField.text?.isValidUsername())! {
                if (usernameView.textField.text?.isEmpty == true) {
                    self.usernameView.errorLabel.text = "the_username_must_contain_at_least_4_letters".localized()
                    self.usernameView.errorLabel.textColor = .red
                    username = nil
                    completion(false)
                    return
                } else {
                    if isChangingUsername {
                        self.usernameView.errorLabel.text = ""
                        self.usernameView.borderColor = .red
                        viewModel?.checkUsername(username: usernameView.textField.text!, completion: { (responseObject, error) in
                            if responseObject != nil && responseObject?.usernameExists == false {
                                DispatchQueue.main.async {
                                    self.username = self.usernameView.textField.text!
                                    self.usernameView.errorLabel.text = "correct_username".localized()
                                    self.usernameView.errorLabel.textColor = .blue
                                    completion(true)
                                }
                            } else if responseObject != nil && responseObject?.usernameExists == true {
                                DispatchQueue.main.async {
                                    self.usernameView.errorLabel.text = "this_username_is_taken".localized()
                                    self.username = nil
                                    self.usernameView.errorLabel.textColor = .red
                                    completion(false)
                                }
                            }
                        })
                    }
                }
            } else {
                self.usernameView.errorLabel.text = "the_username_must_contain_at_least_4_letters".localized()
                self.usernameView.errorLabel.textColor = .red
                username = nil
                completion(false)
                return
            }
        } else {
            completion(nil)
            return
        }
        if username == nil {
            completion(false)
            return
        } else {
            completion(true)
            return
        }
    }
    
    func checkLastname(_ signedUser: UserModel?) -> Bool? {
        if  signedUser?.lastname != lastnameView.textField.text {
            if (lastnameView.textField.text?.isValidNameOrLastname())! || lastnameView.textField.text?.isEmpty == true {
                if (signedUser?.lastname == nil && lastnameView.textField.text?.isEmpty == true) {
                    lastname = nil
                    return nil
                } else {
                    lastname = lastnameView.textField.text!
                    return true
                }
            } else {
                lastname = nil
                return false
            }
        }
        lastname = nil
        return nil
    }
    
    func enableUpdateInfoButton() {
        updateInformationButton.backgroundColor = .clear
        updateInformationButton.titleLabel?.textColor = .white
        updateInformationButton.isEnabled = true
    }
    
    func checkFields() {
        checkUsername(signedUser) { (isAllWell) in
            if isAllWell != false && (self.checkGender(self.signedUser) != false) &&  self.checkBirthdate(self.signedUser) != false &&  self.checkName(self.signedUser) != false && self.checkLastname(self.signedUser) != false && self.checkInfo(self.signedUser) != false {
                if self.name != nil || self.lastname != nil || self.username != nil || self.gender != nil || self.birthDate != nil || self.info != nil || self.info != nil {
                    self.enableUpdateInfoButton()
                } else {
                    self.disableUpdateInfoButton()
                }
            } else {
                self.disableUpdateInfoButton()
            }
        }
    }
    
    @objc func nameTextFieldAction() {
        nameView.errorLabel.isHidden = (nameView.textField.text?.isEmpty == true)
        isChangingUsername = false
        checkFields()
    }
    
    @objc func usernameTextFieldAction() {
        isChangingUsername = true
        checkFields()
    }
    
    @objc func lastnameTextFieldAction() {
        lastnameView.errorLabel.isHidden = (lastnameView.textField.text?.isEmpty == true)
        isChangingUsername = false
        checkFields()
    }
    
    @objc func birthDateTextFieldAction() {
        isChangingUsername = false
        checkFields()
    }
    
    @objc func emailTextFieldAction() {
        isChangingUsername = false
        checkFields()
    }
    
    @objc func infoTextFieldAction() {
        isChangingUsername = false
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
            
            UIView.animate(withDuration: .zero, delay: .zero, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    @IBAction func deactivateAccountAction(_ sender: Any) {
        self.showAlert(title: "attention".localized(), message: "are_you_sure_want_to_deactivate_your_account_you_can_activate_account_again".localized(), buttonTitle1: "deactivate".localized(), buttonTitle2: "cancel".localized(), buttonTitle3: nil, completion1: {
            self.editInformatioViewModel.deactivateAccount { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    DispatchQueue.main.async {
                        UserDataController().logOutUser()
                        AuthRouter().assemblyModule()
                    }
                }
                SocketTaskManager.shared.disconnect{}
            }
        }, completion2: nil, completion3: nil)
    }
    
    
    @IBAction func deleteAccountAction(_ sender: Any) {
        self.showAlert(title: "attention".localized(), message: "are_you_sure_want_to_delete_your_account_your_infrtion_will_be_lost".localized(), buttonTitle1: "delete".localized(), buttonTitle2: "cancel".localized(), buttonTitle3: nil, completion1: {
            self.editInformatioViewModel.deleteAccount { (error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    }
                } else {
                    DispatchQueue.main.async {
                        UserDataController().logOutUser()
                        AuthRouter().assemblyModule()
                    }
                }
                SocketTaskManager.shared.disconnect{}
            }
        }, completion2: nil, completion3: nil)
    }
    
    @objc func handleTapViewUnderDatePicker(_ sender: UITapGestureRecognizer? = nil) {
        let calendar = Calendar.current
        let day = calendar.component(.day, from: datePicker.date)
        let month = calendar.component(.month, from: datePicker.date)
        let year = calendar.component(.year, from: datePicker.date)
        let parsedDay = day < 10 ? "0\(day)" : "\(day)"
        let parsedMonth = month < 10 ? "0\(month)" : "\(month)"
        birdthdateView.textField.text = "\(parsedMonth)/\(parsedDay)/\(year)"
        view.viewWithTag(30)?.removeFromSuperview()
        checkFields()
    }
    
    @objc func handleBirthDateViewTap(_ sender: UITapGestureRecognizer? = nil) {
        view.endEditing(true)
        datePicker.backgroundColor = .white.withAlphaComponent(UIColor.colorAlpha)
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        let viewUnderDatePicker = UIView()
        viewUnderDatePicker.tag = 30
        viewUnderDatePicker.backgroundColor = .white.withAlphaComponent(0.9)
        viewUnderDatePicker.isUserInteractionEnabled = true
        let tapViewUnderDatePicker = UITapGestureRecognizer(target: self, action: #selector(self.handleTapViewUnderDatePicker(_:)))
        let okLabel = UILabel()
        okLabel.text = "ok".localized()
        viewUnderDatePicker.addSubview(okLabel)
        okLabel.translatesAutoresizingMaskIntoConstraints = false
        okLabel.bottomAnchor.constraint(equalTo: viewUnderDatePicker.bottomAnchor, constant: ( -(UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0)) - 85).isActive = true
        okLabel.centerXAnchor.constraint(equalTo: viewUnderDatePicker.centerXAnchor).isActive = true
        okLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        okLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        okLabel.isUserInteractionEnabled = true
        viewUnderDatePicker.addGestureRecognizer(tapViewUnderDatePicker)
        view.addSubview(viewUnderDatePicker)
        viewUnderDatePicker.addSubview(datePicker)
        viewUnderDatePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        viewUnderDatePicker.translatesAutoresizingMaskIntoConstraints = false
        viewUnderDatePicker.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1).isActive = true
        viewUnderDatePicker.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 1).isActive = true
        viewUnderDatePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        viewUnderDatePicker.isUserInteractionEnabled = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        datePicker.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40).isActive = true
        datePicker.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .zero).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 250).isActive = true
        datePicker.isUserInteractionEnabled = true
    }
    
    func createDataPicker() {
        
    }
    
    func addImage(textField: UITextField, imageView: UIImageView) {
        textField.addSubview(imageView)
        imageView.image = UIImage(named: "more")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 5).isActive = true
        imageView.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: .zero).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.isUserInteractionEnabled = true
    }
    
    
    
    func addButtonOnGenderTextField(button: UIButton, textField: UITextField) {
        button.addTarget(self, action: #selector(tappedGenderTextField), for: .touchUpInside)
        addConstraintsOnButton(button: button, textField: textField)
    }
    
    @objc func tappedGenderTextField() {
        checkFields()
        genderDropDown.width = genderView.textField.frame.width
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
        button.translatesAutoresizingMaskIntoConstraints = false
        button.topAnchor.constraint(equalTo: textField.topAnchor, constant: .zero).isActive = true
        button.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: .zero).isActive = true
        button.leftAnchor.constraint(equalTo: textField.leftAnchor, constant: .zero).isActive = true
        button.bottomAnchor.constraint(equalTo: textField.bottomAnchor, constant: .zero).isActive = true
    }
    
    @IBAction func hidePersonalData(_ sender: UISwitch) {
        editInformatioViewModel.hideData(isHideData: sender.isOn) { (error) in
            if error != nil {
                self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
            } else {
                DispatchQueue.main.async {
                    SharedConfigs.shared.setIsHidden(selectIsHidden: sender.isOn)
                }
            }
        }
    }
    
    func stringToDate(date:String?) -> String? {
        if date == nil {
            return nil
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date!)
        let calendar = Calendar.current
        if parsedDate == nil {
            return nil
        } else {
            let day = calendar.component(.day, from: parsedDate!)
            let month = calendar.component(.month, from: parsedDate!)
            let year = calendar.component(.year, from: parsedDate!)
            let parsedDay = day < 10 ? "0\(day)" : "\(day)"
            let parsedMonth = month < 10 ? "0\(month)" : "\(month)"
            return "\(parsedMonth)/\(parsedDay)/\(year)"
        }
    }
    
    @IBAction func continueButtonAction(_ sender: UIButton) {
        editInformatioViewModel.editInformation(name: name, lastname: lastname, username: username, info: info, gender: gender, birthDate: birthDate) { (user, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if user != nil {
                DispatchQueue.main.async {
                    let userModel: UserModel = UserModel(name: user!.name, lastname: user!.lastname, username: user!.username, email: user!.email, token: SharedConfigs.shared.signedUser?.token ?? "", id: user!.id, avatarURL: user?.avatarURL, phoneNumber: user?.phoneNumber, birthDate: user?.birthDate, gender: user?.gender, info: user?.info, tokenExpire: SharedConfigs.shared.signedUser?.tokenExpire)
                    UserDataController().populateUserProfile(model: userModel)
                    self.navigationController?.popViewController(animated: true)
                }
            }
            else {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: "please_fill_all_fields".localized())
                }
            }
        }
    }
    
    
    func addGenderDropDown() {
        addButtonOnGenderTextField(button: genderButton, textField: genderView.textField)
        addImage(textField: genderView.textField, imageView: genderMoreOrLessImageView)
        genderDropDown.anchorView = genderButton
        genderDropDown.direction = .any
        genderDropDown.dataSource = ["male".localized(), "female".localized()]
        genderDropDown.bottomOffset = CGPoint(x: 0, y:((genderDropDown.anchorView?.plainView.bounds.height)! + genderView.textField.frame.height + 30))
        genderDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.genderView.textField.text = item
            self.genderMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreGender = false
            self.isChangingUsername = false
            self.checkFields()
        }
        genderDropDown.width = genderView.textField.bounds.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.genderView.textField.frame.height))
        genderView.textField.rightView = paddingView
        genderView.textField.rightViewMode = UITextField.ViewMode.always
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
    }
}


struct EditInformationViewConstraints {
    
}
