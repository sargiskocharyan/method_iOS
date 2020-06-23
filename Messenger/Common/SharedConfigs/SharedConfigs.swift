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
    
    private init () {
       let _ = appLang
    }
    
    var mode: String = ""
    
    func setMode(selectedMode: String) {
        mode = selectedMode
        UserDefaults.standard.set(mode, forKey: "mode")
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
