//
//  Review.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 29..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import ObjectMapper

struct Review: Mappable {
    
    var comment: String = ""
    var date: String = ""

    init?(map: Map) {}

    mutating func mapping(map: Map) {
        comment <- map["comment"]
        date <- map["regTime"]
    }
    
    init(_ comment: String, _ date: String) {
        self.comment = comment
        self.date = date
    }
    
    

}
