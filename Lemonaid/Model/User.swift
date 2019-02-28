//
//  User.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 14..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation
import RealmSwift
import AlamofireObjectMapper
import RxSwift
import ObjectMapper
import Realm

class User: Object, Mappable {
    @objc dynamic var key: String = ""
    @objc dynamic var isState: Int = 0
    
    required init?(map: Map) { super.init()}
    
    required public init() { super.init() }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) { super.init(realm: realm, schema: schema) }
    
    required init(value: Any, schema: RLMSchema) { super.init(value: value, schema: schema) }
    
    
    
    func mapping(map: Map) {
        key <- map["deviceId"]
        isState <- map["isState"]
    }
    
    
    
    
}
