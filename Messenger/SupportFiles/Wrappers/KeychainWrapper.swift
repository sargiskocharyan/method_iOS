//
//  File.swift
//  Articles
//
//  Created by Employee1 on 5/19/20.
//  Copyright © 2020 employee. All rights reserved.
//

import Foundation

class KeyChain {
      class func save(key: String, data: Data) -> OSStatus {
          let query = [
              kSecClass as String       : kSecClassGenericPassword as String,
              kSecAttrAccount as String : key,
              kSecValueData as String   : data ] as [String : Any]

          SecItemDelete(query as CFDictionary)

          return SecItemAdd(query as CFDictionary, nil)
      }

    
     class func load(key: String) -> Data? {
          let query = [
              kSecClass as String       : kSecClassGenericPassword,
              kSecAttrAccount as String : key,
              kSecReturnData as String  : kCFBooleanTrue!,
              kSecMatchLimit as String  : kSecMatchLimitOne ] as [String : Any]

          var dataTypeRef: AnyObject? = nil

          let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

          if status == noErr {
              return dataTypeRef as! Data?
          } else {
              return nil
          }
      }
    
    class func remove(key: String) -> OSStatus {
        let query = [
            kSecClass as String       : kSecClassGenericPassword as String,
            kSecAttrAccount as String : key ] as [String : Any]
        return SecItemDelete(query as CFDictionary)
    }
}
