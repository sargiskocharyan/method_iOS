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
    weak var changeEmailViewController: ChangeEmailViewController?
    weak var notificationListViewController: NotificationListViewController?
    weak var notificationDetailViewController: NotificationDetailViewController?
    weak var channelListViewController: ChannelListViewController?
    weak var channelInfoViewController: ChannelInfoViewController?
    weak var channelMessagesViewController: ChannelMessagesViewController?
    weak var adminInfoViewController: AdminInfoViewController?
    weak var moderatorListViewController: ModeratorListViewController?
    weak var moderatorInfoViewController: ModeratorInfoViewController?
    weak var subscribersListViewController: SubscribersListViewController?
    weak var updateChannelInfoViewController: UpdateChannelInfoViewController?
    
    func assemblyModule() {
        let vc = MainTabBarController.instantiate(fromAppStoryboard: .main)
        let router = MainRouter()
        vc.mainRouter = router
        vc.viewModel = HomePageViewModel()
        vc.contactsViewModel = ContactsViewModel()
        vc.recentMessagesViewModel = RecentMessagesViewModel()
        router.mainTabBarController = vc
        AppDelegate.shared.providerDelegate.tabbar = vc
        AppDelegate.shared.tabbar = vc
        SocketTaskManager.shared.tabbar = vc
        let videoVC = VideoViewController.instantiate(fromAppStoryboard: .calls)
        videoVC.webRTCClient = router.mainTabBarController!.webRTCClient
        router.videoViewController = videoVC
        router.mainTabBarController?.videoVC = videoVC
        
        let channelListNC = router.mainTabBarController?.viewControllers![3] as! UINavigationController
        router.channelListViewController = (channelListNC.viewControllers[0] as! ChannelListViewController)
        router.channelListViewController?.mainRouter = router.mainTabBarController?.mainRouter
        router.channelListViewController?.viewModel = ChannelListViewModel()
        
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
        
        let window = AppDelegate.shared.window
        window?.rootViewController = router.mainTabBarController
        window?.makeKeyAndVisible()
    }
    
    func showVideoViewController(mode: VideoVCMode) {
        let selectedNC = self.mainTabBarController!.selectedViewController as? UINavigationController
        if selectedNC?.viewControllers.last as? VideoViewController == nil {
            self.mainTabBarController?.videoVC?.videoVCMode = mode
        selectedNC?.pushViewController(self.mainTabBarController!.videoVC!, animated: false)
        } else {
            return
        }
    }
    
    func showUpdateChannelInfoViewController(channelInfo: ChannelInfo) {
        let vc = UpdateChannelInfoViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = adminInfoViewController?.mainRouter
        vc.viewModel = UpdateChannelInfoViewModel()
        vc.channelInfo = channelInfo
        self.updateChannelInfoViewController = vc
        adminInfoViewController?.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    func showModeratorListViewController(id: String, isChangeAdmin: Bool) {
        let vc = ModeratorListViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = adminInfoViewController?.mainRouter
        vc.viewModel = ChannelInfoViewModel()
        vc.isChangeAdmin = isChangeAdmin
        vc.id = id
        self.moderatorListViewController = vc
        adminInfoViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showCallDetailViewController(id: String, name: String, duration: String, time: Date?, callMode: CallStatus, avatarURL: String, isReceiverWe: Bool) {
        let vc = CallDetailViewController.instantiate(fromAppStoryboard: .calls)
        vc.mainRouter = callListViewController?.mainRouter
        vc.name = name
        vc.callDuration = duration
        vc.date = time
        vc.callMode = callMode
        vc.avatarURL = avatarURL
        vc.id = id
        vc.isHandledCall = isReceiverWe
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
    
    func showAdminInfoViewController(channelInfo: ChannelInfo) {
        let vc = AdminInfoViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = channelMessagesViewController?.mainRouter
        vc.channelInfo = channelInfo
        vc.viewModel = ChannelInfoViewModel()
        self.adminInfoViewController = vc
        channelMessagesViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatViewController(name: String?, id: String, avatarURL: String?, username: String?) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .chats)
        vc.viewModel = ChatMessagesViewModel()
        vc.mainRouter = recentMessagesViewController?.mainRouter
        vc.name = name
        vc.fromContactProfile = false
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        recentMessagesViewController?.navigationController?.pushViewController(vc, animated: false)
    }
    
    func showContactProfileViewControllerFromChat(id: String, fromChat: Bool) {
        let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .profile)
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
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .profile)
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.mainRouter = profileViewController?.mainRouter
        vc.contactsMode = .fromProfile
        self.contactsViewController = vc
        profileViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactProfileViewControllerFromContacts(id: String, contact: User, onContactPage: Bool) {
           let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .profile)
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
        let vc = ChatViewController.instantiate(fromAppStoryboard: .chats)
        vc.viewModel = ChatMessagesViewModel()
        vc.mainRouter = contactsViewController?.mainRouter
        vc.name = name
        vc.fromContactProfile = false
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        contactsViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactsViewControllerFromRecent() {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .profile)
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.mainRouter = recentMessagesViewController?.mainRouter
        vc.contactsMode = .fromRecentMessages
        self.contactsViewController = vc
        recentMessagesViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatViewControllerFromContactProfile(name: String?, username: String?, avatarURL: String?, id: String) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .chats)
        vc.mainRouter = contactProfileViewController?.mainRouter
        vc.viewModel = ChatMessagesViewModel()
        vc.name = name
        vc.fromContactProfile = true
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        contactProfileViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatViewControllerFromCallDetail(name: String?, username: String?, avatarURL: String?, id: String) {
        let vc = ChatViewController.instantiate(fromAppStoryboard: .chats)
        vc.mainRouter = callDetailViewController?.mainRouter
        vc.viewModel = ChatMessagesViewModel()
        vc.name = name
        vc.fromContactProfile = false
        vc.username = username
        vc.avatar = avatarURL
        vc.id = id
        self.chatViewController = vc
        callDetailViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showEditViewController() {
        let vc = EditInformationViewController.instantiate(fromAppStoryboard: .profile)
        vc.mainRouter = profileViewController?.mainRouter
        vc.viewModel = RegisterViewModel()
        self.editInformationViewController = vc
        profileViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showContactsViewFromCallList() {
        let vc = ContactsViewController.instantiate(fromAppStoryboard: .profile)
        vc.mainRouter = callListViewController?.mainRouter
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.contactsMode = .fromCallList
        self.contactsViewController = vc
        callListViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChangeEmailViewController(changingSubject: ChangingSubject) {
        let vc = ChangeEmailViewController.instantiate(fromAppStoryboard: .profile)
        vc.mainRouter = profileViewController?.mainRouter
        vc.viewModel = ChangeEmailViewModel()
        vc.delegate = profileViewController
        vc.changingSubject = changingSubject
        self.changeEmailViewController = vc
        profileViewController?.navigationController?.present(vc, animated: true, completion: nil)
    }
    
    
    func showNotificationListViewController() {
        let vc = NotificationListViewController.instantiate(fromAppStoryboard: .profile)
        vc.mainRouter = profileViewController?.mainRouter
        self.notificationListViewController = vc
        profileViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showNotificationDetailViewController(type: CellType) {
        let vc = NotificationDetailViewController.instantiate(fromAppStoryboard: .profile)
        vc.type = type
        vc.mainRouter = notificationListViewController?.mainRouter
        self.notificationDetailViewController = vc
        notificationListViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    
    func showContactProfileViewControllerFromNotificationDetail(id: String) {
        let vc = ContactProfileViewController.instantiate(fromAppStoryboard: .profile)
        vc.id = id
        vc.onContactPage = false
        vc.fromChat = false
        vc.viewModel = mainTabBarController?.contactsViewModel
        vc.mainRouter = notificationDetailViewController?.mainRouter
        self.contactProfileViewController = vc
        notificationDetailViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChatViewControllerFromNotificationDetail(name: String?, id: String, avatarURL: String?, username: String?) {
         let vc = ChatViewController.instantiate(fromAppStoryboard: .chats)
         vc.viewModel = ChatMessagesViewModel()
         vc.mainRouter = notificationDetailViewController?.mainRouter
         vc.name = name
         vc.fromContactProfile = false
         vc.username = username
         vc.avatar = avatarURL
         vc.id = id
         self.chatViewController = vc
         notificationDetailViewController?.navigationController?.pushViewController(vc, animated: false)
     }
     
    func showChannelMessagesViewController(channelInfo: ChannelInfo) {
        let vc = ChannelMessagesViewController.instantiate(fromAppStoryboard: .channel)
        vc.mainRouter = channelListViewController?.mainRouter
        vc.channelInfo = ChannelInfo(channel: channelInfo.channel, role: channelInfo.role)
        vc.viewModel = ChannelMessagesViewModel()
        self.channelMessagesViewController = vc
        channelListViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showChannelInfoViewController(channelInfo: ChannelInfo)  {
        let vc = ChannelInfoViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = channelMessagesViewController?.mainRouter
        vc.channelInfo = channelInfo
        vc.viewModel = ChannelInfoViewModel()
        self.channelInfoViewController = vc
        channelMessagesViewController?.navigationController?.pushViewController(vc, animated: true)
    }
   
    func showModeratorInfoViewController(channelInfo: ChannelInfo)  {
        let vc = ModeratorInfoViewController.instantiate(fromAppStoryboard: .main)
        vc.mainRouter = channelMessagesViewController?.mainRouter
        vc.channelInfo = channelInfo
        vc.viewModel = ChannelInfoViewModel()
        self.moderatorInfoViewController = vc
        channelMessagesViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSubscribersListViewController(id: String) {
        let vc = SubscribersListViewController.instantiate(fromAppStoryboard: .channel)
        vc.mainRouter = moderatorInfoViewController?.mainRouter
        vc.viewModel = ChannelInfoViewModel()
        vc.id = id
        vc.isFromModeratorList = false
        self.subscribersListViewController = vc
        moderatorInfoViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSubscribersListViewControllerFromModeratorList(id: String) {
        let vc = SubscribersListViewController.instantiate(fromAppStoryboard: .channel)
        vc.mainRouter = moderatorListViewController?.mainRouter
        vc.viewModel = ChannelInfoViewModel()
        vc.id = id
        vc.isFromModeratorList = true
        self.subscribersListViewController = vc
        moderatorListViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showSubscribersListViewControllerFromAdminInfo(id: String) {
        let vc = SubscribersListViewController.instantiate(fromAppStoryboard: .channel)
        vc.mainRouter = adminInfoViewController?.mainRouter
        vc.viewModel = ChannelInfoViewModel()
        vc.id = id
        vc.isFromModeratorList = false
        self.subscribersListViewController = vc
        adminInfoViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
