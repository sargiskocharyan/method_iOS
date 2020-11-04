//
//  AuthRouter.swift
//  Messenger
//
//  Created by Employee1 on 8/4/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

class AuthRouter {
    weak var beforeLoginViewController: BeforeLoginViewController?
    weak var confirmCodeViewController: ConfirmCodeViewController?
    weak var congratulationsViewController: CongratulationsViewController?
    weak var registerViewController: RegisterViewController?
    
    func assemblyModule() {
        let vc = BeforeLoginViewController.instantiate(fromAppStoryboard: .auth)
        let router = AuthRouter()
        vc.authRouter = router
        vc.viewModel = BeforeLoginViewModel()
        router.beforeLoginViewController = vc
        let nc = UINavigationController(rootViewController: vc)
        let window: UIWindow? = AppDelegate.shared.window
        window?.rootViewController = nc
        window?.makeKeyAndVisible()
    }
    
    func showConfirmCodeViewController(email: String?, code: String?, isExists: Bool, phoneNumber: String?) {
        let vc = ConfirmCodeViewController.instantiate(fromAppStoryboard: .auth)
        vc.isExists = isExists
        vc.code = code
        vc.email = email
        vc.phoneNumber = phoneNumber
        vc.authRouter = beforeLoginViewController?.authRouter
        vc.viewModel = ConfirmCodeViewModel()
        self.confirmCodeViewController = vc
        beforeLoginViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showRegisterViewController() {
        let vc = RegisterViewController.instantiate(fromAppStoryboard: .auth)
        vc.authRouter = confirmCodeViewController?.authRouter
        vc.viewModel = RegisterViewModel()
        self.registerViewController = vc
        confirmCodeViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
    func showCongratulationsViewController() {
        let vc = CongratulationsViewController.instantiate(fromAppStoryboard: .auth)
        vc.authRouter = registerViewController?.authRouter
        self.congratulationsViewController = vc
        registerViewController?.navigationController?.pushViewController(vc, animated: true)
    }
    
}
