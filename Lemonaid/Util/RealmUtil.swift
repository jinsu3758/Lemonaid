//
//  RealmUtil.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 14..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
import RxRealm
import RxSwift

class RealmUtil {
    static let realm = try! Realm()
    
    static func setUser(_ user: User) {
        try! realm.write {
            realm.add(user)
        }
    }
    
    static func getUser() -> Observable<Results<User>> {
        return Observable.collection(from: realm.objects(User.self))
    }
    
    static func isUser() -> Bool {
        return realm.objects(User.self).first != nil
    }
}
