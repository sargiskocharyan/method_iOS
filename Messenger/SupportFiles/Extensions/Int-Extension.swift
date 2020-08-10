//
//  Int-Extension.swift
//  Messenger
//
//  Created by Employee1 on 8/10/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

extension Int {
    func secondsToHoursMinutesSeconds() -> String {
        if self / 3600 == 0 && ((self % 3600) / 60) == 0 {
            return "\((self % 3600) % 60) sec."
        } else if self / 3600 == 0 {
            return "\((self % 3600) / 60) min. \((self % 3600) % 60) sec."
        }
        return "\(self / 3600) hr. \((self % 3600) / 60) min. \((self % 3600) % 60) sec."
    }
}
