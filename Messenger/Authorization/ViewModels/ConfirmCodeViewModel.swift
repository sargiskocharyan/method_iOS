//
//  ConfirmCodeViewModel.swift
//  Messenger
//
//  Created by Employee1 on 5/26/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation
import Firebase

class ConfirmCodeViewModel {
    let networkManager = AuthorizationNetworkManager()
    
    func login(email: String, code: String, completion: @escaping (String?, LoginResponse?, NetworkResponse?)->()) {
        networkManager.login(email: email, code: code) { (token, loginResponse, error) in
            completion(token, loginResponse, error)
        }
    }

    func resendCode(email: String, completion: @escaping (String?, NetworkResponse?)->()) {
        networkManager.beforeLogin(email: email) { (responseObject, error) in
            completion(responseObject?.code, error)
        }
    }
    
    func register(email: String, code: String, completion: @escaping (String?, LoginResponse?, NetworkResponse?)->()) {
        networkManager.register(email: email, code: code) { (token, loginResponse, error) in
            completion(token, loginResponse, error)
        }
    }
    
    func loginWithPhoneNumber(number: String, completion: @escaping (LoginResponse?, NetworkResponse?)->()) {
        let currentUser = Auth.auth().currentUser
        currentUser?.getIDTokenForcingRefresh(true) { idToken, error in
            if error != nil {
            completion(nil, NetworkResponse.failed)
          } else if let token = idToken {
            self.networkManager.loginWithPhoneNumber(number: number, accessToken: token) { (responseObject, error) in
                completion(responseObject, error)
            }
          }
        }
    }
    
    func registerDevice(completion: @escaping (NetworkResponse?)->()) {
        RemoteNotificationManager.registerDeviceToken(pushDevicetoken: SharedConfigs.shared.deviceToken ?? "", voipDeviceToken: SharedConfigs.shared.voIPToken ?? "") { (error) in
            completion(error)
        }
    }
    
    func stringToDate(date:String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
        let parsedDate = formatter.date(from: date)
        return parsedDate
    }
    
    func parseUserData(_ loginResponse: LoginResponse?, _ token: String?, completion: @escaping (NetworkResponse?)->()) {
        let model = UserModel(name: loginResponse!.user.name, lastname: loginResponse!.user.lastname, username: loginResponse!.user.username, email: loginResponse!.user.email,  token: token!, id: loginResponse!.user.id, avatarURL: loginResponse!.user.avatarURL, phoneNumber: loginResponse!.user.phoneNumber, birthDate: loginResponse!.user.birthDate, tokenExpire: self.stringToDate(date: loginResponse!.tokenExpire), missedCallHistory: loginResponse!.user.missedCallHistory)
        UserDataController().saveUserSensitiveData(token: token!)
        UserDataController().populateUserProfile(model: model)
        self.registerDevice { (error) in
            completion(error)
        }
    }
    
    func saveUserInfo(_ loginResponse: LoginResponse?, _ token: String?) {
        SharedConfigs.shared.signedUser = loginResponse?.user
        SharedConfigs.shared.setIfLoginFromFacebook(isFromFacebook: false)
        SharedConfigs.shared.signedUser?.tokenExpire = self.stringToDate(date: loginResponse!.tokenExpire)
        UserDataController().saveUserSensitiveData(token: token!)
        UserDataController().saveUserInfo()
    }
    
    func signInWithFirebase(code: String, completion: @escaping AuthDataResultCallback) {
        let verificationID = UserDefaults.standard.string(forKey: "authVerificationID")
        if let verificationID = verificationID {
            let credential = PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: code)
            Auth.auth().signIn(with: credential) { (authResult, error) in
                completion(authResult, error)
            }
        }
    }
}

