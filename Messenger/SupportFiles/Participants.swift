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
//
//public class User: NSObject,  Codable, NSCoding {
//    public var name: String?
//    public var lastname: String?
//    public var university: String?
//    public var _id: String?
//    public var username: String?
//    public var avatarURL: String?
//    public var email: String?
//    public var info: String?
//    public var phoneNumber: String?
//    public var birthday: String?
//    public var address: String?
//    public var gender: String?
//
//    init(name: String?, lastname: String?, university: String?, _id: String, username: String?, avaterURL: String?, email: String?, info: String?, phoneNumber: String?, birthday: String?, address: String?, gender: String?) {
//        self.name = name
//        self.lastname = lastname
//        self.university = university
//        self._id = _id
//        self.username = username
//        self.avatarURL = avaterURL
//        self.email = email
//        self.info = info
//        self.phoneNumber = phoneNumber
//        self.birthday = birthday
//        self.address = address
//        self.gender = gender
//    }
//
//    public override init() {
//        super.init()
//    }
//
//    public func encode(with aCoder: NSCoder) {
//        aCoder.encode(name, forKey: "name")
//        aCoder.encode(lastname, forKey: "lastname")
//        aCoder.encode(university, forKey: "university")
//        aCoder.encode(_id, forKey: "_id")
//        aCoder.encode(username, forKey: "username")
//        aCoder.encode(avatarURL, forKey: "avatarURL")
//        aCoder.encode(email, forKey: "email")
//        aCoder.encode(info, forKey: "info")
//        aCoder.encode(phoneNumber, forKey: "phoneNumber")
//        aCoder.encode(birthday, forKey: "birthday")
//        aCoder.encode(address, forKey: "address")
//        aCoder.encode(gender, forKey: "gender")
//    }
//
//    public required convenience init?(coder aDecoder: NSCoder) {
//        let mName = aDecoder.decodeObject(forKey: "name") as? String
//        let mLastname = aDecoder.decodeObject(forKey: "lastname") as? String
//        let mUniversity = aDecoder.decodeObject(forKey: "university") as? String
//        let mId = aDecoder.decodeObject(forKey: "_id") as? String
//        let mUsername = aDecoder.decodeObject(forKey: "username") as? String
//        let mEmailL = aDecoder.decodeObject(forKey: "email") as? String
//        let mInfo = aDecoder.decodeObject(forKey: "info") as? String
//        let mPhoneNumber = aDecoder.decodeObject(forKey: "phoneNumber") as? String
//        let mAvatarURL = aDecoder.decodeObject(forKey: "avatarURL") as? String
//        let mBirthday = aDecoder.decodeObject(forKey: "birthday") as? String
//        let mAddress = aDecoder.decodeObject(forKey: "address") as? String
//        let mGender = aDecoder.decodeObject(forKey: "gender") as? String
//        self.init(name: mName, lastname: mLastname, university: mUniversity, _id: mId!, username: mUsername, avaterURL: mAvatarURL, email: mEmailL, info: mInfo, phoneNumber: mPhoneNumber, birthday: mBirthday, address: mAddress, gender: mGender)
//    }
//
//}
