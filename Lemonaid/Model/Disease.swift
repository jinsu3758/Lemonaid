//
//  Disease.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 25..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import ObjectMapper
import Alamofire
import RxSwift

struct Disease: Mappable {

    private let disposeBag = DisposeBag()
    var title: String!
    var introduce: String!
    var colorIndex: Int!
    var guideExam: String!
    var guidePay: String!
    var guidePresc: String!
    var guidePick: String!
    var define: String!
    var treatAndRisk: String!
    var exceptComment: String!
    var exceptTarget: [String] = []
    var guideStart: String!
    var medicineName: String!

    init(_ title: String) {
        self.title = title
        colorIndex = 0
    }
    
    init(_ title: String, _ count: Int) {
        self.title = title
        colorIndex = count
    }

    init?(map: Map) {
    }

    mutating func mapping(map: Map) {
        title <- map["name"]
        introduce <- map["intro"]
        guideExam <- map["guideExam"]
        guidePay <- map["guidePay"]
        guidePresc <- map["guidePresc"]
        guidePick <- map["guidePick"]
        define <- map["define"]
        treatAndRisk <- map["treatAndRisk"]
        exceptTarget <- map["exceptService"]
        exceptComment <- map["comment"]
        guideStart <- map["guideStart"]
        medicineName <- map["medicineName"]
    }
    
    // MARK: 질병 상세 데이터 GET
    mutating func getDisease(callback: @escaping (Disease?) -> ()) {
        ApiUtil.getDiseaseContent(name: self.title)
            .subscribe { event in
                switch event {
                case .success(let data):
                    callback(data)
                case .error(let error):
                    callback(nil)
                    debugPrint(error)
                }
            }
            .disposed(by: disposeBag)
    }
    
}


