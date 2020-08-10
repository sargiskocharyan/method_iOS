//
//  Date-Extension.swift
//  Messenger
//
//  Created by Employee1 on 8/10/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

extension Date {
    func dateToString() -> String {
        let parsedDate = self
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
             return "\(day >= 10 ? "\(day)" : "0\(day)").\(month >= 10 ? "\(month)" : "0\(month)")"
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        return "\(hour >= 10 ? "\(hour)" : "0\(hour)"):\(minutes >= 10 ? "\(minutes)" : "0\(minutes)")"
    }
}


