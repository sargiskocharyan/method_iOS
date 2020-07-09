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
}
