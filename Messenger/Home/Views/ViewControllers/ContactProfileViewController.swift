//
//  ContactProfileViewController.swift
//  Messenger
//
//  Created by Employee1 on 7/7/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

protocol ContactProfileDelegate: class {
    func addNewContact(contact: User)
    func removeContact()
}

protocol ContactProfileViewControllerDelegate: class {
    func handleVideoCallClick()
}
class ContactProfileViewController: UIViewController {
    
    @IBOutlet weak var videoCallButton: UIButton!
    @IBOutlet weak var addToContactButton: UIButton!
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var usernameTextLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var nameTextLabel: UILabel!
    @IBOutlet weak var lastnameTextLabel: UILabel!
    @IBOutlet weak var phoneTextLabel: UILabel!
    @IBOutlet weak var genderTextLabel: UILabel!
    @IBOutlet weak var birthDateTextLabel: UILabel!
    @IBOutlet weak var infoTextLabel: UILabel!
    @IBOutlet weak var lastnameLabel: UILabel!
    @IBOutlet weak var addressTextLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    var contact: User?
    var id: String?
    var viewModel: ContactsViewModel?
    weak var delegate: ContactProfileDelegate?
    weak var callDelegate: ContactProfileViewControllerDelegate?
    var onContactPage: Bool?
    var tabBar: MainTabBarController?
    var nc: UINavigationController?
    var callListViewController: CallListViewController?
    var fromChat: Bool?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        if onContactPage! {
            addToContactButton.setImage(UIImage(systemName: "person.badge.minus.fill"), for: .normal)
            addToContactButton.addTarget(self, action: #selector(removeFromContacts), for: .touchUpInside)
        } else {
            addToContactButton.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus"), for: .normal)
            addToContactButton.addTarget(self, action: #selector(addToContact), for: .touchUpInside)
        }
        if tabBar!.onCall || !onContactPage! {
            videoCallButton.isEnabled = false
        } else {
            videoCallButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tabBar = tabBarController as? MainTabBarController
        viewModel = tabBar?.contactsViewModel
        nc = tabBar?.viewControllers?[0] as? UINavigationController
        callListViewController = nc?.viewControllers[0] as? CallListViewController
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 40
        userImageView.clipsToBounds = true
        infoView.layer.borderColor = UIColor.lightGray.cgColor
        infoView.layer.borderWidth = 1.0
        infoView.layer.masksToBounds = true
        getUserInformation()
        sendMessageButton.addTarget(self, action: #selector(startMessage), for: .touchUpInside)
        
        sendMessageButton.backgroundColor = .clear
       
    }
    
    @objc func startMessage() {
        if fromChat! {
            navigationController?.popViewController(animated: false)
        } else {
            let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
            vc.id = contact?._id
            vc.name = contact?.name
            vc.username = contact?.username
            vc.avatar = contact?.avatarURL
            navigationController?.pushViewController(vc, animated: true)
            
        }
    }
    
    func getUserInformation() {
        callListViewController?.viewModel.getuserById(id: id!) { (user, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else if user != nil {
                self.contact = user
                DispatchQueue.main.async {
                    self.configureView()
                }
            }
        }
    }
    
    @objc func removeFromContacts() {
        viewModel?.removeContact(id: id!, completion: { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else {
                self.onContactPage = false
                DispatchQueue.main.async {
                    self.addToContactButton.setImage(UIImage(systemName: "person.crop.circle.fill.badge.plus"), for: .normal)
                    self.addToContactButton.addTarget(self, action: #selector(self.addToContact), for: .touchUpInside)
                    self.viewModel?.removeContactFromCoreData(id: self.id!, completion: { (error) in
                        self.delegate?.removeContact()
                    })
                }
            }
        })
    }
    
    @IBAction func startVideoCall(_ sender: Any) {
        let tabBar = tabBarController as! MainTabBarController
        if !tabBar.onCall {
            tabBar.handleCallClick(id: id!, name: contact!.name ?? contact!.username!)
            
            callListViewController?.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: id!)
        } else {
            tabBar.handleClickOnSamePerson()
        }
    }
    
    func sort() {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        for i in 0..<callListViewController!.viewModel.calls.count {
            for j in i..<callListViewController!.viewModel.calls.count {
                let firstDate = callListViewController!.viewModel.calls[i].time
                let secondDate = callListViewController?.viewModel.calls[j].time
                if firstDate.compare(secondDate!).rawValue == -1 {
                    let temp = callListViewController!.viewModel.calls[i]
                    callListViewController!.viewModel.calls[i] = callListViewController!.viewModel.calls[j] 
                    callListViewController!.viewModel.calls[j] = temp
                }
            }
        }
    }
    
    @objc func addToContact() {
        viewModel!.addContact(id: contact!._id!) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
                
            } else {
                DispatchQueue.main.async {
                    self.viewModel?.addContactToCoreData(newContact: self.contact!, completion: { (error) in
                        if error != nil {
                            print(error as Any)
                        } else {
                            print("All is well!!!!")
                             self.delegate?.addNewContact(contact: self.contact!)
                            self.onContactPage = true
                            self.addToContactButton.setImage(UIImage(systemName: "person.badge.minus.fill"), for: .normal)
                            self.addToContactButton.addTarget(self, action: #selector(self.removeFromContacts), for: .touchUpInside)
                        }
                    })
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
    
    func configureView() {
        if contact?.name == nil {
            nameLabel.text = "name".localized()
            nameLabel.textColor = .lightGray
        } else {
            nameLabel.text = contact?.name
            if SharedConfigs.shared.mode == "dark" {
                nameLabel.textColor = .white
            } else {
                nameLabel.textColor = .black
            }
        }
        if contact?.lastname == nil {
            lastnameLabel.text = "lastname".localized()
            lastnameLabel.textColor = .lightGray
        } else {
            lastnameLabel.text = contact?.lastname
            if SharedConfigs.shared.mode == "dark" {
                lastnameLabel.textColor = .white
            } else {
                lastnameLabel.textColor = .black
            }
        }
        if contact?.email == nil {
            emailLabel.text = "email".localized()
            emailLabel.textColor = .lightGray
        } else {
            emailLabel.text = contact?.email
            if SharedConfigs.shared.mode == "dark" {
                emailLabel.textColor = .white
            } else {
                emailLabel.textColor = .black
            }
        }
        
        if contact?.phoneNumber == nil {
            phoneLabel.text = "phone".localized()
            phoneLabel.textColor = .lightGray
        } else {
            phoneLabel.text = contact?.phoneNumber
            if SharedConfigs.shared.mode == "dark" {
                phoneLabel.textColor = .white
            } else {
                phoneLabel.textColor = .black
            }
        }
        
        if contact?.birthday == nil {
            birthDateLabel.text = "birth_date".localized()
            birthDateLabel.textColor = .lightGray
        } else {
            birthDateLabel.text = stringToDate(date: contact?.birthday) 
            if SharedConfigs.shared.mode == "dark" {
                birthDateLabel.textColor = .white
            } else {
                birthDateLabel.textColor = .black
            }
        }
        
        if contact?.gender == nil {
            genderLabel.text = "gender".localized()
            genderLabel.textColor = .lightGray
        } else {
            genderLabel.text = contact?.gender
            if SharedConfigs.shared.mode == "dark" {
                genderLabel.textColor = .white
            } else {
                genderLabel.textColor = .black
            }
        }
        
        if contact?.address == nil {
            addressLabel.text = "address".localized()
            addressLabel.textColor = .lightGray
        } else {
            addressLabel.text = contact?.address
            if SharedConfigs.shared.mode == "dark" {
                addressLabel.textColor = .white
            } else {
                addressLabel.textColor = .black
            }
        }
        
        if contact?.username == nil {
            usernameLabel.text = "username".localized()
            usernameLabel.textColor = .lightGray
        } else {
            usernameLabel.text = contact?.username
            if SharedConfigs.shared.mode == "dark" {
                usernameLabel.textColor = .white
            } else {
                usernameLabel.textColor = .black
            }
        }
        genderTextLabel.text = "gender:".localized()
        addressTextLabel.text = "address:".localized()
        phoneTextLabel.text = "phone:".localized()
        emailTextLabel.text = "email:".localized()
        nameTextLabel.text = "name:".localized()
        lastnameTextLabel.text = "lastname:".localized()
        usernameTextLabel.text = "username:".localized()
        birthDateTextLabel.text = "birth_date:".localized()
        emailTextLabel.text = "email:".localized()
        infoTextLabel.text = "info".localized()
        if contact?.avatarURL != nil {
            ImageCache.shared.getImage(url: (contact?.avatarURL!)!, id: contact!._id!) { (image) in
                DispatchQueue.main.async {
                    self.userImageView.image = image
                }
            }
        } else {
            userImageView.image = UIImage(named: "noPhoto")
        }
    }
    
}
