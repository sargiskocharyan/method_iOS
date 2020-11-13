//
//  CallNetworkManager.swift
//  Messenger
//
//  Created by Employee1 on 11/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
class CallNetworkManager: NetworkManager {
   
    let router = Router<CallApi>()

    func readCalls(id: String, readOne: Bool, completion: @escaping (NetworkResponse?)->()) {
        router.request(.readCalls(id: id, readOne: readOne)) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(error)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    completion(nil)
                case .failure( _):
                    completion(NetworkResponse.failed)
                }
            }
        }
    }
    
    func removeCall(id: [String], completion: @escaping (NetworkResponse?)->()) {
           router.request(.removeCall(id: id)) { data, response, error in
               if error != nil {
                   print(error!.rawValue)
                   completion(error)
               }
               if let response = response as? HTTPURLResponse {
                   let result = self.handleNetworkResponse(response)
                   switch result {
                   case .success:
                       completion(nil)
                   case .failure( _):
                       completion(NetworkResponse.failed)
                   }
               }
           }
       }
    
    
    func getCallHistory(completion: @escaping ([CallHistory]?, NetworkResponse?)->()) {
        router.request(.getCallHistory) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(nil, error)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, error)
                        return
                    }
                    do {
                        let responseObject = try JSONDecoder().decode([CallHistory].self, from: responseData)
                        completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure(_):
                    completion(nil, NetworkResponse.failed)
                }
            }
        }
    }
}
