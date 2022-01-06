//
//  ConfirmCodeViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/23/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import Firebase

class ConfirmCodeViewController: UIViewController, UITextFieldDelegate {
    
    //MARK: @IBOutlets
    @IBOutlet weak var registerOrLoginLabel: UILabel!
    @IBOutlet weak var enterCodeLabel: UILabel!
    @IBOutlet weak var CodeField: UITextField!
    @IBOutlet weak var resendCodeButton: UIButton!
//    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var registerOrLogintTopConstraint: NSLayoutConstraint!
    
//    @IBOutlet weak var continueButtonBottomConstraint: NSLayoutConstraint!
    //MARK: properties
    var constant: CGFloat = 0
    var email: String?
    var code: String?
    var phoneNumber: String?
    var viewModel: ConfirmCodeViewModel?
    var headerShapeView = HeaderShapeView()
    var isExists: Bool?
    let gradientColor = CAGradientLayer()
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    let bottomView = BottomShapeView()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    var authRouter: AuthRouter?
    let buttonAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.darkGray,
        .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    //MARK: @IBAction
    @IBAction func resendCodeAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        if phoneNumber != nil {
            Auth.auth().languageCode = "en" //222222
            Auth.auth().settings?.isAppVerificationDisabledForTesting = false
            PhoneAuthProvider.provider().verifyPhoneNumber(phoneNumber!, uiDelegate: nil) { (verificationID, error) in
                if let error = error {
                    self.showErrorAlert(title: "error", errorMessage: error.localizedDescription)
                    return
                }
                UserDefaults.standard.set(verificationID, forKey: "authVerificationID")
                let currentUser = Auth.auth().currentUser
                currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
                  if let error = error {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error", errorMessage: error.localizedDescription)
                    }
                    return;
                  }
                }
            }
        }
        
        viewModel!.resendCode(email: (email ?? phoneNumber)! ) { (code, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else if code != nil {
                DispatchQueue.main.async {
//                    self.CodeField.text = code
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    @IBAction func codeFieldChanged(_ sender: UITextField) {
        if sender.text != "" {
            enterCodeLabel.isHidden = false
        } else {
            enterCodeLabel.isHidden = true
        }
    }
    
    @IBAction func continueAction(_ sender: UIButton) {
        if email != nil {
            confirmEmailCode()
        } else {
            confirmPhoneCode()
        }
    }
    
    //MARK: Lifecycle methodes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            constant = 30
        } else {
            constant = 150
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CodeField.placeholder = "enter_code".localized()
        CodeField.underlined()
//        continueButton.setTitle("continue".localized(), for: .normal)
        enterCodeLabel.text = "code".localized()
        CodeField.delegate = self
        if isExists! {
            registerOrLoginLabel.text = "login".localized()
        } else {
            registerOrLoginLabel.text = "register".localized()
        }
        let attributeString = NSMutableAttributedString(string: "resend_code".localized(),
                                                        attributes: buttonAttributes)
        resendCodeButton.setAttributedTitle(attributeString, for: .normal)
//        continueButton.isEnabled = true
        self.CodeField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        self.hideKeyboardWhenTappedAround()
        constant = registerOrLogintTopConstraint.constant
        setObservers()
        CodeField.textContentType = .oneTimeCode
        CodeField.becomeFirstResponder()
    }
    
    override func viewDidLayoutSubviews() {
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
        self.gradientColor.removeFromSuperlayer()
//        continueButton.setGradientBackground(view: self.view, gradientColor)
//        continueButton.layer.cornerRadius = 8
        setImage()
    }
    
    
    //MARK: Helper methods
    
    func confirmPhoneCode() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        self.viewModel?.signInWithFirebase(code: CodeField.text!, completion: { (authResult, error) in
            if let error = error {
                self.showErrorAlert(title: "error", errorMessage: error.localizedDescription)
                return
            }
            DispatchQueue.main.async {
                self.activityIndicator.stopAnimating()
                self.viewModel?.loginWithPhoneNumber(number: self.phoneNumber!.replacingOccurrences(of: " ", with: ""), completion: { (response, error) in
                    if let error = error {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error", errorMessage: error.rawValue)
                        }
                    } else if let response = response {
                        self.parseData(response)
                    }
                })
            }
        })
    }
    
    func parseData(_ loginResponse: LoginResponse?) {
        self.viewModel?.parseUserData(loginResponse, loginResponse?.token, completion: { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                DispatchQueue.main.async {
                    MainRouter().assemblyModule()
                    self.activityIndicator.stopAnimating()
                }
            }
        })
    }
    
    func loginUser() {
        viewModel!.login(email: email!, code: CodeField.text!) { (token, loginResponse, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else if (token != nil && loginResponse != nil) {
                self.parseData(loginResponse)
            } else {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message`".localized(), errorMessage: "incorrect_code".localized())
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func registerUser() {
        viewModel!.register(email: email!, code: CodeField.text!) { (token, loginResponse, error)  in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else if token != nil {
                self.viewModel?.saveUserInfo(loginResponse, token)
                self.viewModel?.registerDevice { (error) in
                    if error != nil {
                        DispatchQueue.main.async {
                            self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                            self.activityIndicator.stopAnimating()
                        }
                    } else {
                        DispatchQueue.main.async {
                            self.authRouter?.showRegisterViewController()
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: "incorrect_code".localized())
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func confirmEmailCode() {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        if isExists! {
            loginUser()
        } else {
            registerUser()
        }
    }
    
    func configureView() {
        bottomWidth = view.frame.width * 0.6
        bottomHeight = view.frame.height * 0.08
        bottomView.frame = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        self.view.addSubview(bottomView)
        topWidth = view.frame.width * 0.83
        topHeight =  view.frame.height * 0.3
        self.view.addSubview(headerShapeView)
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        if textField.text?.isEmpty == false {
//            continueButton.isEnabled = true
            if email != nil && textField.text?.count == 4 {
                confirmEmailCode()
            } else if textField.text?.count == 6 {
                confirmPhoneCode()
            }
        } else {
//            continueButton.isEnabled = false
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
//            if isKeyboardShowing {
//                continueButtonBottomConstraint.constant = (keyboardFrame?.height ?? 0) + 10
//            } else {
//                continueButtonBottomConstraint.constant = 50
//            }
//            if self.view.frame.height - resendCodeButton.frame.maxY < keyboardFrame!.height {
//                registerOrLogintTopConstraint.constant = isKeyboardShowing ? constant - (keyboardFrame!.height - (self.view.frame.height - resendCodeButton.frame.maxY)) : constant
//            } else {
//                registerOrLogintTopConstraint.constant = constant
//            }
//            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
//                self.view.layoutIfNeeded()
//            }, completion: nil)
        }
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func tapDetected() {
        navigationController?.popViewController(animated: true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        if textField.text?.count == 4 {
            confirmEmailCode()
        }
        return true
    }
    
    func setImage() {
        let rect = CGRect(x: self.view.frame.width - 120, y: 40, width: 30, height: 30)
        let imageView = UIImageView(frame: rect)
        imageView.image = UIImage(named: "white@_")
        if headerShapeView.subviews.count >= 1 {
            headerShapeView.subviews.forEach({ $0.removeFromSuperview() })
        }
        headerShapeView.addSubview(imageView)
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(tapDetected))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(singleTap)
        
    }
}
