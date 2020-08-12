//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown

class RegisterViewController: UIViewController, UITextFieldDelegate {
    //MARK: @IBOutlets
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var usernameCustomView: CustomTextField!
    @IBOutlet weak var viewOnScroll: UIView!
    @IBOutlet weak var stackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var lastnameCustomView: CustomTextField!
    @IBOutlet weak var nameCustomView: CustomTextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var header: HeaderShapeView!
    @IBOutlet var storyboardView: UIView!
    @IBOutlet weak var headerTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var genderCustomView: CustomTextField!
    
    //MARK: Properties
    var headerShapeView = HeaderShapeView()
    var viewModel: RegisterViewModel?
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    let bottomView = BottomShapeView()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    let dropDown = DropDown()
    let moreOrLessImageView = UIImageView()
    var universities: [University] = []
    var constant: CGFloat = 0
    let button = UIButton()
    var authRouter: AuthRouter?
    var name: String?
    var lastname: String?
    var gender: String?
    var username: String?
    var signedUser = SharedConfigs.shared.signedUser
    var isMoreGender = false
    var isChangingUsername = false
    var isChangingGender = false
    
    //MARK: @IBActions
    @IBAction func createAccountAction(_ sender: UIButton) {
        viewModel!.updateUser(name: name, lastname: lastname, username: username, gender: gender) { (user, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if user != nil {
                DispatchQueue.main.async {
                    let userModel: UserModel = UserModel(name: user!.name, lastname: user!.lastname, username: user!.username, email: user!.email, token: SharedConfigs.shared.signedUser?.token ?? "", id: user!.id, avatarURL: user?.avatarURL, tokenExpire: SharedConfigs.shared.signedUser?.tokenExpire)
                    UserDataController().populateUserProfile(model: userModel)
                    self.authRouter?.showCongratulationsViewController()
                }
            }
        }
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        authRouter?.showCongratulationsViewController()
    }
    
    //MARK: Lifecycles
    override func viewDidLayoutSubviews() {
        print("viewDidLayoutSubviews")
        dropDown.width = button.frame.width
        nameCustomView.handleRotate()
        lastnameCustomView.handleRotate()
        usernameCustomView.handleRotate()
        let minRect = CGRect(x: 0, y: 0, width: 0, height: 0)
        let maxRectBottom = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        let maxRect = CGRect(x: self.view.frame.size.width - topWidth, y: 0, width: topWidth, height: topHeight)
        if (self.view.frame.height < self.view.frame.width) {
            headerShapeView.frame = minRect
            bottomView.frame = minRect
        } else {
            headerShapeView.frame = maxRect
            bottomView.frame = maxRectBottom
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
        setNeedsStatusBarAppearanceUpdate()
        self.navigationController?.navigationBar.isTranslucent = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        let navigationBar = self.navigationController?.navigationBar
        
        navigationBar?.shadowImage = nil
        navigationBar?.setBackgroundImage(nil, for: .default)
        navigationBar?.isTranslucent = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        .default
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        header.backgroundColor = .clear
        stackViewTopConstraint.constant = self.view.frame.height * 0.3
        self.navigationController?.isNavigationBarHidden = true
        createAccountButton.isEnabled = false
        constant = stackViewTopConstraint.constant
        nameCustomView.delagate = self
        lastnameCustomView.delagate = self
        usernameCustomView.delagate = self
        nameCustomView.textField.delegate = self
        lastnameCustomView.textField.delegate = self
        usernameCustomView.textField.delegate = self
        addDropDown()
        skipButton.setTitle("skip".localized(), for: .normal)
        createAccountButton.setTitle("continue".localized(), for: .normal)
        self.hideKeyboardWhenTappedAround()
        setObservers()
        disableUpdateInfoButton()
        nameCustomView.textField.addTarget(self, action: #selector(nameTextFieldAction), for: .editingChanged)
        usernameCustomView.textField.addTarget(self, action: #selector(usernameTextFieldAction), for: .editingChanged)
        lastnameCustomView.textField.addTarget(self, action: #selector(lastnameTextFieldAction), for: .editingChanged)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        dropDown.hide()
        moreOrLessImageView.image = UIImage(named: "more")
        if size.width > size.height {
            constant = 50
        } else {
            constant = size.height * 0.3
            stackViewTopConstraint.constant = CGFloat(constant)
        }
    }
    
    //MARK: Helper methodes
  
    func checkGender(_ signedUser: UserModel?) -> Bool? {
        if signedUser?.gender?.lowercased() != genderCustomView.textField.text?.lowercased() {
            if genderCustomView.textField.text == "" {
                gender = nil
                return nil
            } else {
                gender = genderCustomView.textField.text!.lowercased()
                return true
            }
        }
        if isChangingGender {
            gender = genderCustomView.textField.text!.lowercased()
            return true
        } else {
            gender = nil
            return nil
        }
    }
    
    func checkName(_ signedUser: UserModel?) -> Bool? {
        if signedUser?.name != nameCustomView.textField.text {
            if (nameCustomView.textField.text?.isValidNameOrLastname())! || nameCustomView.textField.text == "" {
                if (signedUser?.name == nil && nameCustomView.textField.text == "") {
                    name = nil
                    return nil
                } else {
                    name = nameCustomView.textField.text!
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
        if signedUser?.username != usernameCustomView.textField.text {
            if (usernameCustomView.textField.text?.isValidUsername())! || usernameCustomView.textField.text == "" {
                if (usernameCustomView.textField.text == "") {
                    self.usernameCustomView.errorLabel.text = ""
                    username = nil
                    completion(nil)
                    return
                } else {
                    if isChangingUsername {
                        self.usernameCustomView.errorLabel.text = ""
                        self.usernameCustomView.borderColor = .red
                        viewModel?.checkUsername(username: usernameCustomView.textField.text!, completion: { (responseObject, error) in
                            if responseObject != nil && responseObject?.usernameExists == false {
                                DispatchQueue.main.async {
                                    self.username = self.usernameCustomView.textField.text!
                                    self.usernameCustomView.errorLabel.text = "correct_username".localized()
                                    self.usernameCustomView.errorLabel.textColor = .blue
                                    completion(true)
                                }
                            } else if responseObject != nil && responseObject?.usernameExists == true {
                                DispatchQueue.main.async {
                                    self.usernameCustomView.errorLabel.text = "this_username_is_taken".localized()
                                    self.username = nil
                                    self.usernameCustomView.errorLabel.textColor = .red
                                    completion(false)
                                }
                            }
                        })
                    }
                }
            } else {
                self.usernameCustomView.errorLabel.text = "the_username_must_contain_at_least_4_letters".localized()
                self.usernameCustomView.errorLabel.textColor = .red
                username = nil
                completion(false)
                return
            }
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
        if  signedUser?.lastname != lastnameCustomView.textField.text {
            if (lastnameCustomView.textField.text?.isValidNameOrLastname())! || lastnameCustomView.textField.text == "" {
                if (signedUser?.lastname == nil && lastnameCustomView.textField.text == "") {
                    lastname = nil
                    return nil
                } else {
                    lastname = lastnameCustomView.textField.text!
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
    
    func disableUpdateInfoButton() {
        createAccountButton.isEnabled = false
        createAccountButton.titleLabel?.textColor = UIColor.white
        createAccountButton.backgroundColor = UIColor.lightGray
    }
    
    func enableUpdateInfoButton() {
        createAccountButton.backgroundColor = .clear
        createAccountButton.titleLabel?.textColor = .white
        createAccountButton.isEnabled = true
    }
    
    func checkFields() {
        checkUsername(signedUser) { (isVsyoLav) in
            if isVsyoLav != false && self.checkGender(self.signedUser) != false && self.checkName(self.signedUser) != false && self.checkLastname(self.signedUser) != false {
                if self.name != nil || self.lastname != nil || self.username != nil || self.gender != nil {
                    self.enableUpdateInfoButton()
                } else {
                    self.disableUpdateInfoButton()
                }
            }
            else {
                self.disableUpdateInfoButton()
            }
        }
    }
    
    @objc func nameTextFieldAction() {
        nameCustomView.errorLabel.isHidden = (nameCustomView.textField.text == "")
        isChangingUsername = false
        checkFields()
    }
    
    @objc func usernameTextFieldAction() {
        isChangingUsername = true
        checkFields()
    }
    
    @objc func lastnameTextFieldAction() {
        lastnameCustomView.errorLabel.isHidden = (lastnameCustomView.textField.text == "")
        isChangingUsername = false
        checkFields()
    }
    
    func raiseStackView(_ keyboardFrame: CGRect?, _ isKeyboardShowing: Bool, _ customView: UIView) {
        if self.view.frame.height - (constant + customView.frame.maxY) < keyboardFrame!.height {
            stackViewTopConstraint.constant = isKeyboardShowing ? constant - (keyboardFrame!.height - (self.view.frame.height - (constant + customView.frame.maxY + 15))) : constant
        } else {
            stackViewTopConstraint.constant = constant
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            
            if usernameCustomView.textField.isFirstResponder {
                raiseStackView(keyboardFrame, isKeyboardShowing, usernameCustomView)
            } else if lastnameCustomView.textField.isFirstResponder {
                raiseStackView(keyboardFrame, isKeyboardShowing, lastnameCustomView)
            } else if nameCustomView.textField.isFirstResponder {
                raiseStackView(keyboardFrame, isKeyboardShowing, nameCustomView)
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
    
    func configureView() {
        bottomWidth = view.frame.width * 0.6
        bottomHeight = view.frame.height * 0.08
        bottomView.frame = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        topWidth = view.frame.width * 0.83
        topHeight =  view.frame.height * 0.3
    }
    
   func addImage(textField: UITextField, imageView: UIImageView) {
        textField.addSubview(imageView)
        imageView.image = UIImage(named: "more")
        imageView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 5).isActive = true
        imageView.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 22).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 25).isActive = true
        imageView.isUserInteractionEnabled = true
        imageView.anchor(top: textField.topAnchor, paddingTop: 5, bottom: nil, paddingBottom: 0, left: nil, paddingLeft: 0, right: textField.rightAnchor, paddingRight: 0, width: 25, height: 22)
    }
    
    func addButton() {
        button.addTarget(self, action: #selector(imageTapped), for: .touchUpInside)
        self.genderCustomView.textField.addSubview(button)
        button.topAnchor.constraint(equalTo: genderCustomView.textField.topAnchor, constant: 0).isActive = true
        button.rightAnchor.constraint(equalTo: genderCustomView.textField.rightAnchor, constant: 0).isActive = true
        button.leftAnchor.constraint(equalTo: genderCustomView.textField.leftAnchor, constant: 0).isActive = true
        button.heightAnchor.constraint(equalToConstant: genderCustomView.textField.frame.height).isActive = true
        button.widthAnchor.constraint(equalToConstant: genderCustomView.textField.frame.width).isActive = true
        button.anchor(top: genderCustomView.textField.topAnchor, paddingTop: 0, bottom: genderCustomView.textField.bottomAnchor, paddingBottom: 0, left: genderCustomView.textField.leftAnchor, paddingLeft: 0, right: genderCustomView.textField.rightAnchor, paddingRight: 0, width: genderCustomView.textField.frame.width, height: genderCustomView.textField.frame.height)
    }
    
    func addDropDown() {
        addButton()
        addImage(textField: genderCustomView.textField, imageView: moreOrLessImageView)
        dropDown.anchorView = button
        dropDown.direction = .any
        dropDown.dataSource = ["Male", "Female"]
        dropDown.bottomOffset = CGPoint(x: 0, y:((dropDown.anchorView?.plainView.bounds.height)! + genderCustomView.textField.frame.height + 30))
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.genderCustomView.textField.text = item
            self.moreOrLessImageView.image = UIImage(named: "more")
            self.isMoreGender = false
            self.isChangingUsername = false
            self.isChangingGender = true
            self.checkFields()
        }
        dropDown.cancelAction = { [unowned self] in
            self.moreOrLessImageView.image = UIImage(named: "more")
            self.isMoreGender = false
        }
        dropDown.width = genderCustomView.textField.frame.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.genderCustomView.textField.frame.height))
        genderCustomView.textField.rightView = paddingView
        genderCustomView.textField.rightViewMode = UITextField.ViewMode.always
    }
    
    @objc func imageTapped() {
        checkFields()
        if isMoreGender {
            isMoreGender = false
            dropDown.hide()
            moreOrLessImageView.image = UIImage(named: "more")
        }
        else { 
            isMoreGender = true
            dropDown.show()
            moreOrLessImageView.image = UIImage(named: "less")
        }
    }
    
}

@IBDesignable
class GradientView: UIView {
    @IBInspectable var firstColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    @IBInspectable var secondColor: UIColor = UIColor.clear {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    @IBInspectable var isHorizontal: Bool = true {
        didSet {
            updateView()
        }
    }
    func updateView() {
        let layer = self.layer as! CAGradientLayer
        layer.colors = [firstColor, secondColor].map{$0.cgColor}
        if (self.isHorizontal) {
            layer.startPoint = CGPoint(x: 0, y: 0.5)
            layer.endPoint = CGPoint (x: 1, y: 0.5)
        } else {
            layer.startPoint = CGPoint(x: 0.5, y: 0)
            layer.endPoint = CGPoint (x: 0.5, y: 1)
        }
    }
    
}


//MARK: Extension
extension RegisterViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
        if placeholder == "name".localized() {
            if !nameCustomView.textField.text!.isValidNameOrLastname() {
                nameCustomView.errorLabel.text = nameCustomView.errorMessage
                nameCustomView.errorLabel.textColor = .red
                nameCustomView.border.backgroundColor = .red
            } else {
                nameCustomView.border.backgroundColor = .blue
                nameCustomView.errorLabel.textColor = .blue
                nameCustomView.errorLabel.text = nameCustomView.successMessage
            }
        }
        if placeholder == "lastname".localized() {
            if !lastnameCustomView.textField.text!.isValidNameOrLastname() {
                lastnameCustomView.errorLabel.text = lastnameCustomView.errorMessage
                lastnameCustomView.errorLabel.textColor = .red
                lastnameCustomView.border.backgroundColor = .red
            } else {
                lastnameCustomView.border.backgroundColor = .blue
                lastnameCustomView.errorLabel.textColor = .blue
                lastnameCustomView.errorLabel.text = lastnameCustomView.successMessage
            }
        }
//        if placeholder == "username".localized() {
//            if !usernameCustomView.textField.text!.isValidUsername() {
//                usernameCustomView.errorLabel.text = usernameCustomView.errorMessage
//                usernameCustomView.errorLabel.textColor = .red
//                usernameCustomView.border.backgroundColor = .red
//            } else {
//
//                usernameCustomView.border.backgroundColor = .blue
//                usernameCustomView.errorLabel.textColor = .blue
//                usernameCustomView.errorLabel.text = usernameCustomView.successMessage
//            }
//        }
        
    }
}
