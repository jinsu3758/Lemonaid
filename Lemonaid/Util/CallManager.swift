//
//  CallManager.swift
//  Lemonaid
//
//  Created by 박진수 on 13/02/2019.
//  Copyright © 2019 박진수. All rights reserved.
//

import Foundation
import QuickbloxWebRTC
import Quickblox
import CallKit
import PushKit
import UserNotifications
import SystemConfiguration

typealias CompletionBlock = (() -> Void)

enum CallResponse {
    case success
    case error(Error?)
}

enum Network {
    case wifi
    case all
}

open class CallManager: NSObject, UNUserNotificationCenterDelegate {
    static let instance = CallManager()
    
    private var callController: CXCallController?
    private var session: QBRTCSession?
    private var provider: CXProvider?
    private var opponentName: String = ""
    private var isCalled: Bool = false
    private var user: QBUUser = QBUUser()
    private var cameraCapture: QBRTCCameraCapture?
    private var uuid = UUID()
    private var delegateArray: [CallManagerDelegate] = []
    
    private let registry = PKPushRegistry(queue: DispatchQueue.main)
    
    lazy var backgroundTask: UIBackgroundTaskIdentifier = {     // A unique token that identifies a request to run in the background
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        // A token indicating an invalid task request. This constant should be used to initialize variables or to check for errors.
        return backgroundTask
    }()
    
    override init() {
        super.init()
//        QBSettings.applicationID = 75837
//        QBSettings.authKey = "RudkTdNRUL3q6b6"
//        QBSettings.authSecret = "FMuxCzGC6jasZDG"
//        QBSettings.accountKey = "hJDEWM3rW4Za3CiMEsrC"
//        QBSettings.autoReconnectEnabled = true
        
        QBRTCClient.initializeRTC()
        let config = CXProviderConfiguration(localizedName: "처방해줌")
        config.iconTemplateImageData = UIImage(named: "AppIcon")?.pngData()
        self.provider = CXProvider(configuration: config)
        if let provider = self.provider {
            provider.setDelegate(self, queue: nil)
        }
        registry.delegate = self
        registry.desiredPushTypes = [.voIP]
        callController = CXCallController(queue: DispatchQueue.main)
        cameraCapture = QBRTCCameraCapture.init(videoFormat: QBRTCVideoFormat.default(), position: .front)
        QBRTCClient.instance().add(self)
    }
    
    func setCall(id: UInt, authKey: String, authSecret: String, accountKey: String) {
        QBSettings.applicationID = id
        QBSettings.authKey = authKey
        QBSettings.authSecret = authSecret
        QBSettings.accountKey = accountKey
        QBSettings.autoReconnectEnabled = true
    }
    
    /// 유저 로그인 시도
    /// 이미 로그인 시, connect만 시도
    ///
    /// - Parameter completion: .success: 로그인(or connect) 성공, .error: 로그인(or connect) 실패
    func onLogin(completion: ((CallResponse) -> Void)?) {
        user.login = "love"
        user.password = "jinsu3758"
        guard let login = self.user.login, let pwd = self.user.password else {
            completion?(.error(MadeError.invalidData))
            return
        }
        let connectChat: () -> () = {
            QBChat.instance.connect(withUserID: self.user.id, password: pwd, completion: { error in
                if let error = error {
                    completion?(.error(error))
                }
                else {
                    print("connect 성공!!")
                    completion?(.success)
                }
            })
        }
        
        if let currentUser = QBSession.current.currentUser {
            self.user = currentUser
            connectChat()
        }
        else {
            QBRequest.logIn(withUserLogin: login, password: pwd, successBlock: { r, currentUser in
                self.user = currentUser
                connectChat()
            }, errorBlock: { response in
                completion?(.error(response.error?.error))
            })
        }
    }
    
    func onLogin(id: String, name: String, pwd: String, completion: ((CallResponse) -> Void)?) {
        user.login = id
        user.fullName = name
        user.password = pwd
        guard let login = self.user.login, let pwd = self.user.password else {
            completion?(.error(MadeError.invalidData))
            return
        }
        let connectChat: () -> () = {
            QBChat.instance.connect(withUserID: self.user.id, password: pwd, completion: { error in
                if let error = error {
                    completion?(.error(error))
                }
                else {
                    print("connect 성공!!")
                    completion?(.success)
                }
            })
        }
        
        if let currentUser = QBSession.current.currentUser {
            self.user = currentUser
            connectChat()
        }
        else {
            QBRequest.logIn(withUserLogin: login, password: pwd, successBlock: { r, currentUser in
                self.user = currentUser
                connectChat()
            }, errorBlock: { response in
                completion?(.error(response.error?.error))
            })
        }
    }
    
    func signUp(id: String, name: String, pwd: String, completion: @escaping (CallResponse) -> Void) {
        user.login = id     // "love"
        user.fullName = name    // "jinsu"
        user.password = pwd     // "jjinsu4000"
        user.tags = ["testroom"]
        
        QBRequest.signUp(user, successBlock: { _, currentUser in
            completion(.success)
        }, errorBlock: { response in
            completion(.error(response.error?.error))
            
        })
    }
    
    func signUp(id: String, name: String, pwd: String, tagName: String, completion: @escaping (CallResponse) -> Void) {
        user.login = id     // "love"
        user.fullName = name    // "jinsu"
        user.password = pwd     // "jjinsu4000"
        user.tags = [tagName]
        
        QBRequest.signUp(user, successBlock: { _, currentUser in
            completion(.success)
        }, errorBlock: { response in
            completion(.error(response.error?.error))
            
        })
    }
    
    func logOut(completion: ((CallResponse) -> Void)?) {
        QBRequest.logOut(successBlock: { _ in completion?(.success)}, errorBlock: { _ in completion?(.error(MadeError.invalidData))})
    }
    
    
    /// APNS, VOIP subscription 등록
    ///
    /// - Parameters:
    ///   - token: deviceToken
    // 아마 uuid 파라미터로 받아야 할지도...
    func registerSubsription(token: Data, completion: @escaping (CallResponse) -> Void ) {
        let APNSsubscription = QBMSubscription()
        APNSsubscription.notificationChannel = QBMNotificationChannel.APNS
        APNSsubscription.deviceUDID = UIDevice.current.identifierForVendor?.uuidString
        APNSsubscription.deviceToken = token
        
        let VOIPsubscription = QBMSubscription()
        VOIPsubscription.notificationChannel = QBMNotificationChannel.APNSVOIP
        VOIPsubscription.deviceUDID = UIDevice.current.identifierForVendor?.uuidString
        VOIPsubscription.deviceToken = token
        
        QBRequest.createSubscription(APNSsubscription, successBlock: { response, objects in
            QBRequest.createSubscription(VOIPsubscription, successBlock: { respons, objects in
                completion(.success)
                print("subscription 성공!!")
            }, errorBlock: { response in
                completion(.error(response.error?.error))
            })
        }, errorBlock: { response in
            debugPrint("response error!: \(String(describing: response.error))")
            completion(.error(response.error?.error))
        })
    }
    
    /// subscription 해제
    ///
    /// - Parameters:
    ///   - devideIdentifier: device uuid
    func releaseSubscription(from devideIdentifier: String, completion: @escaping (CallResponse) -> Void) {
        QBRequest.unregisterSubscription(forUniqueDeviceIdentifier: devideIdentifier, successBlock: { response in
            completion(.success)
        }, errorBlock: { error in
            completion(.error(error.error))
        })
    }
    
    /// 영상통화 시 localView 등록
    ///
    /// - Parameters:
    ///   - localView: localView로 사용할 View
    func setLocalView(view localView: UIView, completion: (() -> ())?) {
        self.cameraCapture?.previewLayer.videoGravity = .resize
        self.cameraCapture?.previewLayer.frame = localView.bounds
        self.cameraCapture?.startSession(nil)
        localView.layer.insertSublayer((cameraCapture?.previewLayer)!, at: 0)
        self.session?.localMediaStream.videoTrack.videoCapture = cameraCapture
        completion?()
    }
    
    func switchCamera() {
        self.cameraCapture?.position = self.cameraCapture?.position == .back ? .front : .back
    }
    
    func registerForRemoteNotification() {
        let app = UIApplication.shared
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.sound, .alert, .badge], completionHandler: { granted, error in
            if let error = error {
                debugPrint("\(String(describing: error.localizedDescription))")
                return
            }
            center.getNotificationSettings(completionHandler: { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async(execute: {
                        app.registerForRemoteNotifications()
                    })
                }
            })
        })
    }
    
    /// 카메라 On/Off
    ///
    /// - Parameters:
    ///   - bool: true - on / false - off
    func turnCamera(_ bool: Bool, completion: (() -> ())?) {
        self.session?.localMediaStream.videoTrack.isEnabled = bool
        self.cameraCapture?.previewLayer.isHidden = !bool
        completion?()
    }
    
    func hangUpCall() {
        guard let session = self.session else { return }
        session.hangUp(nil)
    }
    
    func acceptCall() {
        guard let session = self.session else { return }
        session.acceptCall(nil)
    }
    
    func rejectCall() {
        guard let session = self.session else { return }
        session.rejectCall(nil)
    }
    
    /// 와이파이 status 확인
    ///
    /// - Parameter network: .wifi - 와이파이만 연결 / .all - 둘 다 연결
    func isConnectedNetWork(to network: Network) -> Bool {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
            }
        }
        
        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
            return false
        }
        var isReachable: Bool = true
        var needsConnection: Bool = true
        switch network {
        // Only Working for WIFI
        case .wifi:
            isReachable = flags == .reachable
            needsConnection = flags == .connectionRequired
        case .all:
            isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
            needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        }
        return isReachable && !needsConnection
        
    }
    
    func addDelegate(_ delegate: CallManagerDelegate) {
        self.delegateArray.append(delegate)
    }
    
    func removeDelegate(_ delegate: CallManagerDelegate) {
        for (index, data) in delegateArray.enumerated().reversed() {
            if data === delegate {
                delegateArray.remove(at: index)
            }
        }
    }
    
}

extension CallManager: CXProviderDelegate {
    open func providerDidReset(_ provider: CXProvider) {}
    
    open func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
        guard let session = self.session else {
            action.fulfill(withDateEnded: Date())
            return
        }
        self.session = nil
        let audioSession = QBRTCAudioSession.instance()
        audioSession.isAudioEnabled = false
        audioSession.useManualAudio = false
        if self.isCalled {
            session.hangUp(nil)
            self.isCalled = false
        }
        else {
            session.rejectCall(nil)
            for delegate in self.delegateArray {
                delegate.callManager?(self, didRejectToUser: opponentName)
            }
        }
        action.fulfill(withDateEnded: Date())
    }
    
    open func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
        guard let session = self.session else {
            action.fail()
            return
        }
        self.isCalled = true
        session.acceptCall(nil)
        for delegate in self.delegateArray {
            delegate.callManager?(self, didAcceptFromUser: opponentName)
        }
        action.fulfill()
    }
    
    open func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
        guard let session = self.session else {
            return
        }
        let rtcAudioSession = QBRTCAudioSession.instance()
        rtcAudioSession.audioSessionDidActivate(audioSession)
        // enabling audio now
        rtcAudioSession.isAudioEnabled = true
        // enabling local mic recording in recorder (if recorder is active) as of interruptions are over now
        session.recorder?.isLocalAudioEnabled = true
    }
    
    open func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
        QBRTCAudioSession.instance().audioSessionDidDeactivate(audioSession)
        // deinitializing audio session after iOS deactivated it for us
        let session = QBRTCAudioSession.instance()
        if session.isInitialized {
            session.deinitialize()
        }
    }
}

extension CallManager: QBRTCClientDelegate {
    open func didReceiveNewSession(_ session: QBRTCSession, userInfo: [String : String]? = nil) {
        print("didReceiveNewSession()!!")
        if self.session != nil {
            self.session?.rejectCall(nil)
            return
        }
        
        self.session = session
        if let userName = userInfo?["name"] {
            for delegate in self.delegateArray {
                delegate.callManager?(self, didReceiveFromUser: userName)
            }
            uuid = UUID()
            self.opponentName = userName
            let update = CXCallUpdate()
            update.remoteHandle = CXHandle(type: .generic, value: userName)
            
            let audioSession = QBRTCAudioSession.instance()
            audioSession.useManualAudio = true
            self.session?.recorder?.isLocalAudioEnabled = false
            
            if audioSession.isInitialized == false {
                audioSession.initialize() { configuration in
                    configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowBluetooth)
                    configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowBluetoothA2DP)
                    configuration.categoryOptions.insert(AVAudioSession.CategoryOptions.allowAirPlay)
                    
                    if self.session?.conferenceType == QBRTCConferenceType.video {
                        configuration.mode = AVAudioSession.Mode.videoChat.rawValue
                    }
                }
            }
            
            self.provider?.reportNewIncomingCall(with: uuid, update: update, completion: {_ in})
        }
    }
    
    open func session(_ session: QBRTCBaseSession, receivedRemoteVideoTrack videoTrack: QBRTCVideoTrack, fromUser userID: NSNumber) {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5, execute: {
            for delegate in self.delegateArray {
                delegate.receiveRemoteView?(with: videoTrack)
            }
        })
        
    }
    
    open func session(_ session: QBRTCBaseSession, startedConnectingToUser userID: NSNumber) {
        print("session is started!!")
    }
    
    open func session(_ session: QBRTCBaseSession, didChange state: QBRTCSessionState) {
    }
    
    open func session(_ session: QBRTCBaseSession, connectedToUser userID: NSNumber) {
        print("session is established!!")
        for delegate in self.delegateArray {
            delegate.callManager?(self, didConnectFromUser: opponentName)
        }
    }
    
    open func session(_ session: QBRTCBaseSession, disconnectedFromUser userID: NSNumber) {
        print("session Disconnected!!")
        if !isConnectedNetWork(to: .all) {
            for delegate in self.delegateArray {
                delegate.disConnectedNetwork?()
            }
        }
    }
    
    open func session(_ session: QBRTCBaseSession, connectionFailedForUser userID: NSNumber) {
        print("session Failed!!")
        if isCalled {
            QBRTCAudioSession.instance().isAudioEnabled = false
            QBRTCAudioSession.instance().useManualAudio = false
            QBRTCAudioSession.instance().deinitialize()
            cameraCapture?.stopSession(nil)
            for delegate in self.delegateArray {
                delegate.callManager?(self, didFailFromUser: opponentName)
            }
            let action = CXEndCallAction(call: uuid)
            let transaction = CXTransaction(action: action)
            DispatchQueue.main.async {
                self.callController?.request(transaction, completion: {_ in})
            }
            self.session?.hangUp(nil)
            self.session = nil
            self.isCalled = false
        }
    }
    
    open func session(_ session: QBRTCSession, hungUpByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("hung uped!!!")
    }
    
    open func session(_ session: QBRTCSession, rejectedByUser userID: NSNumber, userInfo: [String : String]? = nil) {
        print("rejected!!")
    }
    
    open func session(_ session: QBRTCSession, userDidNotRespond userID: NSNumber) {
        print("didnotRespond!!")
    }
    
    open func sessionDidClose(_ session: QBRTCSession) {
        print("session disclosed!")
        if self.session == session {
            if backgroundTask != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTask)
                backgroundTask = UIBackgroundTaskIdentifier.invalid
            }
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(1.0 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
                if UIApplication.shared.applicationState == .background && self.backgroundTask == .invalid {
                    // dispatching chat disconnect in 1 second so message about call end
                    // from webrtc does not cut mid sending
                    // checking for background task being invalid though, to avoid disconnecting
                    // from chat when another call has already being received in background
                    QBChat.instance.disconnect(completionBlock: nil)
                }
            })
            if isCalled {
                for delegate in self.delegateArray {
                    delegate.callManager?(self, didEndFromUser: opponentName)
                }
                QBRTCAudioSession.instance().isAudioEnabled = false
                QBRTCAudioSession.instance().useManualAudio = false
                QBRTCAudioSession.instance().deinitialize()
                cameraCapture?.stopSession(nil)
                self.isCalled = false
            }
            let action = CXEndCallAction(call: uuid)
            let transaction = CXTransaction(action: action)
            DispatchQueue.main.async {
                self.callController?.request(transaction, completion: {_ in})
            }
            
            self.session = nil
        }
    }
    
}

extension CallManager: PKPushRegistryDelegate {
    
    open func pushRegistry(_ registry: PKPushRegistry, didUpdate pushCredentials: PKPushCredentials, for type: PKPushType) {
        // 1회성으로 수정
        if let deviceToken = self.registry.pushToken(for: .voIP) {
            self.registerSubsription(token: deviceToken, completion: { _ in})
        }
    }
    
    open func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
        print("push 옴!!")
        let application = UIApplication.shared
        if application.applicationState == .background && backgroundTask == .invalid{
            // Marks the beginning of a new long-running background task.
            // background에서 suspended 상태로 넘어가는 시간을 지연시켜줌
            // return값은 background 작업에 부여된 id
            backgroundTask = application.beginBackgroundTask(expirationHandler: {
                application.endBackgroundTask(self.backgroundTask)  // background 작업이 종료되었음을 알림
                self.backgroundTask = UIBackgroundTaskIdentifier.invalid
            })
        }
        if QBChat.instance.isConnected == false {
            self.onLogin(completion: nil)
        }
        
    }
    
    open func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
        guard let deviceIdentifier = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        self.releaseSubscription(from: deviceIdentifier, completion: { _ in })
    }
}




