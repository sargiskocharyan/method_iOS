//
//  Participants.swift
//  Messenger
//
//  Created by Employee1 on 8/7/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation



public class Participants: NSObject, NSCoding, NSSecureCoding {
    
    public var participants: [String] = []
    public static var supportsSecureCoding = true
    enum Key:String {
        case participants = "participants"
    }
    
    init(participants: [String]) {
        self.participants = participants
    }
    
    public func encode(with aCoder: NSCoder) {
        aCoder.encode(participants, forKey: Key.participants.rawValue)
    }
    
    public required convenience init?(coder aDecoder: NSCoder) {
        let mParticipants = aDecoder.decodeObject(forKey: Key.participants.rawValue) as! [String ]
        
        self.init(participants: mParticipants)
    }
    
    
}
