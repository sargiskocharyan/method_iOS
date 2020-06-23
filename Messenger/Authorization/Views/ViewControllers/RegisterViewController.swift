//
//  RegisterViewController.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown

class RegisterViewController: UIViewController {
    //MARK: @IBOutlets
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var usernameCustomView: CustomTextField!
    @IBOutlet weak var lastnameCustomView: CustomTextField!
    @IBOutlet weak var nameCustomView: CustomTextField!
    @IBOutlet weak var createAccountButton: UIButton!
    @IBOutlet weak var universityTextField: UITextField!
    
    //MARK: Properties
    var headerShapeView = HeaderShapeView()
    let viewModel = RegisterViewModel()
    let gradientColor = CAGradientLayer()
    var topWidth = CGFloat()
    var topHeight = CGFloat()
    let bottomView = BottomShapeView()
    var bottomWidth = CGFloat()
    var bottomHeight = CGFloat()
    var isMore = false
    let dropDown = DropDown()
    let moreOrLessImageView = UIImageView()
    var universities: [University] = []
    
    //MARK: @IBActions
    @IBAction func createAccountAction(_ sender: UIButton) {
        let id = self.universities.first { (university) -> Bool in
            university.name == self.universityTextField.text!
        }?._id
        viewModel.updateUser(name: nameCustomView.textField.text!, lastname: lastnameCustomView.textField.text!, username: usernameCustomView.textField.text!, university: id!) { (user, error, code) in
            if error != nil {
                if code == 401 {
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
                    let vc = CongratulationsViewController.instantiate(fromAppStoryboard: .main)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    @IBAction func skipButtonAction(_ sender: UIButton) {
        DispatchQueue.main.async {
            let vc = CongratulationsViewController.instantiate(fromAppStoryboard: .main) 
           self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    //MARK: Lifecycles
    override func viewDidLayoutSubviews() {
        universityTextField.underlined()
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
        createAccountButton.setGradientBackground(view: self.view, gradientColor)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        nameCustomView.delagate = self
        lastnameCustomView.delagate = self
        usernameCustomView.delagate = self
        addDropDown()
        getUniversities()
        skipButton.setTitle("skip".localized(), for: .normal)
        createAccountButton.setTitle("create_account".localized(), for: .normal)
        universityTextField.placeholder = "select_university".localized()
    }
    
    
    //MARK: Helper methodes
    func getUniversities() {
        viewModel.getUniversities { (responseObject, error, code) in
            if(error != nil) {
                if code == 401 {
                     let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                           let nav = UINavigationController(rootViewController: vc)
                           let window: UIWindow? = UIApplication.shared.windows[0]
                           window?.rootViewController = nav
                           window?.makeKeyAndVisible()
                }
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "error_message".localized(), message: error, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                    self.present(alert, animated: true)
                }
            } else if responseObject != nil {
                self.universities = responseObject!
                switch SharedConfigs.shared.appLang {
                case "am":
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.name
                    })
                case "ru":
                    self.dropDown.dataSource = self.universities.map({ (university) -> String in
                        university.nameRU
                    })
                case "en":
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
    func configureView() {
        bottomWidth = view.frame.width * 0.6
        bottomHeight = view.frame.height * 0.08
        bottomView.frame = CGRect(x: 0, y: view.frame.height - bottomHeight, width: bottomWidth, height: bottomHeight)
        self.view.addSubview(bottomView)
        topWidth = view.frame.width * 0.83
        topHeight =  view.frame.height * 0.3
        self.view.addSubview(headerShapeView)
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
        if placeholder == "username".localized() {
            if !usernameCustomView.textField.text!.isValidUsername() {
                usernameCustomView.errorLabel.text = usernameCustomView.errorMessage
                usernameCustomView.errorLabel.textColor = .red
                usernameCustomView.border.backgroundColor = .red
            } else {
                usernameCustomView.border.backgroundColor = .blue
                usernameCustomView.errorLabel.textColor = .blue
                usernameCustomView.errorLabel.text = usernameCustomView.successMessage
            }
        }
        
    }
}
