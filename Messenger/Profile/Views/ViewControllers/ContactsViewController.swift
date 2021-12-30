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
    var viewModel: ContactsViewModel?
    var onContactPage = true
    var isLoaded = false
    var isLoadedFoundUsers = false
    let refreshControl = UIRefreshControl()
    var tabbar: MainTabBarController?
    var contactsMode: ContactsMode?
    var spinner = UIActivityIndicatorView(style: .medium)
    var mainRouter: MainRouter?
    
    //MARK: Lifecycles
    override func viewDidLoad() {
        super.viewDidLoad()
        setupDelegateAndObserver()
        setupUI()
        getContacts()
        setNavigationItems()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        if isLoaded && viewModel?.contacts.isEmpty == true && onContactPage {
            removeView()
            setView("no_contacts".localized())
        }
        if viewModel?.findedUsers.isEmpty == true && isLoadedFoundUsers && !onContactPage {
            removeView()
            setView("there_is_no_result".localized())
        }
    }
    
    //MARK: Helper methods
    
    func setupUI() {
        tabbar = tabBarController as? MainTabBarController
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        tableView.tableFooterView = UIView()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        view.addSubview(spinner)
        
        spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        spinner.topAnchor.constraint(equalTo: view.topAnchor, constant: ContactsViewControllerConstants.spinnerTopConstant).isActive = true
        spinner.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: ContactsViewControllerConstants.spinnerHeightMultiplier, constant: ContactsViewControllerConstants.spinnerHeightConstant).isActive = true
        
        tabBarController?.tabBar.isHidden = false
        navigationController?.navigationBar.isHidden = false
    }
    
    func setupDelegateAndObserver() {
        tableView.delegate = self
        tableView.dataSource = self
        refreshControl.addTarget(self, action: #selector(refreshWeatherData), for: .valueChanged)
    }
    
    func setNavigationItems() {
        if contactsMode == .fromProfile || contactsMode == .fromRecentMessages || contactsMode == .fromCallList {
            if onContactPage {
                self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
                self.navigationItem.title = "contacts".localized()
            } else {
                self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(backToContacts))
                self.navigationItem.title = "found_users".localized()
            }
        }
    }
    
    @objc private func refreshWeatherData(_ sender: UIRefreshControl) {
        if onContactPage {
            getContacts()
        } else {
            sender.endRefreshing()
        }
    }
    
    @objc func backToContacts() {
        viewModel?.contactsMiniInformation = viewModel!.contacts
        DispatchQueue.main.async {
            self.removeView()
            if self.viewModel!.contacts.isEmpty == true {
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
        if textField.text?.isEmpty == false {
            self.viewModel!.findUsers(term: (textField.text)!) { (responseObject, error) in
                if error != nil {
                    DispatchQueue.main.async {
                        self.showErrorAlert(title: "error_message".localized(), errorMessage: error!.rawValue)
                    }
                } else if responseObject != nil {
                    self.isLoadedFoundUsers = true
                    if responseObject?.users.isEmpty == true {
                        DispatchQueue.main.async {
                            self.viewModel?.contactsMiniInformation = []
                            self.tableView.reloadData()
                            self.navigationItem.rightBarButtonItem = .init(title: "reset".localized(), style: .plain, target: self, action: #selector(self.backToContacts))
                            self.navigationItem.title = "found_users".localized()
                            self.spinner.stopAnimating()
                            self.setView("there_is_no_result".localized())
                        }
                        return
                    }
                    self.viewModel?.getContactsMiniInformation()
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
                self.viewModel?.contactsMiniInformation = []
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
            noResultView.tag = ContactsViewControllerConstants.viewTag
            noResultView.backgroundColor = UIColor.inputColor
            
            let label = UILabel(frame: CGRect(x: .zero, y: .zero, width: self.view.frame.width * ContactsViewControllerConstants.frameWidth, height: self.view.frame.height))
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
            let resultView = self.view.viewWithTag(ContactsViewControllerConstants.viewTag)
            resultView?.removeFromSuperview()
        }
    }
    
    func getContacts() {
        if !isLoaded {
            spinner.startAnimating()
        }
        self.isLoaded = true
        if viewModel?.contacts.isEmpty == true {
            self.setView("no_contacts".localized())
            return
        }
        self.viewModel?.contactsMiniInformation = viewModel!.contacts
        self.onContactPage = true
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.refreshControl.endRefreshing()
            self.spinner.stopAnimating()
        }
    }
}

//MARK: Extensions
extension ContactsViewController: UITableViewDelegate, UITableViewDataSource, ContactProfileDelegate {
    func removeContact() {
        viewModel?.contactsMiniInformation = viewModel!.contacts
        tableView.reloadData()
    }
    
    func addNewContact(contact: User) {
        self.onContactPage = true
        self.viewModel?.contactsMiniInformation = self.viewModel!.contacts
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.navigationItem.rightBarButtonItem = .init(barButtonSystemItem: .add, target: self, action: #selector(self.addButtonTapped))
            self.navigationItem.title = "contacts".localized()
            self.spinner.stopAnimating()
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tabbar?.videoVC?.isCallHandled = false
        if self.contactsMode == .fromProfile {
            mainRouter?.showContactProfileViewControllerFromContacts(contact: viewModel?.contactsMiniInformation[indexPath.row] ?? User(), onContactPage: onContactPage)
        } else if self.contactsMode == .fromCallList {
            let tabBar = tabBarController as! MainTabBarController
            if !tabBar.onCall {
                tabBar.handleCallClick(id: viewModel?.contactsMiniInformation[indexPath.row]._id ?? "", name: viewModel?.contactsMiniInformation[indexPath.row].name ?? viewModel?.contactsMiniInformation[indexPath.row].username ?? "", mode: .videoCall)
                let nc = tabBar.viewControllers!.first as! UINavigationController
                let callListViewController = nc.viewControllers.first as! CallListViewController
                callListViewController.activeCall = FetchedCall(id: UUID(), isHandleCall: false, time: Date(), callDuration: .zero, calleeId: viewModel?.contactsMiniInformation[indexPath.row]._id ?? "")
            } else {
                tabBar.handleClickOnSamePerson()
            }
        } else {
            mainRouter?.showChatViewControllerFromContacts(name: viewModel?.contactsMiniInformation[indexPath.row].name, username: viewModel?.contactsMiniInformation[indexPath.row].username, avatarURL: viewModel?.contactsMiniInformation[indexPath.row].avatarURL, id: viewModel?.contactsMiniInformation[indexPath.row]._id ?? "")
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel?.contactsMiniInformation.count ?? .zero
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        removeView()
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactTableViewCell.reuseIdentifier, for: indexPath) as! ContactTableViewCell
        cell.configure(contact: viewModel?.contactsMiniInformation[indexPath.row] ?? User())
        cell.selectionStyle = .none
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return ContactsViewControllerConstants.cellHeight
    }
}


struct ContactsViewControllerConstants {
    static let cellHeight: CGFloat = 70
    static let viewTag = 25
    static let frameWidth = 0.8
    static let spinnerTopConstant: CGFloat = 100
    static let spinnerHeightMultiplier = 0.1
    static let spinnerHeightConstant: CGFloat = 35
}
