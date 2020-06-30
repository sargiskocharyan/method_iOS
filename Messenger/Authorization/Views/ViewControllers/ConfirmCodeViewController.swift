//
//  ConfirmCodeViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/23/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class ConfirmCodeViewController: UIViewController {
    
    //MARK: @IBOutlets
    @IBOutlet weak var registerOrLoginLabel: UILabel!
    @IBOutlet weak var enterCodeLabel: UILabel!
    @IBOutlet weak var CodeField: UITextField!
    @IBOutlet weak var resendCodeButton: UIButton!
    @IBOutlet weak var continueButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: properties
    var email: String?
    var code: String?
    var viewModel = ConfirmCodeViewModel()
    var headerShapeView = HeaderShapeView()
    var isExists: Bool?
    let gradientColor = CAGradientLayer()
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    let bottomView = BottomShapeView()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    let buttonAttributes: [NSAttributedString.Key: Any] = [
        .font: UIFont.systemFont(ofSize: 14),
        .foregroundColor: UIColor.darkGray,
        .underlineStyle: NSUnderlineStyle.single.rawValue]
    
    //MARK: @IBAction
    @IBAction func resendCodeAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        viewModel.resendCode(email: email!) { (code, error) in
            if error != nil {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                    self.activityIndicator.stopAnimating()
                }
            } else if code != nil {
                DispatchQueue.main.async {
                    self.CodeField.text = code
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
        DispatchQueue.main.async {
            self.activityIndicator.startAnimating()
        }
        if isExists! {
            viewModel.login(email: email!, code: CodeField.text!) { (token, loginResponse, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.activityIndicator.stopAnimating()
                    }
                } else if (token != nil && loginResponse != nil) {
                    let model = UserModel(name: loginResponse!.user.name, lastname: loginResponse!.user.lastname, username: loginResponse!.user.username, email: loginResponse!.user.email, university: loginResponse!.user.university, token: token!, id: loginResponse!.user.id, avatarURL: loginResponse!.user.avatarURL)
                    UserDataController().saveUserSensitiveData(token: token!)
                    UserDataController().populateUserProfile(model: model)
                    DispatchQueue.main.async {
                        let vc = MainTabBarController.instantiate(fromAppStoryboard: .main)
                        self.view.window?.rootViewController = vc
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized(), message: "incorrect_code".localized(), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            viewModel.register(email: email!, code: CodeField.text!) { (token, loginResponse, error)  in
                if error != nil {
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.activityIndicator.stopAnimating()
                    }
                } else if token != nil {
                    SharedConfigs.shared.signedUser = loginResponse?.user
                    UserDataController().saveUserSensitiveData(token: token!)
                    UserDataController().saveUserInfo()
                    DispatchQueue.main.async {
                        let vc = RegisterViewController.instantiate(fromAppStoryboard: .main)
                        self.navigationController?.pushViewController(vc, animated: true)
                        self.activityIndicator.stopAnimating()
                    }
                } else {
                   DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized(), message: "incorrect_code".localized(), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    //MARK: Lifecycle methodes
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        CodeField.text = code
        CodeField.placeholder = "enter_code".localized()
        continueButton.setTitle("continue".localized(), for: .normal)
        enterCodeLabel.text = "code".localized()
        if isExists! {
            registerOrLoginLabel.text = "login".localized()
        } else {
            registerOrLoginLabel.text = "register".localized()
        }
        let attributeString = NSMutableAttributedString(string: "resend_code".localized(),
                                                        attributes: buttonAttributes)
        resendCodeButton.setAttributedTitle(attributeString, for: .normal)
        continueButton.isEnabled = true
        self.CodeField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        
    }
    
    override func viewDidLayoutSubviews() {
        CodeField.underlined()
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
        continueButton.setGradientBackground(view: self.view, gradientColor)
        continueButton.layer.cornerRadius = 8
        setImage()
    }
    
    
    //MARK: Helper methods
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
        if textField.text != "" {
            continueButton.isEnabled = true
        } else {
            continueButton.isEnabled = false
        }
    }
    
    @objc func tapDetected() {
        navigationController?.popViewController(animated: true)
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
