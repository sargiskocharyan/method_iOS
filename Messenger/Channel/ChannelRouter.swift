//
//  ChannelRouter.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation


class ChannelRouter {
    
    weak var channelMessagesViewController: ChannelMessagesViewController?
    
    func assemblyModule() {
        let vc = MainTabBarController.instantiate(fromAppStoryboard: .main)
        let router = ChannelRouter()
        
    }
    
}
