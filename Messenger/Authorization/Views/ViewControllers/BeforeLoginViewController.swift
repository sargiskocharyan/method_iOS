//
//  ViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/21/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import Lottie
import FBSDKLoginKit
import FacebookLogin
import FBSDKCoreKit_Basics
import Firebase
import PhoneNumberKit
import DropDown

class BeforeLoginViewController: UIViewController, LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        //        viewModel?.loginWithFacebook(accessToken: result?.token, completion: { (response, error) in
        //            if error != nil {
        //
        //            } else {
        //
        //            }
        //        })
        activityIndicator.startAnimating()
        var token = ""
        if AccessToken.current != nil {
            token = AccessToken.current!.tokenString
        }
        viewModel?.loginWithFacebook(accessToken: token, completion: { (response, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error", errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else if response != nil {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                }
                
                let model = UserModel(name: response!.user.name, lastname: response!.user.lastname, username: response!.user.username, email: response!.user.email,  token: response!.token, id: response!.user.id, avatarURL: response!.user.avatarURL, phoneNumber: response!.user.phoneNumber, birthDate: response!.user.birthDate, tokenExpire: self.stringToDate(date: response!.tokenExpire), missedCallHistory: response!.user.missedCallHistory)
                SharedConfigs.shared.setIfLoginFromFacebook(isFromFacebook: true)
                UserDataController().saveUserSensitiveData(token: response!.token)
                UserDataController().populateUserProfile(model: model)
                self.registerDevice { (error) in
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
                }
            }
        })
        // fetchUserInfo()
    }
    func stringToDate(date:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        return parsedDate
    }
    func registerDevice(completion: @escaping (NetworkResponse?)->()) {
        RemoteNotificationManager.registerDeviceToken(pushDevicetoken: SharedConfigs.shared.deviceToken ?? "", voipDeviceToken: SharedConfigs.shared.voIPToken ?? "") { (error) in
            completion(error)
        }
    }
    
    func fetchUserInfo() -> Void {
        if (AccessToken.current != nil) {
            let graphRequest: GraphRequest = GraphRequest(graphPath: "/me", parameters:["fields": "id, first_name, last_name, name, email, picture"])
            graphRequest.start(completionHandler: { (connection, result, error) in
                
                if(error != nil) { self.showErrorAlert(title: "error".localized(), errorMessage: error!.localizedDescription)
                  }
                else
                {
                    self.dictionary = result as! [String : AnyObject]
                    let name = self.dictionary["name"] as! String
                    let token = AccessToken.current?.tokenString
                    print("name is -\(name)")
                    print("token is -\(token ?? "")")
                }
            })
        }
    }
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        print("")
    }
    
    
    //MARK: @IBOutlets
    @IBOutlet weak var logInWithFacebookButton: FBLoginButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var emailDescriptionLabel: UILabel!
    @IBOutlet weak var aboutPgLabel: UILabel!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var emaiCustomView: CustomTextField!
    @IBOutlet weak var animationView: UIView!
    @IBOutlet weak var animationTopConstraint: NSLayoutConstraint!
    @IBOutlet var storyboardView: UIView!
    @IBOutlet weak var phonaView: UIView!
    @IBOutlet weak var numberTextField: PhoneNumberTextField!
    @IBOutlet weak var changeModeButton: UIButton!
    @IBOutlet weak var borderView: UIView!
    
    
    //MARK: Properties
    var headerShapeView = HeaderShapeView()
    var bottomView = BottomShapeView()
    var viewModel: BeforeLoginViewModel?
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    var constant: CGFloat = 0
    var authRouter: AuthRouter?
    var dictionary: Dictionary<String, AnyObject> = [:]
    var isLoginWithEmail: Bool!
    let phoneNumberKit = PhoneNumberKit()
    let codeDropDown = DropDown()
    let codeMoreOrLessImageView = UIImageView()
    let buttonAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.darkGray,
        .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    //MARK: @IBAction
    @IBAction func continueButtonAction(_ sender: UIButton) {
        if isLoginWithEmail {
            checkEmail()
        } else {
            checkPhone()
        }
    } 
    
   
    //MARK: Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
        continueButton.setTitle("continue".localized(), for: .normal)
        emailDescriptionLabel.text = "email_will_be_used_to_confirm".localized()
        aboutPgLabel.text = "enter_your_email".localized()
        let attributeString = NSMutableAttributedString(string: "use_phone_number_for_login".localized(),
                                                        attributes: buttonAttributes)
        changeModeButton.setAttributedTitle(attributeString, for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyboardView.bringSubviewToFront(view)
        emaiCustomView.delagate = self
        for constraint in logInWithFacebookButton.constraints where constraint.firstAttribute == .height {
            constraint.constant = 35
        }
        navigationController?.isNavigationBarHidden = true
        numberTextField.withDefaultPickerUI = true
        numberTextField.withPrefix = true
        numberTextField.defaultRegion = "AM"
        numberTextField.withFlag = true
        numberTextField.withExamplePlaceholder = true
        continueButton.isEnabled = false
        continueButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        continueButton.titleLabel?.textColor = UIColor.lightGray
        self.numberTextField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .allEvents)
        showAnimation()
        self.hideKeyboardWhenTappedAround()
        setObservers()
        emaiCustomView.textField.returnKeyType = .done
        constant = animationTopConstraint.constant
        logInWithFacebookButton.permissions = ["public_profile", "email"]
        logInWithFacebookButton.delegate = self
        isLoginWithEmail = true
        numberTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
    
    func addImage(textField: UITextField, imageView: UIImageView) {
        textField.addSubview(imageView)
        imageView.image = UIImage(named: "more")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: textField.topAnchor, constant: 5).isActive = true
        imageView.rightAnchor.constraint(equalTo: textField.rightAnchor, constant: 0).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        imageView.isUserInteractionEnabled = true
    }
    
    override func viewDidLayoutSubviews() {
        self.emaiCustomView.handleRotate()
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
        continueButton.layer.cornerRadius = 8
        logInWithFacebookButton.layer.cornerRadius = 8
        
        logInWithFacebookButton.clipsToBounds = true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        if size.width > size.height {
            constant = -50
        } else {
            constant = 90
        }
    }
    
    //MARK: Helper methods
    func configureViews() {
        bottomWidth = view.frame.width * 0.6
        bottomHeight = view.frame.height * 0.08
        bottomView.frame = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        self.view.addSubview(bottomView)
        topWidth = view.frame.width * 0.83
        topHeight =  view.frame.height * 0.3
        self.view.addSubview(headerShapeView)
    }
    
    func disableContinueButton() {
        continueButton.isEnabled = false
        continueButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        continueButton.setTitleColor(.lightGray, for: .normal)
    }
    
    func enableContinueButton() {
        continueButton.isEnabled = true
        continueButton.backgroundColor = UIColor.clear
        continueButton.setTitleColor(.white, for: .normal)
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        do {
            let _ = try phoneNumberKit.parse(textField.text!)
            borderView.backgroundColor = .lightGray
            enableContinueButton()
        }
        catch {
            borderView.backgroundColor = .red
            disableContinueButton()
        }
    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            if self.view.frame.height - emailDescriptionLabel.frame.maxY < keyboardFrame!.height {
                animationTopConstraint.constant = isKeyboardShowing ? constant - (keyboardFrame!.height - (self.view.frame.height - emailDescriptionLabel.frame.maxY)) : constant
            } else {
                animationTopConstraint.constant = constant
            }
            UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                self.view.layoutIfNeeded()
            }, completion: nil)
        }
    }
       
    @IBAction func changeModeButtonAction(_ sender: UIButton) {
        isLoginWithEmail = !isLoginWithEmail
        if isLoginWithEmail {
            sender.setTitle("use_phone_number_for_login".localized(), for: .normal)
            phonaView.isHidden = true
            numberTextField.text = ""
            borderView.backgroundColor = .lightGray
            emaiCustomView.isHidden = false
            emailDescriptionLabel.text = "email_will_be_used_to_confirm".localized()
            aboutPgLabel.text = "enter_your_email".localized()
        } else {
            phonaView.isHidden = false
            emaiCustomView.isHidden = true
            emptyField(customView: emaiCustomView)
            sender.setTitle("use_email_for_login".localized(), for: .normal)
            emailDescriptionLabel.text = "phone_number_will_be_used".localized()
            aboutPgLabel.text = "enter_your_phone_number".localized()
        }
    }
    
    func emptyField(customView: CustomTextField) {
        disableContinueButton()
        customView.textField.text = ""
        customView.errorLabel.text = ""
        customView.topLabel.text = ""
        customView.textField.placeholder = customView.placeholder
    }
    
    func setObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardNotification), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func checkPhone() {
        Auth.auth().languageCode = "hy" //222222
        Auth.auth().settings?.isAppVerificationDisabledForTesting = false
        PhoneAuthProvider.provider().verifyPhoneNumber(numberTextField.text!, uiDelegate: nil) { (verificationID, error) in
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
            self.viewModel?.emailChecking(email: self.numberTextField.text!, completion: { (responseObject, error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error", errorMessage: error.rawValue)
                    }
                } else if let response = responseObject {
                    DispatchQueue.main.async {
                        self.authRouter?.showConfirmCodeViewController(email: nil, code: nil, isExists: response.mailExist, phoneNumber: self.numberTextField.text)
                        self.activityIndicator.stopAnimating()
                    }
                }
            })
        }
    }
    
    func checkEmail() {
        activityIndicator.startAnimating()
        viewModel!.emailChecking(email: emaiCustomView.textField.text!) { (responseObject, error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.activityIndicator.stopAnimating()
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if responseObject != nil {
                DispatchQueue.main.async {
                    self.authRouter?.showConfirmCodeViewController(email: self.emaiCustomView.textField.text!, code: responseObject!.code, isExists: responseObject!.mailExist, phoneNumber: nil)
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func showAnimation() {
        let checkMarkAnimation =  AnimationView(name:  "message")
        animationView.contentMode = .scaleAspectFit
        checkMarkAnimation.animationSpeed = 1
        checkMarkAnimation.frame = self.animationView.bounds
        checkMarkAnimation.loopMode = .loop
        checkMarkAnimation.play()
        self.animationView.addSubview(checkMarkAnimation)
    }
}

//MARK: Extension
extension BeforeLoginViewController: CustomTextFieldDelegate {
    func texfFieldDidChange(placeholder: String) {
        if placeholder == "email".localized() {
            if !emaiCustomView.textField.text!.isValidEmail() {
                emaiCustomView.errorLabel.text = emaiCustomView.errorMessage
                emaiCustomView.errorLabel.textColor = .red
                emaiCustomView.border.backgroundColor = .red
                disableContinueButton()
            } else {
                emaiCustomView.border.backgroundColor = .blue
                emaiCustomView.errorLabel.textColor = .blue
                emaiCustomView.errorLabel.text = emaiCustomView.successMessage
                enableContinueButton()
            }
        }
    }
}

