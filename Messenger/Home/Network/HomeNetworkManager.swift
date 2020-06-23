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
    
    func getUserContacts(completion: @escaping ([ContactResponseWithId]?, String?, Int?)->()) {
   router.request(.getUserContacts) { data, response, error in
       if error != nil {
           print(error!.localizedDescription)
           completion(nil, error?.localizedDescription, nil)
       }
       if let response = response as? HTTPURLResponse {
           let result = self.handleNetworkResponse(response)
           switch result {
           case .success:
               guard let responseData = data else {
                completion(nil, nil, response.statusCode)
                   return
               }
               do {
                    let responseObject = try JSONDecoder().decode([ContactResponseWithId].self, from: responseData)
                    completion(responseObject, nil, response.statusCode)
               } catch {
                   print(error)
                completion(nil, error.localizedDescription, response.statusCode)
               }
           case .failure( _):
                guard let responseData = data else {
                    completion(nil, nil, response.statusCode)
                    return
                }
               do {
                    let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                completion(nil, errorObject.Error, response.statusCode)
               } catch {
                   print(error)
                completion(nil, error.localizedDescription, response.statusCode)
               }
           }
       }
   }
}
    
    func findUsers(term: String, completion: @escaping (FindUserResponse?, String?, Int?)->()) {
        router.request(.findUsers(term: term)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(nil, error?.localizedDescription, nil)
            }
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                    do {
                         let responseObject = try JSONDecoder().decode(FindUserResponse.self, from: responseData)
                         completion(responseObject, nil, response.statusCode)
                    } catch {
                        print(error)
                        completion(nil, nil, response.statusCode)
                    }
                case .failure( _):
                   guard let responseData = data else {
                         completion(nil, nil, response.statusCode)
                         return
                     }
                    do {
                         let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                     completion(nil, errorObject.Error, response.statusCode)
                    } catch {
                        print(error)
                     completion(nil, error.localizedDescription, response.statusCode)
                    }
                }
            }
        }
    }
    
    func addContact(id: String, completion: @escaping (String?, Int?)->()) {
        router.request(.addContact(id: id)) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(error?.localizedDescription, nil)
            }
          
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                        completion(nil, response.statusCode)
                case .failure( _):
                   guard let responseData = data else {
                         completion("Something went wrong", response.statusCode)
                         return
                     }
                    do {
                         let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                     completion(errorObject.Error, response.statusCode)
                    } catch {
                     completion(error.localizedDescription, response.statusCode)
                    }
                }
            }
        }
    }
        func logout(completion: @escaping (String?, Int?)->()) {
        router.request(.logout) { data, response, error in
            if error != nil {
                print(error!.localizedDescription)
                completion(error?.localizedDescription, nil)
            }
          
            if let response = response as? HTTPURLResponse {
                let result = self.handleNetworkResponse(response)
                switch result {
                case .success:
                        completion(nil, response.statusCode)
                case .failure( _):
                   guard let responseData = data else {
                         completion("Something went wrong", response.statusCode)
                         return
                     }
                    do {
                         let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                     completion(errorObject.Error, response.statusCode)
                    } catch {
                     completion(error.localizedDescription, response.statusCode)
                    }
                }
            }
        }
    
}
    
    func getChats(completion: @escaping ([Chat]?, String?, Int?)->()) {
       router.request(.getChats) { data, response, error in
           if error != nil {
               print(error!.localizedDescription)
               completion(nil, error?.localizedDescription, nil)
           }
         
           if let response = response as? HTTPURLResponse {
               let result = self.handleNetworkResponse(response)
               switch result {
               case .success:
                   guard let responseData = data else {
                       completion(nil, nil, response.statusCode)
                       return
                   }
                   do {
                        let responseObject = try JSONDecoder().decode([Chat].self, from: responseData)
                        completion(responseObject, nil, response.statusCode)
                   } catch {
                       print(error)
                    completion(nil, error.localizedDescription, response.statusCode)
                   }
               case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                   do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                    completion(nil, errorObject.Error, response.statusCode)
                   } catch {
                       print(error)
                    completion(nil, error.localizedDescription, response.statusCode)
                   }
               }
           }
       }
    }
    
    func getChatMessages(id: String,  completion: @escaping ([Message]?, String?, Int?)->()) {
        router.request(.getChatMessages(id: id)) { data, response, error in
              if error != nil {
                  print(error!.localizedDescription)
                  completion(nil, error?.localizedDescription, nil)
              }
              if let response = response as? HTTPURLResponse {
                  let result = self.handleNetworkResponse(response)
                  switch result {
                  case .success:
                      guard let responseData = data else {
                          completion(nil, nil, response.statusCode)
                          return
                      }
                      do {
                           let responseObject = try JSONDecoder().decode([Message].self, from: responseData)
                           completion(responseObject, nil, response.statusCode)
                      } catch {
                          print(error)
                       completion(nil, error.localizedDescription, response.statusCode)
                      }
                  case .failure( _):
                       guard let responseData = data else {
                           completion(nil, nil, response.statusCode)
                           return
                       }
                      do {
                           let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                       completion(nil, errorObject.Error, response.statusCode)
                      } catch {
                          print(error)
                       completion(nil, error.localizedDescription, response.statusCode)
                      }
                  }
              }
          }
       }
    func getuserById(id: String,  completion: @escaping (UserById?, String?, Int?)->()) {
     router.request(.getUserById(id: id)) { data, response, error in
           if error != nil {
               print(error!.localizedDescription)
               completion(nil, error?.localizedDescription, nil)
           }
           if let response = response as? HTTPURLResponse {
               let result = self.handleNetworkResponse(response)
               switch result {
               case .success:
                   guard let responseData = data else {
                       completion(nil, nil, response.statusCode)
                       return
                   }
                   do {
                        let responseObject = try JSONDecoder().decode(UserById.self, from: responseData)
                        completion(responseObject, nil, response.statusCode)
                   } catch {
                       print(error)
                    completion(nil, error.localizedDescription, response.statusCode)
                   }
               case .failure( _):
                    guard let responseData = data else {
                        completion(nil, nil, response.statusCode)
                        return
                    }
                   do {
                        let errorObject = try JSONDecoder().decode(ErrorResponse.self, from: responseData)
                    completion(nil, errorObject.Error, response.statusCode)
                   } catch {
                       print(error)
                    completion(nil, error.localizedDescription, response.statusCode)
                   }
               }
           }
       }
    }
}
