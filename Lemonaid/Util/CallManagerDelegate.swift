//
//  CallManagerDelegate.swift
//  Lemonaid
//
//  Created by 박진수 on 20/02/2019.
//  Copyright © 2019 박진수. All rights reserved.
//

import Foundation
import QuickbloxWebRTC
import Quickblox

@objc protocol CallManagerDelegate: class {
    @objc optional func callManager(_ callManager: CallManager, didAcceptFromUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didEndFromUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didConnectFromUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didReceiveFromUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didFailFromUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didDisconnectFromUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didRejectToUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didHangUpByUser userName: String)
    
    @objc optional func callManager(_ callManager: CallManager, didRejectByUser userName: String)
    
    @objc optional func disConnectedNetwork()
    
    @objc optional func receiveRemoteView(with videoTrack: QBRTCVideoTrack)
}
