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
    @IBOutlet weak var updateInformationButton: UIButton!
    @IBOutlet weak var usernameView: CustomTextField!
    @IBOutlet weak var nameView: CustomTextField!
    @IBOutlet weak var lastnameView: CustomTextField!
    @IBOutlet weak var hideDataSwitch: UISwitch!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var viewOnScroll: UIView!
    @IBOutlet weak var genderView: CustomTextField!
    @IBOutlet weak var universityView: CustomTextField!
    @IBOutlet weak var phoneCustomView: CustomTextField!
    @IBOutlet weak var infoTextView: UITextView!
    @IBOutlet weak var emailView: CustomTextField!
    
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
    let signedUser = SharedConfigs.shared.signedUser
    let datePicker = UIDatePicker()
    var didSomethingChanges: Bool = false
    var gender: String? = nil
    var birthDate: String? = nil
    var name: String?
    var lastname: String?
    var username: String?
    var email: String?
    var phoneNumber: String?
    var universityId: String?
    var info: String?
    var checkInfo: Bool?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        birdthdateView.isUserInteractionEnabled = true
        let tapBirthdate = UITapGestureRecognizer(target: self, action: #selector(self.handleBirthDateViewTap(_:)))
        birdthdateView.textField.addGestureRecognizer(tapBirthdate)
        infoTextView.layer.borderColor = UIColor.lightGray.cgColor
        infoTextView.layer.borderWidth = 1.0
        infoTextView.layer.masksToBounds = true
        constant = stackViewTopConstraint.constant
        nameView.delagate = self
        nameView.textField.delegate = self
        lastnameView.textField.delegate = self
        usernameView.textField.delegate = self
        lastnameView.delagate = self
        genderView.delagate = self
        usernameView.delagate = self
        infoTextView.delegate = self
        phoneCustomView.delagate = self
        birdthdateView.delagate = self
        emailView.delagate = self
        addUniversityDropDown()
        getUniversities()
        addGenderDropDown()
        nameView.textField.text = SharedConfigs.shared.signedUser?.name
        lastnameView.textField.text = SharedConfigs.shared.signedUser?.lastname
        usernameView.textField.text = SharedConfigs.shared.signedUser?.username
        genderView.textField.text = SharedConfigs.shared.signedUser?.gender
        infoTextView.text = signedUser?.info
        emailView.textField.text = SharedConfigs.shared.signedUser?.email
        phoneCustomView.textField.text = SharedConfigs.shared.signedUser?.phoneNumber
        genderView.textField.text = signedUser?.gender
        birdthdateView.textField.text = stringToDate(date: SharedConfigs.shared.signedUser?.birthDate) ?? ""
        setUniversityName()
        updateInformationButton.setTitle("update_information".localized(), for: .normal)
        self.hideKeyboardWhenTappedAround()
        setObservers()
        setTopLabels()
        updateInformationButton.isEnabled = false
        updateInformationButton.titleLabel?.textColor = UIColor.white
        updateInformationButton.backgroundColor = UIColor.lightGray
        nameView.textField.addTarget(self, action: #selector(nameTextFieldAction), for: .editingChanged)
        usernameView.textField.addTarget(self, action: #selector(usernameTextFieldAction), for: .editingChanged)
        lastnameView.textField.addTarget(self, action: #selector(lastnameTextFieldAction), for: .editingChanged)
        phoneCustomView.textField.addTarget(self, action: #selector(phoneTextFieldAction), for: .editingChanged)
        birdthdateView.textField.addTarget(self, action: #selector(birthDateTextFieldAction), for: .editingChanged)
        emailView.textField.addTarget(self, action: #selector(emailTextFieldAction), for: .editingChanged)
        hideDataSwitch.isOn = SharedConfigs.shared.isHidden
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
        genderDropDown.width = genderView.textField.frame.width
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

     func checkUniverity(_ id: String?, _ signedUser: UserModel?) -> Bool? {
        if id != nil && signedUser?.university?._id != id {
            universityId = id!
            return true
        } else if signedUser?.university?._id == nil && id != nil {
            universityId = id!
            return true
        }
        universityId = nil
        return nil
    }
    
     func checkGender(_ signedUser: UserModel?) -> Bool? {
        if  signedUser?.gender?.lowercased() != genderView.textField.text?.lowercased() {
            if signedUser?.gender == nil && genderView.textField.text == "" {
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
        if nameView.textField.text != "" {
            nameView.topLabel.text = "name".localized()
        }
        if lastnameView.textField.text != "" {
            lastnameView.topLabel.text = "lastname".localized()
        }
        if usernameView.textField.text != "" {
            usernameView.topLabel.text = "username".localized()
        }
        if birdthdateView.textField.text != "" {
            birdthdateView.topLabel.text = "birthdate".localized()
        }
        if phoneCustomView.textField.text != "" {
            phoneCustomView.topLabel.text = "number".localized()
        }
        if emailView.textField.text != "" {
            emailView.topLabel.text = "email".localized()
        }
        if universityView.textField.text != "" {
            universityView.topLabel.text = "university".localized()
        }
        if genderView.textField.text != "" {
            genderView.topLabel.text = "gender".localized()
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if signedUser?.info != infoTextView.text {
            if (signedUser?.info == nil && infoTextView.text == "") {
                checkInfo = nil
                info = nil
            } else {
                checkInfo = true
                info = infoTextView.text
            }
        } else {
            info = nil
            checkInfo = nil
        }
        checkFields()
    }
    
     func checkBirthdate(_ signedUser: UserModel?) -> Bool? {
        if  stringToDate(date: SharedConfigs.shared.signedUser?.birthDate) != birdthdateView.textField.text {
            if signedUser?.birthDate == nil && birdthdateView.textField.text == "" {
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
    
     func checkEmail(_ signedUser: UserModel?) -> Bool? {
        if  signedUser?.email != emailView.textField.text {
            if (emailView.textField.text?.isValidEmail())! {
                email = emailView.textField.text!
                return true
            } else {
                email = nil
                return false
            }
        }
        email = nil
        return nil
    }
    
     func checkName(_ signedUser: UserModel?) -> Bool? {
        if signedUser?.name != nameView.textField.text {
            if (nameView.textField.text?.isValidNameOrLastname())! || nameView.textField.text == "" {
                if (signedUser?.name == nil && nameView.textField.text == "") {
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
    
     func checkUsername(_ signedUser: UserModel?) -> Bool? {
        if signedUser?.username != usernameView.textField.text {
            if (usernameView.textField.text?.isValidUsername())! {
                username = usernameView.textField.text!
                return true
            } else {
                username = nil
                return false
            }
        }
        username = nil
        return nil
    }
    
    func checkPhoneNumber(_ signedUser: UserModel?) -> Bool? {
        if  signedUser?.phoneNumber != phoneCustomView.textField.text {
            if (phoneCustomView.textField.text?.isValidNumber())! || phoneCustomView.textField.text == "" {
                if (signedUser?.phoneNumber == nil && phoneCustomView.textField.text == "") {
                    phoneNumber = nil
                    return nil
                } else {
                    phoneNumber = phoneCustomView.textField.text!
                    return true
                }
            } else {
                phoneNumber = nil
                return false
            }
        }
        phoneNumber = nil
        return nil
    }
    
     func checkLastname(_ signedUser: UserModel?) -> Bool? {
        if  signedUser?.lastname != lastnameView.textField.text {
            if (lastnameView.textField.text?.isValidNameOrLastname())! || lastnameView.textField.text == "" {
                if (signedUser?.lastname == nil && lastnameView.textField.text == "") {
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
    
    func checkFields() {
        var id: String?
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            id = self.universities.first { (university) -> Bool in
                university.name == self.universityView.textField.text!
                }?._id
        case AppLangKeys.Rus:
            id = self.universities.first { (university) -> Bool in
                university.nameRU == self.universityView.textField.text!
                }?._id
        default:
            id = self.universities.first { (university) -> Bool in
                university.nameEN == self.universityView.textField.text!
                }?._id
        }
         
       
        if checkUniverity(id, signedUser) != false && (checkGender(signedUser) != false) &&  checkBirthdate(signedUser) != false &&   checkName(signedUser) != false && checkEmail(signedUser) != false && checkUsername(signedUser) != false && checkLastname(signedUser) != false && checkPhoneNumber(signedUser) != false && checkInfo != false {
            if name != nil || lastname != nil || username != nil || gender != nil || birthDate != nil || phoneNumber != nil || universityId != nil || info != nil {
                updateInformationButton.backgroundColor = .clear
                updateInformationButton.titleLabel?.textColor = .white
                updateInformationButton.isEnabled = true
            } else {
                updateInformationButton.isEnabled = false
                updateInformationButton.titleLabel?.textColor = UIColor.white
                updateInformationButton.backgroundColor = UIColor.lightGray
            }
        } else {
            updateInformationButton.isEnabled = false
            updateInformationButton.titleLabel?.textColor = UIColor.white
            updateInformationButton.backgroundColor = UIColor.lightGray
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
    
    @objc func birthDateTextFieldAction() {
       checkFields()
    }
    
    @objc func emailTextFieldAction() {
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
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
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
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
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
        datePicker.backgroundColor = .white
        datePicker.datePickerMode = .date
        let viewUnderDatePicker = UIView()
        viewUnderDatePicker.tag = 30
        viewUnderDatePicker.backgroundColor = .white
        viewUnderDatePicker.isUserInteractionEnabled = true
        let tapViewUnderDatePicker = UITapGestureRecognizer(target: self, action: #selector(self.handleTapViewUnderDatePicker(_:)))
        let okLabel = UILabel()
        okLabel.text = "ok".localized()
        viewUnderDatePicker.addSubview(okLabel)
        okLabel.bottomAnchor.constraint(equalTo: viewUnderDatePicker.bottomAnchor, constant: 84).isActive = true
        okLabel.leftAnchor.constraint(equalTo: viewUnderDatePicker.leftAnchor, constant: self.view.frame.width / 2 - 15).isActive = true
        okLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        okLabel.widthAnchor.constraint(equalToConstant: 30).isActive = true
        okLabel.isUserInteractionEnabled = true
        okLabel.anchor(top: nil, paddingTop: 0, bottom: viewUnderDatePicker.bottomAnchor, paddingBottom: 84, left: viewUnderDatePicker.leftAnchor, paddingLeft: self.view.frame.width / 2 - 15, right: nil, paddingRight: 0, width: 30, height: 30)
        viewUnderDatePicker.addGestureRecognizer(tapViewUnderDatePicker)
        view.addSubview(viewUnderDatePicker)
        viewUnderDatePicker.addSubview(datePicker)
        viewUnderDatePicker.topAnchor.constraint(equalTo: view.topAnchor, constant: 0).isActive = true
        viewUnderDatePicker.centerXAnchor.constraint(equalToSystemSpacingAfter: view.centerXAnchor, multiplier: 1).isActive = true
        viewUnderDatePicker.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 1).isActive = true
        viewUnderDatePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        viewUnderDatePicker.isUserInteractionEnabled = true
        viewUnderDatePicker.anchor(top: view.topAnchor, paddingTop: 0, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: self.view.frame.width, height: 250)
        datePicker.centerYAnchor.constraint(equalToSystemSpacingBelow: view.centerYAnchor, multiplier: 1).isActive = true
        datePicker.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 0).isActive = true
        datePicker.heightAnchor.constraint(equalToConstant: 250).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
        datePicker.isUserInteractionEnabled = true
        datePicker.anchor(top: nil, paddingTop: 100, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: view.rightAnchor, paddingRight: 0, width: self.view.frame.width, height: 250)
    }
    
    func addImage(textField: UITextField, imageView: UIImageView) {
        textField.addSubview(imageView)
        imageView.image = UIImage(named: "more")
        imageView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 5).isActive = true
        imageView.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.isUserInteractionEnabled = true
        imageView.anchor(top: textField.topAnchor, paddingTop: 5, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: textField.rightAnchor, paddingRight: 0, width: 25, height: 20)
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
    
    @IBAction func hidePersonalData(_ sender: UISwitch) {
        editInformatioViewModel.hideData(isHideData: sender.isOn) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error!.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else {
                DispatchQueue.main.async {
                    SharedConfigs.shared.setIsHidden(selectIsHidden: sender.isOn)
                }
            }
        }
    }
    
    @IBAction func universityTextFieldAction(_ sender: Any) {
        var id: String?
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            id = self.universities.first { (university) -> Bool in
                university.name == self.universityView.textField.text!
                }?._id
        case AppLangKeys.Rus:
            id = self.universities.first { (university) -> Bool in
                university.nameRU == self.universityView.textField.text!
                }?._id
        default:
            id = self.universities.first { (university) -> Bool in
                university.nameEN == self.universityView.textField.text!
                }?._id
        }
        if id != nil {
            updateInformationButton.isEnabled = true
            updateInformationButton.backgroundColor = .clear
            updateInformationButton.titleLabel?.textColor = .white
        } else {
            updateInformationButton.isEnabled = false
            updateInformationButton.titleLabel?.textColor = UIColor.lightGray
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
        editInformatioViewModel.editInformation(name: name, lastname: lastname, username: username, phoneNumber: phoneNumber, info: info, gender: gender, birthDate: birthDate, email: email, university: universityId) { (user, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if user != nil {
                DispatchQueue.main.async {
                    let userModel: UserModel = UserModel(name: user!.name, lastname: user!.lastname, username: user!.username, email: user!.email, university: user!.university, token: SharedConfigs.shared.signedUser?.token ?? "", id: user!.id, avatarURL: user?.avatarURL, phoneNumber: user?.phoneNumber, birthDate: user?.birthDate, gender: user?.gender, info: user?.info, tokenExpire: SharedConfigs.shared.signedUser?.tokenExpire)
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
    
    func setUniversityName() {
        switch SharedConfigs.shared.appLang {
        case AppLangKeys.Arm:
            universityView.textField.text = SharedConfigs.shared.signedUser?.university?.name
        case AppLangKeys.Rus:
            universityView.textField.text = SharedConfigs.shared.signedUser?.university?.nameRU
        case AppLangKeys.Eng:
            universityView.textField.text = SharedConfigs.shared.signedUser?.university?.nameEN
        default:
            universityView.textField.text = SharedConfigs.shared.signedUser?.university?.nameEN
        }
    }
    
    func getUniversities() {
        viewModel.getUniversities { (responseObject, error) in
            if(error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
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
        addButtonOnUniversityTextField(button: universityButton, textField: universityView.textField)
        addImage(textField: universityView.textField, imageView: universityMoreOrLessImageView)
        universityDropDown.anchorView = universityButton
        universityDropDown.direction = .any
        universityDropDown.bottomOffset = CGPoint(x: 0, y:((universityDropDown.anchorView?.plainView.bounds.height)! + universityView.textField.frame.height + 30))
        universityDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.universityView.textField.text = item
            self.universityMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreUniversity = false
            var id: String?
                  switch SharedConfigs.shared.appLang {
                  case AppLangKeys.Arm:
                      id = self.universities.first { (university) -> Bool in
                          university.name == self.universityView.textField.text!
                          }?._id
                  case AppLangKeys.Rus:
                      id = self.universities.first { (university) -> Bool in
                          university.nameRU == self.universityView.textField.text!
                          }?._id
                  default:
                      id = self.universities.first { (university) -> Bool in
                          university.nameEN == self.universityView.textField.text!
                          }?._id
                  }
                  if id != nil {
                    self.updateInformationButton.isEnabled = true
                    self.updateInformationButton.backgroundColor = .clear
                    self.updateInformationButton.titleLabel?.textColor = .white
                  } else {
                    self.updateInformationButton.isEnabled = false
                    self.updateInformationButton.titleLabel?.textColor = UIColor.lightGray
                  }
        }
        universityDropDown.width = universityView.textField.frame.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.universityView.textField.frame.height))
        universityView.textField.rightView = paddingView
        universityView.textField.rightViewMode = UITextField.ViewMode.always
        universityDropDown.cancelAction = { [unowned self] in
            self.universityMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreUniversity = false
        }
    }
    
    func addGenderDropDown() {
        addButtonOnGenderTextField(button: genderButton, textField: genderView.textField)
        addImage(textField: genderView.textField, imageView: genderMoreOrLessImageView)
        genderDropDown.anchorView = genderButton
        genderDropDown.direction = .any
        genderDropDown.dataSource = ["Male", "Female"]
        genderDropDown.bottomOffset = CGPoint(x: 0, y:((genderDropDown.anchorView?.plainView.bounds.height)! + genderView.textField.frame.height + 30))
        genderDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.genderView.textField.text = item
            self.genderMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreGender = false
            if item.lowercased() != SharedConfigs.shared.signedUser?.gender?.lowercased() {
                self.updateInformationButton.isEnabled = true
                self.updateInformationButton.backgroundColor = .clear
                self.updateInformationButton.titleLabel?.textColor = .white
            }
        }
        genderDropDown.width = genderView.textField.frame.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.universityView.textField.frame.height))
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
        
        if placeholder == "email".localized() {
                   if !emailView.textField.text!.isValidEmail() {
                       emailView.errorLabel.text = emailView.errorMessage
                       emailView.errorLabel.textColor = .red
                       emailView.border.backgroundColor = .red
                   } else {
                       emailView.border.backgroundColor = .blue
                       emailView.errorLabel.textColor = .blue
                       emailView.errorLabel.text = emailView.successMessage
                   }
               }
    }
}
