//
//  UserDefaultsUtil.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 1..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation

protocol UserDefaultTabel {
    associatedtype DefaultKey: RawRepresentable
}

class UserDefaultsUtil: UserDefaultTabel {
    
    enum DefaultKey: String {
        case disease = "disease"
        case deviceId = "deviceId"
        case isPay = "isPay"
    }
    
    static let defaults = UserDefaults.standard
    
    static func getString(_ key: DefaultKey) -> String {
        return defaults.string(forKey: key.rawValue)!
    }
    
    static func setString(_ key: DefaultKey, id: String) {
        defaults.set(id, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    static func isEmpty(key: DefaultKey) -> Bool {
        if defaults.value(forKey: key.rawValue) != nil {
            return true
        }
        else {
            return false
        }
    }
    
    static func setBool(_ bool: Bool, key: DefaultKey) {
        defaults.set(bool, forKey: key.rawValue)
        defaults.synchronize()
    }
    
    static func isBool(_ key: DefaultKey) -> Bool {
        return defaults.bool(forKey: key.rawValue)
    }
    
    
    
    
}
