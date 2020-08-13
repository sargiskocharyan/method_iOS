//
//  ContactsViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/4/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

enum ContactsMode {
    case fromRecentMessages
    case fromCallList
    case fromProfile
}

class ContactsViewController: UIViewController {
    
    //MARK: IBOutlets
    @IBOutlet weak var tableView: UITableView!
    //@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //MARK: Properties
    var findedUsers: [User] = []
    var contactsMiniInformation: [User] = []
    var viewModel: ContactsViewModel?
    var onContactPage = true
    var isLoaded = false
    var isLoadedFoundUsers = false
    let refreshControl = UIRefreshControl()
    var tabbar: MainTabBarController?
    var contactsMode: ContactsMode?
    static let cellIdentifier = "cell"
    var spinner = UIActivityIndicatorView(style: .medium)
    var mainRouter: MainRouter?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tabbar = tabBarController as? MainTabBarController
        tableView.dataSource = self
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refreshWeatherData(_:)), for: .valueChanged)
        tableView.tableFooterView = UIView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        spinner.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.1, constant: 35).isActive = true
    }
    
    @objc private func refreshWeatherData(_ sender: UIRefreshControl) {
        if onContactPage {
          getContacts()
        } else {
            sender.endRefreshing()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
        getContacts()
        setNavigationItems()
        contactsMiniInformation = viewModel!.contacts
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isLoaded && viewModel!.contacts.count == 0 && onContactPage {
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
        if contactsMode == .fromProfile || contactsMode == .fromRecentMessages {
            if onContactPage {
                self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
                self.navigationItem.title = "contacts".localized()
            } else {
                self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(backToContacts))
                self.navigationItem.title = "found_users".localized()
            }
        }
    }
    
    @objc func backToContacts() {
        contactsMiniInformation = viewModel!.contacts
        DispatchQueue.main.async {
            self.removeView()
            if self.viewModel!.contacts.count == 0 {
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
            self.viewModel!.findUsers(term: (textField.text)!) { (responseObject, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    }
                } else if responseObject != nil {
                    self.isLoadedFoundUsers = true
                    if responseObject?.users.count == 0 {
                        DispatchQueue.main.async {
                            self.contactsMiniInformation = []
                            self.tableView.reloadData()
                            self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                            self.navigationItem.title = "found_users".localized()
                            self.spinner.stopAnimating()
                            self.setView("there_is_no_result".localized())
                        }
                        return
                    }
                    self.findedUsers = []
                    for i in 0..<responseObject!.users.count {
                        var a = false
                        for j in 0..<self.viewModel!.contacts.count {
                            if responseObject!.users[i]._id == self.viewModel!.contacts[j]._id {
                                a = true
                                break
                            }
                        }
                        if a == false {
                            self.findedUsers.append(responseObject!.users[i])
                        }
                    }
                    self.contactsMiniInformation = self.findedUsers.map({ (user) -> User in
                        User(name: user.name, lastname: user.lastname, university: nil, _id: user._id!, username: user.username, avaterURL: user.avatarURL, email: nil, info: user.info, phoneNumber: user.phoneNumber, birthday: user.birthday, address: user.address, gender: user.gender)
                    })
                    DispatchQueue.main.async {
                        self.removeView()
                        self.tableView.reloadData()
                        self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                        self.navigationItem.title = "found_users".localized()
                        self.spinner.stopAnimating()
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                self.contactsMiniInformation = []
                self.tableView.reloadData()
                self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                self.navigationItem.title = "found_users".localized()
                self.spinner.stopAnimating()
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
            noResultView.tag = 25
            noResultView.backgroundColor = UIColor(named: "imputColor")
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
            let resultView = self.view.viewWithTag(25)
            resultView?.removeFromSuperview()
        }
    }
    
    
    
    func getContacts() {
        if !isLoaded {
            spinner.startAnimating()
        }
            self.isLoaded = true
            if viewModel!.contacts.count == 0 {
                self.setView("no_contacts".localized())
                return
            }
            self.contactsMiniInformation = viewModel!.contacts
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            self.spinner.stopAnimating()
        }
    }
}

//MARK: Extension
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource, ContactProfileDelegate {
    func removeContact() {
        contactsMiniInformation = viewModel!.contacts
        tableView.reloadData()
    }

    func addNewContact(contact: User) {
        self.onContactPage = true
        self.contactsMiniInformation = self.viewModel!.contacts
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
            self.navigationItem.title = "contacts".localized()
            self.spinner.stopAnimating()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.contactsMode == .fromProfile {
            mainRouter?.showContactProfileViewControllerFromContacts(id: contactsMiniInformation[indexPath.row]._id!, contact: contactsMiniInformation[indexPath.row], onContactPage: onContactPage)
        } else if self.contactsMode == .fromCallList {
            let tabBar = tabBarController as! MainTabBarController
            if !tabBar.onCall {
                tabBar.handleCallClick(id: contactsMiniInformation[indexPath.row]._id!, name: contactsMiniInformation[indexPath.row].name ?? contactsMiniInformation[indexPath.row].username!)
                let nc = tabBar.viewControllers![0] as! UINavigationController
                let callListViewController = nc.viewControllers[0] as! CallListViewController
                callListViewController.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: 0, calleeId: contactsMiniInformation[indexPath.row]._id!)
            } else {
                tabBar.handleClickOnSamePerson()
            }
        } else {
            mainRouter?.showChatViewControllerFromContacts(name: contactsMiniInformation[indexPath.row].name, username: contactsMiniInformation[indexPath.row].username, avatarURL: contactsMiniInformation[indexPath.row].avatarURL, id: contactsMiniInformation[indexPath.row]._id!)
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactsMiniInformation.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        removeView()
        let cell = tableView.dequeueReusableCell(withIdentifier: Self.cellIdentifier, for: indexPath) as! ContactTableViewCell
        if contactsMiniInformation.count > indexPath.row {
            cell.configure(contact: contactsMiniInformation[indexPath.row])
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}


