//
//  ReviewList.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 23..
//  Copyright © 2018년 박진수. All rights reserved.
//
import ObjectMapper

struct ReviewList: Mappable {
    
    var reviews: [Review] = []
    
    init?(map: Map) {}
    
    mutating func mapping(map: Map) {
        reviews <- map["review"]
    }
    
}
