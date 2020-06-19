//
//  JSONEncoding.swift
//
//  Created by sargis on 03/02/20.
//  Copyright © 2020 Sargis Kocharyan. All rights reserved.
//

import Foundation
import CryptoSwift

public struct JSONParameterEncoder: ParameterEncoder {
    
    public func encode(urlRequest: inout URLRequest, with parameters: Parameters, encrypted: Bool) throws {
        do {
            let jsonAsData = try JSONSerialization.data(withJSONObject: parameters, options: .prettyPrinted)
            if encrypted == true {
                let key: String? = ""
                let iv: String? = ""
                if iv != nil && key != nil {
                    do {
                        
                        let aes = try AES(key: key!.bytes, blockMode: CBC(iv: iv!.bytes), padding: .pkcs7)
                        var encryptedArray = try aes.encrypt(jsonAsData.bytes)
                        let encryptedData =  NSData(bytes: &encryptedArray, length: encryptedArray.count)
                        let encryptedString = encryptedData.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
                        
                       urlRequest.httpBody = encryptedString.data(using: .utf8)

                    } catch {
                        print("An error occurred while encrypting body: ",error)
                    }
                }
                else {
                    print("Error: iv or key is null")
                }
            }
            else {
                urlRequest.httpBody = jsonAsData
            }
            
            if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            }
        }catch {
            throw NetworkError.encodingFailed
        }
    }
}

