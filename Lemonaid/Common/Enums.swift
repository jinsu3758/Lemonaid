//
//  Enums.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 27..
//  Copyright © 2018년 박진수. All rights reserved.
//

import Foundation
import UIKit

// MARK: GuideViewController의 ContainerView 식별값
enum Container: Int {
    case processGuide = 1
    case main = 2
    case define = 3
    case treat = 4
    case except = 5
}
// MARK: URL path
enum Path: String {
    case diseaseList = "disease"
    case diseaseContent = "intro"
    case login = "login"
    case review = "review"
    case receiveId = "receiveId"
    case question = "question"
    case logout = "logout"
    case pharmacy = "saveMapLocation"
    case setRefund = "setRefund"
    case isRefund = "getRefund"
    var instance: String {
        return ApiUtil.baseUrl + self.rawValue
    }
    var api: String {
        return ApiUtil.baseUrl + "api/" + self.rawValue
    }
}
enum VC: String {
    case loginVC = "loginVC"
    case examVC = "examVC"
    case mapVC = "mapVC"
    case prescVC = "prescVC"
    case callVC = "callVC"
    case mikeTestVC = "mikeTestVC"
    case guideVC = "guideVC"
    case mainVC = "mainVC"
    case completePrescVC = "completePrescVC"
    case videoVC = "videoVC"
}
enum State: Int {
    case success = 1
    case fail = -1
//    case alert = 0
}
enum Key: String {
    case map = "AIzaSyBg2F8JxFhvWqyMXvcI2kmsMJ40NDYyxOQ"
    case disease = "disease"
    case diseaseName = "disease_name"
    case priority = "priority"
    case priorityValue = "1"
    case estimateProgress = "estimatedProgress"
    case diseaseCell = "diseaseCell"
    case reviewCell = "reviewCell"
    case exceptCell = "exceptCell"
    case isRefund = "isNeedRefund"
    case location = "Location"
    case review = "review"
    case isLogin = "isLogin"
    case loginDeviceId = "loginDeviceId"
}

// MARK: 웹뷰 response
enum Flow: String {
    case onLogin = "onLogin"
    case survey = "survey"
    case login = "login"
    case cash = "cash"
    case signIn = "signIn"
    case order = "order"
    case end = "end"
    case fail = "fail"
}
enum Message: String {
    case network = "networkError"
    case request = "requestError"
    case refund = "refundError"
    case locationAuthor = "locationAuthor"
    case gps = "gpsError"
    case voiceAuthor = "voiceAuthor"
    case mikeAuthor = "mikeAuthor"
    case selectPharmacy = "selectPharmacyError"
    case mike = "mikeError"
    case examExit = "examExit"
    case signExit = "signExit"
    case orderExit = "orderExit"
    case payExit = "payExit"
    var instance: String {
        return self.rawValue.localized
    }
}

enum Cookie: String {
    case path = "/"
    case domain = "13.124.186.120"
    case name = "deviceId"
    case script = "document.cookie='domain=13.124.186.120; path=/; "
    var full: String {
        return self.rawValue + "DeviceId=\(SingleData.instance.deviceId!) '"
    }
}

enum Etc: String {
    case tel = "facetime://010-3934-8692"
    case radius = "1500"
    case type = "pharmacy"
    case language = "ko"
}

enum Image: String {
    case back = "back"
    case logo = "logo"
    case progressPay = "progressPay"
    case reload = "reload"
    case checkOrange = "checkOrange"
    case mikeOn = "mikeOn"
    case failOrange = "failOrange"
    var instance: String {
        return self.rawValue + ".png"
    }
}

enum AppStoryboard: String {
    case main = "Main"
    case exam = "Exam"
    case guide = "Guide"
    case treat = "Treat"
    case presc = "Presc"
    
    var instance: UIStoryboard {
        return UIStoryboard(name: self.rawValue, bundle: Bundle.main)
    }
}

enum MadeError: Error {
    case invalidId
    case invalidData
    case alreadyLogin
}
