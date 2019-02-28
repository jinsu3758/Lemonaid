//
//  SingleData.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 14..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation
import WebKit
import UIKit

class SingleData {
    static let instance = SingleData()
    
    var disease: Disease = Disease("")  // 앱 전체에서 사용할 질병 상세 데이터
    var deviceId: String?
    var isLogin: Bool = false   // 로그인 여부
    var isPay: Bool = false     // 환불처리 여부
    var processPool = WKProcessPool()
    
    private init() {}
    
    /// HTTPCookie를 JavaScript문으로 변환해주는 함수
    ///
    /// - Parameter cookies: 변환할 쿠키
    /// - Returns: 변환된 스크립트문 String 값
    func getJSCookiesString(for cookies: [HTTPCookie]) -> String {
        var result = ""
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        dateFormatter.dateFormat = "EEE, d MMM yyyy HH:mm:ss zzz"
        
        for cookie in cookies {
            result += "document.cookie='\(cookie.name)=\(cookie.value); domain=\(cookie.domain); path=\(cookie.path); "
            if let date = cookie.expiresDate {
                result += "expires=\(dateFormatter.string(from: date)); "
            }
            if (cookie.isSecure) {
                result += "secure; "
            }
            result += "'; "
        }
        return result
    }

}


