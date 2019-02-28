//
//  VideoViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 11/02/2019.
//  Copyright © 2019 박진수. All rights reserved.
//

import UIKit
import Quickblox
import QuickbloxWebRTC
import RxCocoa
import RxSwift

protocol VideoCallDelegate {
    func didFailedNetwork()
}

class VideoViewController: UIViewController {
    @IBOutlet weak var remoteView: QBRTCRemoteVideoView!
    @IBOutlet weak var localView: UIView!
    @IBOutlet weak var cameraRotateBtn: UIButton!
    @IBOutlet weak var cameraOnOffBtn: UIButton!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    
    private var isCalled: Bool = true
    private var isCamera: Bool = true
    var cameraArray = [UIImage(named: "cameraOff"), UIImage(named: "cameraOn")]
    var cameraArrayIndex: Int = 0
    var delegate: VideoCallDelegate?
    
    private let callManager = CallManager.instance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
        
        let alert = UIAlertController(title: "saveVideo".localized, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: { [weak self]_ in
            guard let `self` = self else { return }
            if !self.callManager.isConnectedNetWork(to: .wifi) {
                let wifiAlert = UIAlertController(title: "saveWifi".localized, message: "setWifi".localized, preferredStyle: .alert)
                wifiAlert.addAction(UIAlertAction(title: "setting".localized, style: .default, handler: { _ in
                    if let url = URL(string:"App-Prefs:root=WIFI") {
                        if UIApplication.shared.canOpenURL(url) {
                            UIApplication.shared.open(url, options: [:], completionHandler: nil)
                        }
                    }
                }))
                wifiAlert.addAction(UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil))
                self.present(wifiAlert, animated: true, completion: nil)
            }
        }))
        present(alert, animated: true, completion: nil)
        
        indicator.hidesWhenStopped = true
        callManager.addDelegate(self)
        cameraRotateBtn.setImage(UIImage(named: "switchCamera"), for: .normal)
        cameraOnOffBtn.setImage(cameraArray[cameraArrayIndex], for: .normal)
        callManager.setLocalView(view: localView, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        print("viewWillDisappear!!")
        callManager.removeDelegate(self)
    }
    
    @IBAction func turnCamera(_ sender: Any) {
        cameraArrayIndex += 1
        if cameraArrayIndex > 1 {
            cameraArrayIndex = 0
        }
        cameraOnOffBtn.setImage(cameraArray[cameraArrayIndex], for: .normal)
        isCamera = !isCamera
        callManager.turnCamera(isCamera, completion: nil)
    }
    
    @IBAction func switchCamera(_ sender: Any) {
        callManager.switchCamera()
    }
}

extension VideoViewController: CallManagerDelegate {
    func receiveRemoteView(with videoTrack: QBRTCVideoTrack) {
        //        remoteView.videoGravity = AVLayerVideoGravity.resizeAspect.rawValue
        //        remoteView.clipsToBounds = true
        print("receiveRemoteView()!!")
        remoteView.setVideoTrack(videoTrack)
    }
    
    func callManager(_ callManager: CallManager, didEndFromUser userName: String) {
        let prescVC = AppStoryboard.presc.instance.instantiateViewController(withIdentifier: VC.prescVC.rawValue) as! PrescViewController
        self.navigationController?.pushViewController(prescVC, animated: true)
    }
    
    func callManager(_ callManager: CallManager, didFailFromUser userName: String) {
        self.navigationController?.popViewController(animated: true)
        delegate?.didFailedNetwork()
    }
    
    func callManager(_ callManager: CallManager, didConnectFromUser userName: String) {
        if self.indicator.isAnimating {
            self.indicator.stopAnimating()
        }
    }
    
    func disConnectedNetwork() {
        let alert = UIAlertController(title: nil, message: "networkDisconnect".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .destructive, handler: { [weak self] _ in
            self?.indicator.startAnimating()
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    
}




