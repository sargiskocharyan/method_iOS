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

class BeforeLoginViewController: UIViewController, UITextFieldDelegate, LoginButtonDelegate {
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        
       // fetchUserInfo()
    }
    
    func fetchUserInfo() -> Void {
        if (AccessToken.current != nil) {
            let graphRequest: GraphRequest = GraphRequest(graphPath: "/me", parameters:["fields": "id, first_name, last_name, name, email, picture"])
            graphRequest.start(completionHandler: { (connection, result, error) in
                
                if(error != nil) { self.showErrorAlert(title: "error".localized(), errorMessage: error!.localizedDescription)
                  }
                else
                {
                    print("Result is:\(result ?? "")")
                    self.dictionary = result as! [String : AnyObject]
                    let name = self.dictionary["name"] as! String
//                    let email = self.dictionary["email"] as! String
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
    @IBOutlet weak var numberCustomView: CustomTextField!
    @IBOutlet weak var codeCustomView: CustomTextField!
    @IBOutlet weak var changeModeButton: UIButton!
    
    
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
    var isMoreCode: Bool!
    let codeMoreOrLessImageView = UIImageView()
    //MARK: @IBAction
    @IBAction func continueButtonAction(_ sender: UIButton) {
        checkEmail()
    } 
    
   
    //MARK: Lifecycle methods
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureViews()
        continueButton.setTitle("continue".localized(), for: .normal)
        emailDescriptionLabel.text = "email_will_be_used_to_confirm".localized()
        aboutPgLabel.text = "enter_your_email".localized()
        changeModeButton.setTitle("use_phone_number_for_login".localized(), for: .normal)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storyboardView.bringSubviewToFront(view)
        emaiCustomView.delagate = self
        emaiCustomView.textField.delegate = self
        navigationController?.isNavigationBarHidden = true
        continueButton.isEnabled = false
        continueButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        continueButton.titleLabel?.textColor = UIColor.lightGray
//        self.emaiCustomView.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .allEvents)
        showAnimation()
        self.hideKeyboardWhenTappedAround()
        setObservers()
        emaiCustomView.textField.returnKeyType = .done
        constant = animationTopConstraint.constant
        logInWithFacebookButton.permissions = ["public_profile", "email"]
        logInWithFacebookButton.delegate = self
        isLoginWithEmail = true
        codeCustomView.textField.keyboardType = .numbersAndPunctuation
        numberCustomView.textField.keyboardType = .numberPad
        let tapOnCodeView = UITapGestureRecognizer(target: self, action: #selector(handleCodeViewTap(_:)))
        codeCustomView.delagate = self
        numberCustomView.delagate = self
        isMoreCode = false
        codeCustomView.isUserInteractionEnabled = true
        codeCustomView.addGestureRecognizer(tapOnCodeView)
        codeCustomView.textField.isEnabled = false
        addCodeDropDown()
    }
   
    @objc func handleCodeViewTap(_ gesture: UITapGestureRecognizer) {
        codeDropDown.width = codeCustomView.textField.frame.width
        if isMoreCode {
            isMoreCode = false
            codeDropDown.hide()
            codeMoreOrLessImageView.image = UIImage(named: "more")
        }
        else {
            isMoreCode = true
            codeDropDown.show()
            codeMoreOrLessImageView.image = UIImage(named: "less")
        }
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
    
    func addCodeDropDown() {
        addImage(textField: codeCustomView.textField, imageView: codeMoreOrLessImageView)
        codeDropDown.anchorView = codeCustomView.textField
        codeDropDown.direction = .any
        let allCountries = phoneNumberKit.allCountries().filter { (country) -> Bool in
            return country != "AZ" && country != "TR"
        }
        let countryCodes = allCountries.map { (country) -> String in
            return "+\(phoneNumberKit.countryCode(for: country) ?? 374)"
        }
        codeDropDown.dataSource = countryCodes
        codeDropDown.bottomOffset = CGPoint(x: 0, y:((codeDropDown.anchorView?.plainView.bounds.height)! + codeCustomView.textField.frame.height + 30))
        codeDropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            self.codeCustomView.textField.text = item
            self.codeMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreCode = false
//            self.checkFields()
        }
        codeDropDown.width = codeCustomView.textField.bounds.width
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 30, height: self.codeCustomView.textField.frame.height))
        codeCustomView.textField.rightView = paddingView
        codeCustomView.textField.rightViewMode = UITextField.ViewMode.always
        codeDropDown.cancelAction = { [unowned self] in
            self.codeMoreOrLessImageView.image = UIImage(named: "more")
            self.isMoreCode = false
        }
    }
    
    override func viewDidLayoutSubviews() {
        self.emaiCustomView.handleRotate()
        codeDropDown.width = codeCustomView.textField.frame.width
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
    
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        if textField.text!.isValidEmail() {
//            checkEmail()
//        }
//        return true
//    }
    
    func disableContinueButton() {
        continueButton.isEnabled = false
        continueButton.backgroundColor = UIColor.lightGray.withAlphaComponent(0.4)
        continueButton.titleLabel?.textColor = UIColor.lightGray
    }
    
    func enableContinueButton() {
        continueButton.isEnabled = true
        continueButton.backgroundColor = UIColor.clear
        continueButton.titleLabel?.textColor = UIColor.white
    }
    
//    @objc func textFieldDidChange(textField: UITextField){
//        if isLoginWithEmail {
//            if !textField.text!.isValidEmail() {
//               disableContinueButton()
//            } else {
//               enableContinueButton()
//            }
//        } else {
//
//        }
//    }
    
    @objc func handleKeyboardNotification(notification: NSNotification) {
        if let userInfo = notification.userInfo {
            let keyboardFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as AnyObject).cgRectValue
            let isKeyboardShowing = notification.name == UIResponder.keyboardWillShowNotification
            if isLoginWithEmail {
                if self.view.frame.height - emailDescriptionLabel.frame.maxY < keyboardFrame!.height {
                    animationTopConstraint.constant = isKeyboardShowing ? constant - (keyboardFrame!.height - (self.view.frame.height - emailDescriptionLabel.frame.maxY)) : constant
                } else {
                    animationTopConstraint.constant = constant
                }
                UIView.animate(withDuration: 0, delay: 0, options: UIView.AnimationOptions.curveEaseOut, animations: {
                    self.view.layoutIfNeeded()
                }, completion: nil)
            } else {
                if !(isKeyboardShowing && animationTopConstraint.constant != constant) {
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
        }
    }
       
    @IBAction func changeModeButtonAction(_ sender: UIButton) {
        isLoginWithEmail = !isLoginWithEmail
        if isLoginWithEmail {
            sender.setTitle("use_phone_number_for_login".localized(), for: .normal)
            phonaView.isHidden = true
            emptyField(customView: codeCustomView)
            emptyField(customView: numberCustomView)
            emaiCustomView.isHidden = false
            emailDescriptionLabel.text = "email_will_be_used_to_confirm".localized()
            aboutPgLabel.text = "enter_your_email".localized()
        } else {
            phonaView.isHidden = false
            emaiCustomView.isHidden = true
            emptyField(customView: emaiCustomView)
            sender.setTitle("use_email_for_login".localized(), for: .normal)
            emailDescriptionLabel.text = "phone_number_will_be_used_to_confirm".localized()
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
       
       func checkEmail() {
//           activityIndicator.startAnimating()
//           viewModel!.emailChecking(email: emaiCustomView.textField.text!) { (responseObject, error) in
//               if (error != nil) {
//                   DispatchQueue.main.async {
//                       self.activityIndicator.stopAnimating()
//                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
//                   }
//               } else if responseObject != nil {
//                   DispatchQueue.main.async {
//                    self.authRouter?.showConfirmCodeViewController(email: self.emaiCustomView.textField.text!, code: responseObject!.code, isExists: responseObject!.mailExist)
//                       self.activityIndicator.stopAnimating()
//                   }
//               }
//           }
        Auth.auth().languageCode = "am";
        Auth.auth().settings?.isAppVerificationDisabledForTesting = true
        PhoneAuthProvider.provider().verifyPhoneNumber("+37494021274", uiDelegate: nil) { (verificationID, error) in
          
            if let error = error {
                print(error.localizedDescription)
                return
            }
          print("succes")
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

