//
//  EditInformationViewModel.swift
//  Messenger
//
//  Created by Employee1 on 7/8/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class EditInformationViewModel {
    func deleteAccount(completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().deleteAccount() { (error) in
            completion(error)
        }
    }
    
    func deactivateAccount(completion: @escaping (NetworkResponse?)->()) {
           HomeNetworkManager().deactivateAccount() { (error) in
               completion(error)
           }
       }
    
    func editInformation(name: String?, lastname: String?, username: String?, phoneNumber: String?, info: String?, gender: String?, birthDate: String?, email: String?, university: String?, completion: @escaping (UserModel?, NetworkResponse?)->()) {
        HomeNetworkManager().editInformation(name: name, lastname: lastname, username: username, phoneNumber: phoneNumber, info: info, gender: gender, birthDate: birthDate, email: email, university: university) { (user, error) in
            completion(user, error)
        }
    }
}
