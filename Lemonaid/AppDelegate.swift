//
//  AppDelegate.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 25..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift
import Alamofire
import Fabric
import Crashlytics
import Quickblox
import QuickbloxWebRTC
import UserNotifications
import PushKit
import CallKit

protocol initDelegate {
    func checkInitData(_ state: State)
}

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var mainDelegate: initDelegate?
    
    private let disposeBag = DisposeBag()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        GMSServices.provideAPIKey(Key.map.rawValue)
        GMSPlacesClient.provideAPIKey(Key.map.rawValue)
        getInitData()
        Fabric.with([Crashlytics.self])
        
        CallManager.instance.setCall(id: 75837, authKey: "RudkTdNRUL3q6b6", authSecret: "FMuxCzGC6jasZDG", accountKey: "hJDEWM3rW4Za3CiMEsrC")
        CallManager.instance.onLogin(completion: { response in
            switch response {
            case .success:
                CallManager.instance.registerForRemoteNotification()
            case .error(let error):
                guard let error = error else { break }
                print("\(error?.localizedDescription)!")
            }
        })
        
        return true
    }
    
    func getInitData() {
        // MARK: 첫 실행 시 deviceId 처리
        if !UserDefaultsUtil.isEmpty(key: .deviceId) {
            ApiUtil.getId()
                .subscribe { event in
                    switch event {
                    case .success(let data):
                        SingleData.instance.deviceId = data
                        UserDefaultsUtil.setString(.deviceId, id: data)
                        self.mainDelegate?.checkInitData(.success)
                    case .error(let error):
                        debugPrint(error)
                        self.mainDelegate?.checkInitData(.fail)
                    }
                }
                .disposed(by: disposeBag)
            
        }
        else {
            SingleData.instance.deviceId = UserDefaultsUtil.getString(.deviceId)
        }
    }
    
//    func registerForRemoteNotifications() {
//        let app = UIApplication.shared
//        let center = UNUserNotificationCenter.current()
//        center.delegate = self
//        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
//            if let error = error {
//                debugPrint("\(String(describing: error.localizedDescription))")
//                return
//            }
//            center.getNotificationSettings(completionHandler: { settings in
//                if settings.authorizationStatus == .authorized {
//                    DispatchQueue.main.async(execute: {
//                        app.registerForRemoteNotifications()
//                    })
//                }
//            })
//        })
//    }
    
    
    func applicationWillResignActive(_ application: UIApplication) {
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        print("background 진입!!")
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//        CallManager.instance.registerSubsription(token: deviceToken, completion: { _ in})

    }
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return [.portrait]
    }
    
}

