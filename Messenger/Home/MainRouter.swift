//
//  MainRouter.swift
//  Messenger
//
//  Created by Employee1 on 8/4/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class MainRouter {
    
    weak var mainTabBarController: MainTabBarController?
    weak var callListViewController: CallListViewController?
    weak var profileViewController: ProfileViewController?
    weak var recentMessagesViewController: RecentMessagesViewController?
    weak var chatViewController: ChatViewController?
    weak var contactsViewController: ContactsViewController?
    weak var editInformationViewController: EditInformationViewController?
    weak var contactProfileViewController: ContactProfileViewController?
    weak var callDetailViewController: CallDetailViewController?
    weak var videoViewController: VideoViewController?
    
    func assemblyModule() {
        let vc = MainTabBarController.instantiate(fromAppStoryboard: .main)
        let router = MainRouter()
        vc.mainRouter = router
        vc.viewModel = HomePageViewModel()
        vc.contactsViewModel = ContactsViewModel()
        vc.recentMessagesViewModel = RecentMessagesViewModel()
        router.mainTabBarController = vc
        let videoVC = VideoViewController.instantiate(fromAppStoryboard: .main)
        videoVC.webRTCClient = router.mainTabBarController!.webRTCClient
        router.videoViewController = videoVC
        router.mainTabBarController?.videoVC = videoVC
        let callListNC = router.mainTabBarController?.viewControllers![0] as! UINavigationController
        router.callListViewController = (callListNC.viewControllers[0] as! CallListViewController)
        router.callListViewController?.mainRouter = router.mainTabBarController?.mainRouter
        router.callListViewController?.viewModel = RecentMessagesViewModel()
        let recentMessagesNC = router.mainTabBarController?.viewControllers![1] as! UINavigationController
        router.recentMessagesViewController = (recentMessagesNC.viewControllers[0] as! RecentMessagesViewController)
        router.recentMessagesViewController?.mainRouter = router.mainTabBarController?.mainRouter
        router.recentMessagesViewController?.viewModel = RecentMessagesViewModel()
        let profileNC = router.mainTabBarController?.viewControllers![2] as! UINavigationController
        router.profileViewController = (profileNC.viewControllers[0] as! ProfileViewController)
        router.profileViewController?.mainRouter = router.mainTabBarController?.mainRouter
        router.profileViewController?.viewModel = ProfileViewModel()
        let window: UIWindow? = UIApplication.shared.windows[0]
        window?.rootViewController = router.mainTabBarController
        window?.makeKeyAndVisible()
    }
    
    func showVideoViewController() {
        let selectedNC = self.mainTabBarController!.selectedViewController as? UINavigationController
        selectedNC?.pushViewController(self.mainTabBarController!.videoVC!, animated: false)
    }
    
    func showCallDetailViewController(id: String, name: String, duration: String, time: Date?, callMode: CallMode, avatarURL: String) {
        let vc = CallDetailViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = callListViewController?.mainRouter
        vc.name = name
        vc.callDuration = duration
        vc.date = time
        vc.callMode = callMode
        vc.avatarURL = avatarURL
        vc.id = id
        vc.onContactPage = false
        for j in 0..<mainTabBarController!.contactsViewModel!.contacts.count {
            if id == mainTabBarController!.contactsViewModel!.contacts[j]._id {
                vc.onContactPage = true
                break
            }
        }
        self.callDetailViewController = vc
        callListViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatViewController(name: String?, id: String, avatarURL: String?, username: String?) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
        vc.viewModel = ChatMessagesViewModel()
        vc.mainRouter = recentMessagesViewController?.mainRouter
        vc.name = name
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        recentMessagesViewController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func showContactProfileViewControllerFromChat(id: String, fromChat: Bool) {
        let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .main)
        vc.id = id
        vc.onContactPage = false
        vc.fromChat = true
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.mainRouter = chatViewController?.mainRouter
        for i in 0..<mainTabBarController!.contactsViewModel!.contacts.count {
            if mainTabBarController!.contactsViewModel!.contacts[i]._id == id {
                vc.onContactPage = true
                break
            }
        }
        self.contactProfileViewController = vc
        chatViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactsViewControllerFromProfile() {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .main)
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.mainRouter = profileViewController?.mainRouter
        vc.contactsMode = .fromProfile
        self.contactsViewController = vc
        profileViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactProfileViewControllerFromContacts(id: String, contact: User, onContactPage: Bool) {
           let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .main)
           vc.delegate = contactsViewController
        vc.mainRouter = contactsViewController?.mainRouter
        vc.viewModel = mainTabBarController?.contactsViewModel
           vc.id = id
           vc.contact = contact
           vc.onContactPage = onContactPage
           vc.fromChat = false
           self.contactProfileViewController = vc
           contactsViewController?.navigationController?.pushViewController(vc, animated: true)
       }
    
    func showChatViewControllerFromContacts(name: String?, username: String?, avatarURL: String?, id: String) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
        vc.viewModel = ChatMessagesViewModel()
        vc.mainRouter = contactsViewController?.mainRouter
        vc.name = name
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        contactsViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactsViewControllerFromRecent() {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .main)
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.mainRouter = recentMessagesViewController?.mainRouter
        vc.contactsMode = .fromRecentMessages
        self.contactsViewController = vc
        recentMessagesViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatViewControllerFromContactProfile(name: String?, username: String?, avatarURL: String?, id: String) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = contactsViewController?.mainRouter
        vc.viewModel = ChatMessagesViewModel()
        vc.name = name
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        contactProfileViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatViewControllerFromCallDetail(name: String?, username: String?, avatarURL: String?, id: String) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = callDetailViewController?.mainRouter
        vc.viewModel = ChatMessagesViewModel()
        vc.name = name
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        callDetailViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showEditViewController() {
        let vc = EditInformationViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = profileViewController?.mainRouter
        vc.viewModel = RegisterViewModel()
        self.editInformationViewController = vc
        profileViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactsViewFromCallList() {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = callListViewController?.mainRouter
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.contactsMode = .fromCallList
        self.contactsViewController = vc
        callListViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
