//
//  AuthNetworkManager.swift
//  DragonMoney
//
//  Created by Sargis Kocharyan on 3/4/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation


class HomeNetworkManager: NetworkManager {
    
    let router = Router<HomeApi>()
    
    func getUserContacts(completion: @escaping ([ContactResponseWithId]?, NetworkResponse?)->()) {
   router.request(.getUserContacts) { data, response, error in
       if error != nil {
        print(error?.rawValue)
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
                    let responseObject = try JSONDecoder().decode([ContactResponseWithId].self, from: responseData)
                completion(responseObject, nil)
               } catch {
                print(error)
                completion(nil, NetworkResponse.unableToDecode)
               }
           case .failure(_):
                guard let responseData = data else {
                    completion(nil, error)
                    return
                }
               do {
                    let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                completion(nil, error)
               } catch {
                   print(error)
                completion(nil, NetworkResponse.unableToDecode)
               }
           }
       }
   }
}
    
    func findUsers(term: String, completion: @escaping (FindUserResponse?, NetworkResponse?)->()) {
        router.request(.findUsers(term: term)) { data, response, error in
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
                         let responseObject = try JSONDecoder().decode(FindUserResponse.self, from: responseData)
                         completion(responseObject, nil)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                case .failure( _):
                   guard let responseData = data else {
                         completion(nil, error)
                         return
                     }
                    do {
                         let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                     completion(nil, error)
                    } catch {
                        print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                    }
                }
            }
        }
    }
    
    func addContact(id: String, completion: @escaping (NetworkResponse?)->()) {
        router.request(.addContact(id: id)) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(error)
            }
          
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                        completion(error)
                case .failure( _):
                   guard let responseData = data else {
                         completion(error)
                         return
                     }
                    do {
                         let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                     completion(nil)
                    } catch {
                        completion(NetworkResponse.unableToDecode)
                    }
                }
            }
        }
    }
        func logout(completion: @escaping (NetworkResponse?)->()) {
        router.request(.logout) { data, response, error in
            if error != nil {
                print(error!.rawValue)
                completion(error)
            }
          
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                        completion(error)
                case .failure( _):
                   guard let responseData = data else {
                         completion(error)
                         return
                     }
                    do {
                         let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                     completion(nil)
                    } catch {
                        completion(NetworkResponse.unableToDecode)
                    }
                }
            }
        }
    
}
    
    func getChats(completion: @escaping ([Chat]?, NetworkResponse?)->()) {
       router.request(.getChats) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode([Chat].self, from: responseData)
                        completion(responseObject, nil)
                   } catch {
                       print(error)
                    completion(nil, NetworkResponse.unableToDecode)
                   }
               case .failure( _):
                    guard let responseData = data else {
                        completion(nil, error)
                        return
                    }
                   do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                    completion(nil, error)
                   } catch {
                       print(error)
                    completion(nil, NetworkResponse.unableToDecode)
                   }
               }
           }
       }
    }
    
    func getChatMessages(id: String,  completion: @escaping ([Message]?, NetworkResponse?)->()) {
        router.request(.getChatMessages(id: id)) { data, response, error in
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
                           let responseObject = try JSONDecoder().decode([Message].self, from: responseData)
                           completion(responseObject, nil)
                      } catch {
                          print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                      }
                  case .failure( _):
                       guard let responseData = data else {
                           completion(nil, error)
                           return
                       }
                      do {
                           let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                       completion(nil, error)
                      } catch {
                          print(error)
                        completion(nil, NetworkResponse.unableToDecode)
                      }
                  }
              }
          }
       }
    func getuserById(id: String,  completion: @escaping (UserById?, NetworkResponse?)->()) {
     router.request(.getUserById(id: id)) { data, response, error in
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
                        let responseObject = try JSONDecoder().decode(UserById.self, from: responseData)
                        completion(responseObject, nil)
                   } catch {
                       print(error)
                    completion(nil, NetworkResponse.unableToDecode)
                   }
               case .failure( _):
                    guard let responseData = data else {
                        completion(nil, error)
                        return
                    }
                   do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                    completion(nil, error)
                   } catch {
                       print(error)
                    completion(nil, NetworkResponse.unableToDecode)
                   }
               }
           }
       }
    }
}
