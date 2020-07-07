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
    var contacts: [User] = []
    var findedUsers: [User] = []
    var contactsMiniInformation: [User] = []
    let viewModel = ContactsViewModel()
    var onContactPage = true
    var isLoaded = false
    var isLoadedFoundUsers = false
    let refreshControl = UIRefreshControl()
    
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        setNavigationItems()
        getContacts()
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        
    }
    
    @objc private func refreshWeatherData(_ sender: Any) {
        getContacts()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isLoaded && contacts.count == 0 && onContactPage {
            removeView()
            setView("no_contacts".localized())
        }
        if findedUsers.count == 0 && isLoadedFoundUsers && !onContactPage {
            removeView()
            setView("there_is_no_result".localized())
        }
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
        contactsMiniInformation = contacts
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
    
    @objc func handleAlertChange(sender: Any?) {
        let textField = sender as! UITextField
        if textField.text != "" {
            self.viewModel.findUsers(term: (textField.text)!) { (responseObject, error) in
                if error != nil {
                    if error == NetworkResponse.authenticationError {
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
                        let alert = UIAlertController(title: "error_message".localized() , message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                } else if responseObject != nil {
                    self.isLoadedFoundUsers = true
                    if responseObject?.users.count == 0 {
                        DispatchQueue.main.async {
                            self.contactsMiniInformation = []
                            self.tableView.reloadData()
                            self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                            self.navigationItem.title = "found_users".localized()
                            self.activityIndicator.stopAnimating()
                            self.setView("there_is_no_result".localized())
                        }
                        return
                    }
                    self.findedUsers = []
                    for i in 0..<responseObject!.users.count {
                        var a = false
                        for j in 0..<self.contacts.count {
                            if responseObject!.users[i]._id == self.contacts[j]._id {
                                a = true
                                break
                            }
                        }
                        if a == false {
                            self.findedUsers.append(responseObject!.users[i])
                        }
                    }
                    self.contactsMiniInformation = self.findedUsers.map({ (user) -> User in
                        User(name: user.name, lastname: user.lastname, university: nil, _id: user._id, username: user.username, avatarURL: user.avatarURL, email: nil)
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
        } else {
            DispatchQueue.main.async {
                self.contactsMiniInformation = []
                self.tableView.reloadData()
                self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                self.navigationItem.title = "found_users".localized()
                self.activityIndicator.stopAnimating()
                self.setView("there_is_no_result".localized())
            }
        }
    }
    
    @objc func addButtonTapped() {
        onContactPage = false
        let alert = UIAlertController(title: "search_user".localized()
            , message: "enter_name_or_lastname_or_username".localized(), preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.addTarget(self, action: #selector(self.handleAlertChange(sender:)), for: .editingChanged)
        }
        alert.addAction(UIAlertAction(title: "close".localized(), style: .default, handler: nil))
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
    
    func removeView() {
        DispatchQueue.main.async {
            let resultView = self.view.viewWithTag(1)
            resultView?.removeFromSuperview()
        }
    }
    
    func getContacts() {
        if !isLoaded {
            activityIndicator.startAnimating()
        }
        viewModel.getContacts { (userContacts, error) in
            if error != nil {
                if error == NetworkResponse.authenticationError {
                    UserDataController().logOutUser()
                    DispatchQueue.main.async {
                        let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                        let nav = UINavigationController(rootViewController: vc)
                        let window: UIWindow? = UIApplication.shared.windows[0]
                        window?.rootViewController = nav
                        window?.makeKeyAndVisible()
                    }
                    DispatchQueue.main.async {
                        let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                }
            } else if userContacts != nil {
                self.isLoaded = true
                if userContacts?.count == 0 {
                    self.setView("no_contacts".localized())
                    return
                }
                self.contacts = userContacts!
                self.contactsMiniInformation = userContacts!
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.refreshControl.endRefreshing()
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if onContactPage == false {
            self.navigationItem.rightBarButtonItem?.isEnabled = true
            DispatchQueue.main.async {
                self.activityIndicator.startAnimating()
            }
            viewModel.addContact(id: contactsMiniInformation[indexPath.row]._id) { (error) in
                if error != nil {
                    if error == NetworkResponse.authenticationError {
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
                        let alert = UIAlertController(title: "error_message".localized(), message: error?.rawValue, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized(), style: .default, handler: nil))
                        self.present(alert, animated: true)
                    }
                    
                } else {
                    self.contacts.append(User(name: self.findedUsers[indexPath.row].name, lastname:
                        self.findedUsers[indexPath.row].lastname, university: nil, _id: self.findedUsers[indexPath.row]._id, username: self.findedUsers[indexPath.row].username, avatarURL: self.findedUsers[indexPath.row].avatarURL, email: nil))
                    self.onContactPage = true
                    self.contactsMiniInformation = self.contacts
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
            vc.name = self.contactsMiniInformation[indexPath.row].name
            vc.username = self.contactsMiniInformation[indexPath.row].username
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsMiniInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        removeView()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! ContactTableViewCell
        cell.configure(contact: contactsMiniInformation[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}

