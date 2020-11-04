//
//  SharedConfigs.swift
//  Messenger
//
//  Created by Employee1 on 6/2/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import Foundation

class SharedConfigs {
    
    static var shared: SharedConfigs = SharedConfigs()
    var signedUser: UserModel?
    var deviceToken: String?
    var voIPToken: String?
    var isRegistered: Bool?
    var deviceUUID: String?
    var contactRequests: [Request] = []
    var unreadMessages: [Chat] = []
    var missedCalls: [String] = []
    var adminMessages: [AdminMessage] = []
    var isLoginFromFacebook: Bool = false
    
    private init () {
       let _ = appLang
    }
    
    func setIfLoginFromFacebook(isFromFacebook: Bool)  {
        isLoginFromFacebook = isFromFacebook
        UserDefaults.standard.setValue(isLoginFromFacebook, forKey: "isLoginFromFacebook")
    }
    
    func getNumberOfNotifications() -> Int {
        let filteredRequests = contactRequests.filter { (request) -> Bool in
            return request.receiver == signedUser?.id
        }
        return filteredRequests.count + unreadMessages.count + adminMessages.count + missedCalls.count
    }
    
    var mode: String = ""
    var isHidden: Bool = false
    
    func setMode(selectedMode: String) {
        mode = selectedMode
        UserDefaults.standard.set(mode, forKey: "mode")
    }
    
    func setIsHidden(selectIsHidden: Bool) {
           isHidden = selectIsHidden
           UserDefaults.standard.set(isHidden, forKey: "isHidden")
       }
    
    private var _appLang: String?
    public var appLang: String? {
        get {
            if self._appLang == nil {
                self._appLang = UserDefaults.standard.object(forKey: Keys.APP_Language) as? String
                
                if self._appLang == nil {
                    let languages = NSLocale.preferredLanguages
                    var preferredLanguage: String?
                    for lan in languages {
                        let langPref = (lan as NSString).substring(to: 2)
                        if langPref == "en" {
                            preferredLanguage = AppLangKeys.Eng
                            break
                        }
                        if langPref == "hy" {
                            preferredLanguage = AppLangKeys.Arm
                            break
                        }
                        if langPref == "ru" {
                            preferredLanguage = AppLangKeys.Rus
                            break
                        }
                    }
                    UserDefaults.standard.set(preferredLanguage, forKey: Keys.APP_Language)
                    UserDefaults.standard.synchronize()
                }
                self._appLang = UserDefaults.standard.object(forKey: Keys.APP_Language) as? String
            }
            return self._appLang
        }
        set {
            self._appLang = newValue
        }
    }
    
    func setAppLang(lang: String? ) {
        if lang != nil {
            appLang = lang
            UserDefaults.standard.set(appLang, forKey: Keys.APP_Language)
            UserDefaults.standard.synchronize()
        }
    }
}
