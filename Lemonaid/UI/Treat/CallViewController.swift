//
//  CallViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 19..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import CallKit
import Quickblox
import QuickbloxWebRTC
import CallKit
import PushKit
import UserNotifications


class CallViewController: UIViewController, CXCallObserverDelegate {
    
    @IBOutlet weak var callRequestLabel: UILabel!
    @IBOutlet weak var callImg: UIImageView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    var isCall: Bool = false
    var isCalled: Bool = false
    var session: QBRTCSession?
    
    private var onAcceptActionBlock: CompletionBlock?
    private var nav: UINavigationController?
    private var callController: CXCallController?
    var registry: PKPushRegistry?
    
    let callUpdate = CXCallUpdate()
    let callObserver = CXCallObserver()
    
    lazy private var backgroundTask: UIBackgroundTaskIdentifier = {     // A unique token that identifies a request to run in the background
        let backgroundTask = UIBackgroundTaskIdentifier.invalid
        // A token indicating an invalid task request. This constant should be used to initialize variables or to check for errors.
        return backgroundTask
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "videoCall".localized
//        callRequestLabel.text = "callRequest".localized
        callRequestLabel.text = "전화 대기 중..."
        self.navigationItem.hidesBackButton = true
        indicator.hidesWhenStopped = true
        callController = CXCallController(queue: DispatchQueue.main)

        
        //        callObserver.setDelegate(self, queue: nil)
        //        NotificationCenter.default.addObserver(self, selector: #selector(detect), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    // MARK: applicationActive 감지 함수
    @objc func detect() {
        if isCalled && isCall{
            isCalled = false
            let prescVC = AppStoryboard.presc.instance.instantiateViewController(withIdentifier: VC.prescVC.rawValue) as! PrescViewController
            self.navigationController?.pushViewController(prescVC, animated: true)
        }
    }
    
    @IBAction func onCall(_ sender: Any) {
        if let facetimeURL:URL = URL(string: "facetime://010-9340-7393") {
            let application:UIApplication = UIApplication.shared
            if (application.canOpenURL(facetimeURL)) {
                application.open(facetimeURL, completionHandler: { bool in
                    if bool {
                        print("성공!!")
                        self.isCall = true
                    }
                    else {
                        self.isCall = false
                        print("실패!!")
                    }
                })
            }
        }
    }
    
    // MARK: 전화 겄을 경우 감지
    func callObserver(_ callObserver: CXCallObserver, callChanged call: CXCall) {
        isCalled = true
    }
}

