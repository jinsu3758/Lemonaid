//
//  ApiUtil.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 7..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation
import Alamofire
import AlamofireObjectMapper
import RxSwift
import SwiftyJSON
import RxAlamofire
import ObjectMapper

class ApiUtil {
    
    static let baseUrl = "http://13.124.186.120:8080/"
    static let url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json"
    
    // MARK: 약국 선택 - POST
    static func setPharmacy(addr: Address) -> Completable {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.adapter = HeaderAdapter()
        
        return Completable.create { complete in
            sessionManager.request(Path.pharmacy.api, method: .post,
                                   parameters: addr.toDictionary(), encoding: JSONEncoding.default, headers: nil)
                .responseData { (response: DataResponse<Data>) in
                    if response.result.isSuccess
                    {
                        complete(.completed)
                    }
                    else {
                        guard let error = response.result.error else {return}
                        complete(.error(error))
                    }
            }
            return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: 질병리스트 요청 - GET
    static func getDiseaseList() -> Single<[String]> {
        return Single<[String]>.create { single in
            Alamofire.request(Path.diseaseList.api)
                .validate()
                .responseJSON { response in
                    if response.result.isSuccess {
                        if let data = response.result.value {
                            let json = JSON(data)
                            var object: [String] = []
                            for item in json[Key.disease.rawValue].arrayValue {
                                object.append(item["diseaseName"].stringValue)
                            }
                            single(.success(object))
                        }
                        single(.error(MadeError.invalidData))
                    }
                    else {
                        guard let error = response.result.error else {return}
                        single(.error(error))
                    }
            }
            return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: 약국리스트 요청 - GET
    static func getPharmacyList(location: String) -> Single<[Address]> {
        let parameter = [
            "location": location,
            "radius": Etc.radius.rawValue,
            "type": Etc.type.rawValue,
            "language": Etc.language.rawValue,
            "key": Key.map.rawValue
        ]
        var list: [Address] = []
        return Single<[Address]>.create { single in
            Alamofire.request(url, method: .get, parameters: parameter, encoding: URLEncoding.queryString, headers: nil)
                .validate()
                .responseJSON { response in
                    if response.result.isSuccess {
                        if let data = response.result.value {
                            let json = JSON(data)
                            for item in json["results"].arrayValue {
                                list.append(Address(item["geometry"]["location"]["lat"].doubleValue, item["geometry"]["location"]["lng"].doubleValue,
                                                    item["name"].stringValue, item["vicinity"].stringValue))
                            }
                            single(.success(list))
                        }
                        single(.error(MadeError.invalidData))
                    }
                    else {
                        guard let error = response.result.error else {return}
                        single(.error(error))
                    }
            }
            return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: 질병 상세 내용 요청 - GET
    static func getDiseaseContent(name: String) -> Single<Disease> {
        return Single<Disease>.create { single in
            Alamofire.request(Path.diseaseContent.api, method: .get, parameters: [Key.diseaseName.rawValue : name], encoding: URLEncoding.queryString, headers: nil)
                .responseObject { (response: DataResponse<Disease>) in
                    if response.result.isSuccess {
                        if let data = response.result.value {
                            single(.success(data))
                        }
                        single(.error(MadeError.invalidData))
                    }
                    else {
                        guard let error = response.result.error else {return}
                        single(.error(error))
                    }
            }
            return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
    }
    
    // MARK: 리뷰리스트 요청 - GET
    static func getReview() -> Single<[Review]> {
        return Single<[Review]>.create { single in
            Alamofire.request(Path.review.api)
                .validate()
                .responseJSON { response in
                    if response.result.isSuccess {
                        if let data = response.result.value {
                            let json = JSON(data)
                            if let str = json[Key.review.rawValue].rawString(),
                                let array = Mapper<Review>().mapArray(JSONString: str) {
                                single(.success(array))
                            }
                        }
                        single(.error(MadeError.invalidData))
                    }
                    else {
                        guard let error = response.result.error else { return }
                        single(.error(error))
                    }
            }
            return Disposables.create()
            }
            .observeOn(MainScheduler.instance)
        
    }
    
    // MARK: deviceId 요청 - GET
    static func getId() -> Single<String> {
        return Single<String>.create { single in
            Alamofire.request(Path.receiveId.api, method: .post, parameters: nil, encoding: JSONEncoding.default, headers: nil)
                .responseObject { (response: DataResponse<User>) in
                    if response.result.isSuccess {
                        if let data = response.result.value {
                            if data.isState == State.success.rawValue {
                                single(.success(data.key))
                            }
                        }
                        single(.error(MadeError.invalidId))
                    }
                    else {
                        guard let error = response.result.error else {return}
                        single(.error(error))
                    }
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }
    
    static func setRefund(_ bool: Bool) -> Completable {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.adapter = HeaderAdapter()
        print("\(SingleData.instance.deviceId!)!!!!")
        return Completable.create { complete in
            sessionManager.request(Path.setRefund.api, method: .get, parameters: [Key.isRefund.rawValue : bool], encoding: URLEncoding.queryString, headers: nil)
                .responseData { (response: DataResponse<Data>) in
                    if response.result.isSuccess {
                        print("\(response.response?.statusCode)!!!")
                        complete(.completed)
                    }
                    else {
                        guard let error = response.result.error else {return}
                        print("\(response.response?.statusCode)!!!")
                        complete(.error(error))
                    }
            }
            return Disposables.create()
        }.observeOn(MainScheduler.instance)
    }

    
}

