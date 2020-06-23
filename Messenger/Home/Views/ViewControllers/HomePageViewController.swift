//
//  HomePageViewController.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//


import UIKit

class HomePageViewController: UITabBarController {
    
    //MARK: Properties
    let viewModel = HomePageViewModel()
    
    //MARK: Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = true
        verifyToken()
    }
    
    //MARK: Helper methods
    func verifyToken() {
        viewModel.verifyToken(token: (SharedConfigs.shared.signedUser?.token)!) { (responseObject, error, code) in
            if (error != nil){
                if code == 401 {
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
            } else if responseObject != nil && responseObject!.tokenExists == false {
                DispatchQueue.main.async {
                    let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .main)
                    vc.modalPresentationStyle = .fullScreen
                    let nav = UINavigationController(rootViewController: vc)
                    guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                        let sceneDelegate = windowScene.delegate as? SceneDelegate
                        else {
                            return
                    }
                    sceneDelegate.window?.rootViewController = nav
                }
            }
            else if responseObject != nil && ((responseObject?.tokenExists) == true) {
              
            }
        }
    }
}
