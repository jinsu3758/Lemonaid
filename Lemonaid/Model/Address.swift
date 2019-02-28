//
//  Address.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 22..
//  Copyright © 2018년 박진수. All rights reserved.
//

struct Address {
    var lat: Double = 0.0
    var lng: Double = 0.0
    var name: String = ""
    var address: String = ""
    
    init(_ lat: Double, _ lng: Double, _ name: String, _ address: String) {
        self.lat = lat
        self.lng = lng
        self.name = name
        self.address = address
    }
    init(_ lat: Double, _ lng: Double, _ name: String) {
        self.lat = lat
        self.lng = lng
        self.name = name
    }
    
    func toDictionary() -> [String: Any] {
        return [
            "lat": lat,
            "lng": lng,
            "name": name
        ]
    }
}
