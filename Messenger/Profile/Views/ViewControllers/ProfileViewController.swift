//
//  ProfileViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit
import DropDown
import AVFoundation
import CoreData
import FBSDKLoginKit


protocol ProfileViewControllerDelegate: AnyObject {
    func changeLanguage(key: String)
}

protocol ProfileViewDelegate: AnyObject {
    func changeMode()
}

class ProfileViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var hidePersonalDataLabel: UILabel!
    @IBOutlet weak var switchMode: UISwitch!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var contactView: UIView!
    @IBOutlet weak var contactsLabel: UILabel!
    @IBOutlet weak var notificationLabel: UILabel!
    @IBOutlet weak var phoneTextLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var darkModeLabel: UILabel!
    @IBOutlet weak var lastnameTextLabel: UILabel!
    @IBOutlet weak var languageLabel: UILabel!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var notificationView: UIView!
    @IBOutlet weak var darkModeView: UIView!
    @IBOutlet weak var logoutView: UIView!
    @IBOutlet weak var headerUsernameLabel: UILabel!
    @IBOutlet weak var flagImageView: UIImageView!
    @IBOutlet weak var notificationCountLabel: UILabel!
    @IBOutlet weak var logOutLanguageVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var logOutDarkModeVerticalConstraint: NSLayoutConstraint!
    @IBOutlet weak var headerEmailLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    //MARK: Properties
    var dropDown = DropDown()
    var viewModel: ProfileViewModel?
    let center = UNUserNotificationCenter.current()
    var imagePicker = UIImagePickerController()
    weak var delegate: ProfileViewControllerDelegate?
    var mainRouter: MainRouter?
    weak var profileDelegate: ProfileViewDelegate?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        imagePicker.delegate = self
        setupUI()
        addGestures()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkInformation()

        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    //MARK: Helper methods
    @IBAction func editButton(_ sender: Any) {
        mainRouter?.showEditViewController()
    }
    
    @IBAction func changePhoneAction(_ sender: Any) {
        mainRouter?.showChangeEmailViewController(changingSubject: .phone)
    }
    
    func setupUI() {
        setFlagImage()
        setBorder(view: contactView)
        setBorder(view: languageView)
        setBorder(view: darkModeView)
        setBorder(view: logoutView)
        setBorder(view: notificationView)
        checkVersion()
        setImage()
        configureImageView()
        defineSwithState()
        localizeStrings()
    }
    
    func setImage() {
        ImageCache.shared.getImage(url: SharedConfigs.shared.signedUser?.avatarURL ?? "", id: SharedConfigs.shared.signedUser?.id ?? "", isChannel: false) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
    }
    
    func localizeStrings() {
        hidePersonalDataLabel.text = "hide_personal_data".localized()
        headerEmailLabel.text = "email".localized()
        headerUsernameLabel.text = "username".localized()
        phoneTextLabel.text = "phone:".localized()
        nameTextLabel.text = "name:".localized()
        lastnameTextLabel.text = "lastname:".localized()
        contactsLabel.text = "contacts".localized()
        languageLabel.text = "language".localized()
        darkModeLabel.text = "dark_mode".localized()
        notificationLabel.text = "notifications".localized()
        logoutLabel.text = "log_out".localized()
        self.navigationController?.navigationBar.topItem?.title = "profile".localized()
    }
    
    func defineSwithState() {
        if SharedConfigs.shared.mode == AppMode.dark.rawValue {
            switchMode.isOn = true
        } else {
            switchMode.isOn = false
        }
    }
    
    func setFlagImage() {
        if SharedConfigs.shared.appLang == AppLangKeys.Eng {
            flagImageView.image = UIImage(named: Languages.english)
        } else if SharedConfigs.shared.appLang == AppLangKeys.Rus {
            flagImageView.image = UIImage(named: Languages.russian)
        } else if SharedConfigs.shared.appLang == AppLangKeys.Arm {
            flagImageView.image = UIImage(named: Languages.armenian)
        }
    }
    
    @IBAction func changeEmailAction(_ sender: Any) {
        mainRouter?.showChangeEmailViewController(changingSubject: .email)
    }
    
    @IBAction func selectMode(_ sender: UISwitch) {
        profileDelegate?.changeMode()
        if sender.isOn {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .dark
            }
            SharedConfigs.shared.setMode(selectedMode: AppMode.dark.rawValue)
        } else {
            UIApplication.shared.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
            SharedConfigs.shared.setMode(selectedMode: AppMode.light.rawValue)
        }
        self.viewDidLoad()
    }
    
     func addCameraView(_ cameraView: UIView) {
        cameraView.translatesAutoresizingMaskIntoConstraints = false
        cameraView.backgroundColor = UIColor.camerViewColor
        cameraView.bottomAnchor.constraint(equalTo: userImageView.bottomAnchor, constant: .zero).isActive = true
        cameraView.rightAnchor.constraint(equalTo: userImageView.rightAnchor, constant: .zero).isActive = true
        cameraView.heightAnchor.constraint(equalToConstant: ProfileViewConstants.cameraViewConstant).isActive = true
        cameraView.widthAnchor.constraint(equalToConstant: ProfileViewConstants.cameraViewConstant).isActive = true
        cameraView.isUserInteractionEnabled = true
        cameraView.contentMode = . scaleAspectFill
        cameraView.layer.cornerRadius = ProfileViewConstants.cameraViewCornerRadius
        cameraView.clipsToBounds = true
    }
    
    func configureImageView() {
        let cameraView = UIView()
        view.addSubview(cameraView)
        userImageView.backgroundColor = .clear
        addCameraView(cameraView)
        let cameraImageView = UIImageView()
        cameraImageView.image = UIImage(named: "camera")
        cameraView.addSubview(cameraImageView)
        cameraImageView.translatesAutoresizingMaskIntoConstraints = false
        cameraImageView.backgroundColor = UIColor.camerViewColor
        cameraImageView.bottomAnchor.constraint(equalTo: cameraView.bottomAnchor, constant: -ProfileViewConstants.cameraImageViewConstant).isActive = true
        cameraImageView.rightAnchor.constraint(equalTo: cameraView.rightAnchor, constant: -ProfileViewConstants.cameraImageViewConstant).isActive = true
        cameraImageView.topAnchor.constraint(equalTo: cameraView.topAnchor, constant: ProfileViewConstants.cameraImageViewConstant).isActive = true
        cameraImageView.leftAnchor.constraint(equalTo: cameraView.leftAnchor, constant: ProfileViewConstants.cameraImageViewConstant).isActive = true
        cameraImageView.isUserInteractionEnabled = true
        let tapCamera = UITapGestureRecognizer(target: self, action: #selector(self.handleCameraTap(_:)))
        cameraImageView.addGestureRecognizer(tapCamera)
        userImageView.contentMode = . scaleAspectFill
        userImageView.layer.cornerRadius = ProfileViewConstants.cameraImageViewConrnerRadius
        userImageView.clipsToBounds = true
    }
    
    func addGestures() {
        let tapLogOut = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        logoutView.addGestureRecognizer(tapLogOut)
        let tapContacts = UITapGestureRecognizer(target: self, action: #selector(self.handleContactsTap(_:)))
        contactView.addGestureRecognizer(tapContacts)
        let tapLanguage = UITapGestureRecognizer(target: self, action: #selector(self.handleLanguageTab(_:)))
        languageView.addGestureRecognizer(tapLanguage)
        let tapImage = UITapGestureRecognizer(target: self, action: #selector(self.handleImageTap(_:)))
        let tapNotification = UITapGestureRecognizer(target: self, action: #selector(self.tapOnNotification(_:)))
        notificationView.addGestureRecognizer(tapNotification)
        userImageView.isUserInteractionEnabled = true
        userImageView.addGestureRecognizer(tapImage)
    }
    
    @objc func tapOnNotification(_ sender: UITapGestureRecognizer? = nil) {
        if SharedConfigs.shared.getNumberOfNotifications() > .zero {
            mainRouter?.showNotificationListViewController()
        }
    }
    
    @objc func handleCameraTap(_ sender: UITapGestureRecognizer? = nil) {
        AVCaptureDevice.requestAccess(for: AVMediaType.video) { response in
            if response {
                print("Permission allowed")
            } else {
                print("Permission don't allowed")
            }
        }
        self.showAlert(title: nil, message: "choose_one_of_this_app_to_upload_photo".localized(), buttonTitle1: "camera".localized(), buttonTitle2: "album".localized(), buttonTitle3: nil, completion1: {
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.imagePicker.delegate = self
                self.imagePicker.sourceType = .camera;
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }, completion2: {
            if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
                self.imagePicker.sourceType = .savedPhotosAlbum
                self.imagePicker.allowsEditing = false
                self.present(self.imagePicker, animated: true, completion: nil)
            }
        }, completion3: nil)
    }
    
    func addCloseButton(_ imageView: UIImageView) {
        let closeButton = UIButton()
        imageView.addSubview(closeButton)
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.topAnchor.constraint(equalTo: imageView.topAnchor, constant: ProfileViewConstants.closeButtonTop).isActive = true
        closeButton.rightAnchor.constraint(equalTo: imageView.rightAnchor, constant: ProfileViewConstants.closeButtonRight).isActive = true
        closeButton.heightAnchor.constraint(equalToConstant: ProfileViewConstants.closeButtonSize).isActive = true
        closeButton.widthAnchor.constraint(equalToConstant: ProfileViewConstants.closeButtonSize).isActive = true
        closeButton.isUserInteractionEnabled = true
        closeButton.setImage(UIImage(named: "closeColor"), for: .normal)
        closeButton.addTarget(self, action: #selector(dismissFullscreenImage), for: .touchUpInside)
    }
    
     func addDeleteMessageButton(_ imageView: UIImageView) {
        let deleteImageButton = UIButton()
        imageView.addSubview(deleteImageButton)
        deleteImageButton.translatesAutoresizingMaskIntoConstraints = false
        deleteImageButton.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: ProfileViewConstants.deleteImageButtonBottom).isActive = true
        deleteImageButton.centerXAnchor.constraint(equalTo: imageView.centerXAnchor).isActive = true
        deleteImageButton.heightAnchor.constraint(equalToConstant: ProfileViewConstants.deleteImageButtonSize).isActive = true
        deleteImageButton.widthAnchor.constraint(equalToConstant: ProfileViewConstants.deleteImageButtonSize).isActive = true
        deleteImageButton.isUserInteractionEnabled = true
        deleteImageButton.setImage(UIImage(named: "trash"), for: .normal)
        deleteImageButton.addTarget(self, action: #selector(deleteAvatar), for: .touchUpInside)
    }
    
    @objc func handleImageTap(_ sender: UITapGestureRecognizer? = nil) {
        if SharedConfigs.shared.signedUser?.avatarURL == nil {
            return
        }
        let imageView = UIImageView(image: userImageView.image)
        addCloseButton(imageView)
        imageView.backgroundColor = UIColor.inputColor
        addDeleteMessageButton(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.tag = ProfileViewConstants.imageViewTag
        self.view.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.topAnchor.constraint(equalTo: view.topAnchor, constant: .zero).isActive = true
        imageView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: .zero).isActive = true
        imageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: .zero).isActive = true
        imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: .zero).isActive = true
        imageView.isUserInteractionEnabled = true
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func deleteAvatar() {
        viewModel!.deleteAvatar { (error) in
            if (error != nil) {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
                return
            } else {
                let signedUser = SharedConfigs.shared.signedUser
                let user = UserModel(name: signedUser?.name, lastname: signedUser?.lastname, username: signedUser?.username, email: signedUser?.email, token: signedUser?.token, id: signedUser!.id, avatarURL: nil)
                UserDataController().populateUserProfile(model: user)
                DispatchQueue.main.async {
                    self.dismissFullscreenImage()
                    self.userImageView.image = UIImage(named: "noPhoto")
                }
            }
        }
    }
    
    @objc func dismissFullscreenImage() {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        view.viewWithTag(ProfileViewConstants.imageViewTag)?.removeFromSuperview()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        activityIndicator.startAnimating()
        picker.dismiss(animated: true, completion: nil)
        guard let image = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        viewModel!.uploadImage(image: image) { (error, avatarURL) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    self.activityIndicator.stopAnimating()
                }
            } else {
                ImageCache.shared.getImage(url: avatarURL ?? "", id: SharedConfigs.shared.signedUser?.id ?? "", isChannel: false) { (image) in
                    DispatchQueue.main.async {
                        self.userImageView.image = image
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        }
    }
    
    @objc func handleContactsTap(_ sender: UITapGestureRecognizer? = nil) {
        mainRouter?.showContactsViewControllerFromProfile()
    }
    
    @objc func handleLanguageTab(_ sender: UITapGestureRecognizer? = nil) {
        addDropDown()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer? = nil) {
        if UserDefaults.standard.object(forKey: Keys.IS_LOGIN_FROM_FACEBOOK) as? Bool == false {
            viewModel!.logout(deviceUUID: UIDevice.current.identifierForVendor!.uuidString) { (error) in
                UserDefaults.standard.set(false, forKey: Keys.IS_REGISTERED)
                DispatchQueue.main.async {
                    self.deleteAllRecords()
                    UserDataController().logOutUser()
                    AuthRouter().assemblyModule()
                }
                SocketTaskManager.shared.disconnect{}
            }
        } else {
            UserDefaults.standard.set(false, forKey: Keys.IS_REGISTERED)
            DispatchQueue.main.async {
                self.deleteAllRecords()
                LoginManager().logOut()
                UserDataController().logOutUser()
                AuthRouter().assemblyModule()
            }
            SocketTaskManager.shared.disconnect{}
            
        }
    }
    
    func setBorder(view: UIView) {
        view.layer.masksToBounds = true
        view.layer.borderWidth = ProfileViewConstants.borderWidth
        let color = UIColor.lightGray.withAlphaComponent(UIColor.colorAlpha)
        view.layer.borderColor = color.cgColor
    }
    
    func addDropDown() {
        dropDown.anchorView = languageView 
        dropDown.direction = .any
        dropDown.width = languageView.frame.width
        dropDown.dataSource = [Languages.english, Languages.russian, Languages.armenian]
        dropDown.bottomOffset = CGPoint(x: .zero, y:(dropDown.anchorView?.plainView.bounds.height)!)
        dropDown.selectionAction = { [unowned self] (index: Int, item: String) in
            if item == Languages.russian {
                self.flagImageView.image = UIImage(named: Languages.russian)
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Rus)
            } else if item == Languages.english {
                self.flagImageView.image = UIImage(named: Languages.english)
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Eng)
            } else if item == Languages.armenian {
                self.flagImageView.image = UIImage(named: Languages.armenian)
                SharedConfigs.shared.setAppLang(lang: AppLangKeys.Arm)
            }
            self.delegate?.changeLanguage(key: AppLangKeys.Arm)
            self.viewDidLoad()
            self.mainRouter?.callDetailViewController?.tableView?.reloadData()
        }
        dropDown.backgroundColor = UIColor.dropDownColor
        dropDown.cellNib = UINib(nibName: ProfileViewConstants.nameOfDropdownCell, bundle: nil)
        dropDown.customCellConfiguration = { (index: Index, item: String, cell: DropDownCell) -> Void in
            guard let cell = cell as? CustomCell else { return }
            cell.countryImageView.image = UIImage(named: "\(item)")
        }
        dropDown.show()
    }
    
    func deleteAllRecords() {
        let delegate = UIApplication.shared.delegate as! AppDelegate
        let context = delegate.persistentContainer.viewContext
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: CallModelConstants.callEntity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        do {
            try context.execute(deleteRequest)
            try context.save()
        } catch {
            print ("There was an error")
        }
    }
    
    func changeNotificationNumber() {
        UIApplication.shared.applicationIconBadgeNumber = SharedConfigs.shared.getNumberOfNotifications()
        if notificationCountLabel != nil {
            notificationCountLabel.text = "\(SharedConfigs.shared.getNumberOfNotifications())"
        }
    }
    
    func checkInformation() {
        let user = SharedConfigs.shared.signedUser
        changeNotificationNumber()
        if user?.name == nil {
            nameLabel.text = "not_defined".localized()
            nameLabel.textColor = .lightGray
        } else {
            nameLabel.text = user?.name
            nameLabel.textColor = UIColor.color
        }
        if user?.lastname == nil {
            lastnameLabel.text = "not_defined".localized()
            lastnameLabel.textColor = .lightGray
        } else {
            lastnameLabel.text = user?.lastname
            lastnameLabel.textColor = UIColor.color
        }
        if user?.email == nil {
            emailLabel.text = "not_defined".localized()
            emailLabel.textColor = .lightGray
        } else {
            emailLabel.text = user?.email
            emailLabel.textColor = UIColor.color
        }
        if user?.phoneNumber == nil {
            phoneLabel.text = "not_defined".localized()
            phoneLabel.textColor = .lightGray
        } else {
            phoneLabel.text = user?.phoneNumber
            phoneLabel.textColor = UIColor.color
        }
        if user?.username == nil {
            usernameLabel.text = "not_defined".localized()
            usernameLabel.textColor = .lightGray
        } else {
            usernameLabel.text = user?.username
            usernameLabel.textColor = UIColor.color
        }
    }
    
    private func checkVersion() {
        if #available(iOS 13.0, *) {
            logOutDarkModeVerticalConstraint.priority = UILayoutPriority(rawValue: ProfileViewConstants.higiPriority)
            logOutLanguageVerticalConstraint.priority = UILayoutPriority(rawValue: ProfileViewConstants.lowPriority)
        } else {
            logOutDarkModeVerticalConstraint.priority = UILayoutPriority(rawValue: ProfileViewConstants.lowPriority)
            logOutLanguageVerticalConstraint.priority = UILayoutPriority(rawValue: ProfileViewConstants.higiPriority)
            darkModeView.isHidden = true
        }
    }    
}

//MARK: Extension
extension ProfileViewController: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }
}

extension ProfileViewController: ChangeEmailViewControllerDelegate {
    func setEmail(email: String) {
        emailLabel.text = email
    }
    
    func setPhone(phone: String) {
        phoneLabel.text = phone
        phoneLabel.textColor = UIColor.color
    }
}


struct ProfileViewConstants {
    static let cameraViewConstant: CGFloat = 30
    static let cameraViewCornerRadius: CGFloat = 15
    static let cameraImageViewConstant: CGFloat = 5
    static let cameraImageViewConrnerRadius: CGFloat = 50
    static let closeButtonTop: CGFloat = 20
    static let closeButtonRight: CGFloat = -10
    static let closeButtonSize: CGFloat = 25
    static let deleteImageButtonBottom: CGFloat = -40
    static let deleteImageButtonSize: CGFloat = 30
    static let imageViewTag = 3
    static let borderWidth: CGFloat = 1
    static let higiPriority: Float = 990
    static let lowPriority: Float = 900
    static let nameOfDropdownCell = "CustomCell"
}
