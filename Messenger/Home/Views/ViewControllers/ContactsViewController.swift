//
//  ContactsViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

class ContactsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    var contacts: [ContactResponseWithId] = []
    var findedUsers: [User] = []
    var contactsMiniInformation: [ContactInformation] = []
    let viewModel = ContactsViewModel()
    var onContactPage = true
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setNavigationItems()
        getContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    //MARK: Helper methods
    func setNavigationItems() {
        if onContactPage {
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
            self.navigationItem.title = "contacts".localized()
        } else {
            self.navigationItem.rightBarButtonItem = .init(title: "reset", style: .plain, target: self, action: #selector(backToContacts))
            self.navigationItem.title = "found_users"
        }
    }
    
    @objc func backToContacts() {
        contactsMiniInformation = contacts.map({ (contact) -> ContactInformation in
            ContactInformation(username: contact.username, name: contact.name, lastname: contact.lastname, _id: contact._id)
        })
        DispatchQueue.main.async {
            self.removeView()
            if self.contacts.count == 0 {
                self.setView("no_contacts".localized())
            }
            self.onContactPage = true
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
            self.navigationItem.title = "contacts".localized()
        }
    }
    
    @objc func addButtonTapped() {
        onContactPage = false
        let alert = UIAlertController(title: "search_user".localized()
            , message: "enter_name_or_lastname_or_username".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in }
        alert.addAction(UIAlertAction(title: "find".localized(), style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0]
            if textField?.text != "" {
                DispatchQueue.main.async {
                    self.activityIndicator.startAnimating()
                    self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                    self.navigationItem.title = "found_users".localized()
                }
                self.viewModel.findUsers(term: (textField?.text)!) { (responseObject, error, code) in
                    self.removeView()
                    if error != nil {
                        if code == 401 {
                            UserDataController().logOutUser()
                            DispatchQueue.main.async {
                                let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                                let nav = UINavigationController(rootViewController: vc)
                                let window: UIWindow? = UIApplication.shared.windows[0]
                                window?.rootViewController = nav
                                window?.makeKeyAndVisible()
                            }
                        }
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: "error_message".localized() , message: error, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                            self.present(alert, animated: true)
                        }
                    } else if responseObject != nil {
                        if responseObject?.users.count == 0 {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                                self.navigationItem.title = "found_users".localized()
                                self.activityIndicator.stopAnimating()
                                self.setView("there_is_no_result".localized())
                            }
                            return
                        }
                        self.findedUsers = responseObject!.users
                        self.contactsMiniInformation = self.findedUsers.map({ (user) -> ContactInformation in
                            ContactInformation(username: user.username, name: user.name, lastname: user.lastname, _id: user._id)
                        })
                        DispatchQueue.main.async {
                            self.removeView()
                            self.tableView.reloadData()
                            self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                            self.navigationItem.title = "found_users".localized()
                            self.activityIndicator.stopAnimating()
                        }
                    }
                }
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func setView(_ str: String) {
        DispatchQueue.main.async {
            let noResultView = UIView(frame: self.view.frame)
            noResultView.tag = 1
            noResultView.backgroundColor = .white
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.width * 0.8, height: self.view.frame.height))
            label.center = noResultView.center
            label.text = str
            label.textColor = .lightGray
            label.textAlignment = .center
            noResultView.addSubview(label)
            self.view.addSubview(noResultView)
        }
    }
    
    func getNewMessage(message: Message) {
        print("dfjg")
//        DispatchQueue.main.async {
//                            let visibleViewController = self.navigationController?.visibleViewController
//                            if visibleViewController is ChatViewController {
//                                let chatViewController = visibleViewController as! ChatViewController
//                                    chatViewController.getnewMessage( message: message)
//                            }
//                        }
    }
    
    func removeView() {
        DispatchQueue.main.async {
            let resultView = self.view.viewWithTag(1)
            resultView?.removeFromSuperview()
        }
    }
    
    
    func getContacts() {
        activityIndicator.startAnimating()
        viewModel.getContacts { (userContacts, error, code) in
            if error != nil {
                if code == 401 {
                    UserDataController().logOutUser()
                    DispatchQueue.main.async {
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
                }
            } else if userContacts != nil {
                if userContacts?.count == 0 {
                    self.setView("no_contacts".localized())
                    return
                }
                self.contacts = userContacts!
                self.contactsMiniInformation = userContacts!.map({ (contact) -> ContactInformation in
                    ContactInformation(username: contact.username, name: contact.name, lastname: contact.lastname, _id: contact._id)
                })
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    self.activityIndicator.stopAnimating()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.removeView()
        if onContactPage == false {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            viewModel.addContact(id: contactsMiniInformation[indexPath.row]._id) { (error, code) in
                if error != nil {
                    if code == 401 {
                        UserDataController().logOutUser()
                        DispatchQueue.main.async {
                            let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                            let nav = UINavigationController(rootViewController: vc)
                            let window: UIWindow? = UIApplication.shared.windows[0]
                            window?.rootViewController = nav
                            window?.makeKeyAndVisible()
                        }
                    }
                    DispatchQueue.main.async {
                        self.activityIndicator.stopAnimating()
                        let alert = UIAlertController(title: "error_message".localized(), message: error, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    
                } else {
                    self.contacts.append(ContactResponseWithId(_id: self.findedUsers[indexPath.row]._id, name:
                        self.findedUsers[indexPath.row].name, lastname: self.findedUsers[indexPath.row].lastname, email: nil, username: self.findedUsers[indexPath.row].username))
                    self.onContactPage = true
                    self.contactsMiniInformation = self.contacts.map({ (contact) -> ContactInformation in
                        ContactInformation(username: contact.username, name: contact.name, lastname: contact.lastname, _id: contact._id)
                    })
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                        self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
                        self.navigationItem.title = "contacts".localized()
                        self.activityIndicator.stopAnimating()
                    }
                }
            }
        } else {
            let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
            vc.id = self.contactsMiniInformation[indexPath.row]._id
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsMiniInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        cell.contactImageView.image = UIImage(named: "noPhoto")
        if contactsMiniInformation[indexPath.row].name == nil {
            cell.nameLabel.textColor = .darkGray
            cell.nameLabel.text = "name".localized()
        } else {
            cell.nameLabel.text = self.contactsMiniInformation[indexPath.row].name
        }
        if contactsMiniInformation[indexPath.row].username == nil {
            cell.usernameLabel.textColor = .darkGray
            cell.usernameLabel.text = "username".localized()
        } else {
            cell.usernameLabel.text = self.contactsMiniInformation[indexPath.row].username
        }
        if contactsMiniInformation[indexPath.row].lastname == nil {
            cell.lastnameLabel.textColor = .darkGray
            cell.lastnameLabel.text = "lastname".localized()
        } else {
            cell.lastnameLabel.text = self.contactsMiniInformation[indexPath.row].lastname
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

