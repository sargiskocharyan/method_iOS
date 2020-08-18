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
    @IBOutlet weak var stackView: UIStackView!
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
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var phoneLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var emailTextLabel: UILabel!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var removeFromContactsButton: UIButton!
    
    var addContact: UIButton?
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
    var mainRouter: MainRouter?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
        tabBarController?.tabBar.isHidden = false
        addToContactButton.addTarget(self, action: #selector(addToContact), for: .touchUpInside)
        removeFromContactsButton.setTitle("remove_from_account".localized(), for: .normal)
        if onContactPage! {
            self.view.viewWithTag(45)?.removeFromSuperview()
        } else {
            removeFromContactsButton.isHidden = true
        }
        if tabBar!.onCall {
            videoCallButton.isEnabled = false
        } else {
            videoCallButton.isEnabled = true
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addToContactButton.setImage(UIImage(systemName: "person.badge.plus.fill"), for: .normal)
        addContact = addToContactButton
        tabBar = tabBarController as? MainTabBarController
        nc = tabBar?.viewControllers?[0] as? UINavigationController
        callListViewController = nc?.viewControllers[0] as? CallListViewController
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 40
        userImageView.clipsToBounds = true
        infoView.layer.borderColor = UIColor.lightGray.cgColor
        infoView.layer.borderWidth = 1.0
        infoView.layer.masksToBounds = true
        addToContactButton.tag = 45
        getUserInformation()
        sendMessageButton.addTarget(self, action: #selector(startMessage), for: .touchUpInside)
        sendMessageButton.backgroundColor = .clear
        
    }
    
    @IBAction func removeFromContactsAction(_ sender: Any) {
        viewModel?.removeContact(id: id!, completion: { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                }
            } else {
                self.onContactPage = false
                DispatchQueue.main.async {
                    self.stackView.addArrangedSubview(self.addContact!)
                    self.stackView.reloadInputViews()
                    self.removeFromContactsButton.isHidden = true
                    self.viewModel?.removeContactFromCoreData(id: self.id!, completion: { (error) in
                        self.delegate?.removeContact()
                    })
                }
            }
        })
    }
    
    @objc func startMessage() {
        if fromChat! {
            navigationController?.popViewController(animated: false)
        } else {
            mainRouter?.showChatViewControllerFromContactProfile(name: contact?.name, username:  contact?.username, avatarURL: contact?.avatarURL, id: (contact?._id)!)
        }
    }
    
    func getUserInformation() {
        callListViewController?.viewModel!.getuserById(id: id!) { (user, error) in
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
                                self.view.viewWithTag(45)?.removeFromSuperview()
                                self.delegate?.addNewContact(contact: self.contact!)
                                self.onContactPage = true
                                self.removeFromContactsButton.isHidden = false
                            }
                        })
                    }
                }
            }
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
        for i in 0..<callListViewController!.viewModel!.calls.count {
            for j in i..<callListViewController!.viewModel!.calls.count {
                let firstDate = stringToDate(date: callListViewController!.viewModel!.calls[i].createdAt)
                let secondDate = stringToDate(date: callListViewController?.viewModel!.calls[j].createdAt)
                if firstDate!.compare(secondDate!).rawValue == -1 {
                    let temp = callListViewController!.viewModel!.calls[i]
                    callListViewController!.viewModel!.calls[i] = callListViewController!.viewModel!.calls[j]
                    callListViewController!.viewModel!.calls[j] = temp
                }
            }
        }
    }
    
   func stringToDate(date:String) -> Date? {
         let formatter = DateFormatter()
         formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
         let parsedDate = formatter.date(from: date)
         if parsedDate == nil {
             return nil
         } else {
            return parsedDate
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
            nameLabel.text = "not_defined".localized()
            nameLabel.textColor = .lightGray
        } else {
            nameLabel.text = contact?.name
            nameLabel.textColor = UIColor(named: "color")
        }
        if contact?.lastname == nil {
            lastnameLabel.text = "not_defined".localized()
            lastnameLabel.textColor = .lightGray
        } else {
            lastnameLabel.text = contact?.lastname
            lastnameLabel.textColor = UIColor(named: "color")
        }
        if contact?.email == nil {
            emailLabel.text = "not_defined".localized()
            emailLabel.textColor = .lightGray
        } else {
            emailLabel.text = contact?.email
            emailLabel.textColor = UIColor(named: "color")
        }
        
        if contact?.phoneNumber == nil {
            phoneLabel.text = "not_defined".localized()
            phoneLabel.textColor = .lightGray
        } else {
            phoneLabel.text = contact?.phoneNumber
            phoneLabel.textColor = UIColor(named: "color")
        }
        
        if contact?.birthday == nil {
            birthDateLabel.text = "not_defined".localized()
            birthDateLabel.textColor = .lightGray
        } else {
            birthDateLabel.text = stringToDate(date: contact?.birthday) 
            birthDateLabel.textColor = UIColor(named: "color")
        }
        
        if contact?.gender == nil {
            genderLabel.text = "not_defined".localized()
            genderLabel.textColor = .lightGray
        } else {
            genderLabel.text = contact?.gender
            genderLabel.textColor = UIColor(named: "color")
        }
        
        if contact?.username == nil {
            usernameLabel.text = "not_defined".localized()
            usernameLabel.textColor = .lightGray
        } else {
            usernameLabel.text = contact?.username
            usernameLabel.textColor = UIColor(named: "color")
        }
        if contact?.info == nil {
            infoLabel.text = "info_not_set".localized()
            infoLabel.textColor = .lightGray
        } else {
            infoLabel.text = contact?.info
            infoLabel.textColor = UIColor(named: "color")
        }
        
        genderTextLabel.text = "gender:".localized()
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
