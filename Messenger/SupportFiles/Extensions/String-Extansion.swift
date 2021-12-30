//
//  String-Extansion.swift
//  Messenger
//
//  Created by Employee1 on 5/25/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

extension String {
    func isValidEmail() -> Bool {
        let regex = try! NSRegularExpression(pattern:  "^[a-zA-Z0-9\\+\\.\\_\\%\\-\\+]{2,256}" +
               "\\@" + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,64}" + "(" + "\\." + "[a-zA-Z0-9][a-zA-Z0-9\\-]{0,25}" + ")+$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func isValidNameOrLastname() -> Bool {
         let regex = try! NSRegularExpression(pattern:  "^[a-zA-Z]{2,30}$", options: .caseInsensitive)
               return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
    func isValidUsername() -> Bool {
         let regex = try! NSRegularExpression(pattern:  "^[a-zA-Z0-9](_(?!(\\.|_|-))|\\.(?!(_|-|\\.))|-(?!(\\.|_|-))|[a-zA-Z0-9]){2,18}[a-zA-Z0-9]$", options: .caseInsensitive)
               return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }
    
     func isValidDate() -> Bool {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "dd/MM/yyyy"
        if let _ = dateFormatterGet.date(from: self) {
            return true
        } else {
            return false
        }
    }
    
    func isValidNumber() -> Bool {
        let regex = try! NSRegularExpression(pattern: "^((\\+374)+([0-9]){8})$", options: .caseInsensitive)
        return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: count)) != nil
    }

}
extension String  {
    func localized() ->String {
        let lang = SharedConfigs.shared.appLang
        let path = Bundle.main.path(forResource: lang, ofType: "lproj")
        let bundle = Bundle(path: path!)
        return NSLocalizedString(self, tableName: nil, bundle: bundle!, value: "", comment: "")
    }
}

