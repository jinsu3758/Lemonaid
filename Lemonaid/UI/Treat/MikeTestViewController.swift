//
//  MikeTestViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 16..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import UICircularProgressRing
import Speech
import Kingfisher
import RxSwift

//@available(iOS 10.0, *)
class MikeTestViewController: UIViewController, SFSpeechRecognizerDelegate {
    
    @IBOutlet weak var mikeGuideLabel: UILabel!
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var mikeAccessLabel: UILabel!
    @IBOutlet weak var mikeOffImg: UIImageView!
    @IBOutlet weak var mikeOnImg: UIImageView!
    @IBOutlet weak var mikeCenterYConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var testStartBtn: UIButton!
    @IBOutlet weak var responseView: UIView!
    @IBOutlet weak var progressLabel: UILabel!
    
    @IBOutlet weak var testGuideLabel: UILabel!
    @IBOutlet weak var testContentLabel: UILabel!
    @IBOutlet weak var testCheckImg: UIImageView!
    
    @IBOutlet weak var progressBar: UICircularProgressRing!
    @IBOutlet weak var reloadBtn: UIButton!
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "ko-KR"))
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    private let audioSession = AVAudioSession.sharedInstance()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(checkAuthor), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        mikeGuideLabel.text = "mikeGuide".localized
        navigationItem.title = "mikeTest".localized
        responseView.layer.borderColor = UIColor.backColor.cgColor
        responseView.layer.borderWidth = 1.0
        responseView.layer.cornerRadius = 5
        responseView.layer.masksToBounds = true
        
        progressBar.maxValue = 100
        progressBar.delegate = self
        
        speechRecognizer?.delegate = self
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        
        SingleData.instance.isPay = true
//        ApiUtil.setRefund(true)
//            .subscribe { event in
//                switch event {
//                case .completed:
//                    print("refund 하고 끄끼!!")
//                    break
//                case .error(let error):
//                    print("refund 체크 실패!!")
//                    debugPrint(error)
//                }
//            }
//            .disposed(by: disposeBag)
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        checkAuthor()
    }
    
    //MARK : 마이크 권한 체크
    @objc func checkAuthor() {
        SFSpeechRecognizer.requestAuthorization { status in
            OperationQueue.main.addOperation {
                switch status {
                case .authorized:
                    break
                case .notDetermined:
                    self.checkAuthor()
                case .restricted, .denied:
                    self.alertErrorMessage(.voiceAuthor)
                }
            }
        }
        switch audioSession.recordPermission {
        case .denied:
            self.alertErrorMessage(.mikeAuthor)
        case .undetermined:
            audioSession.requestRecordPermission { _ in}
        case .granted:
            break
            
        }
    }
    
    // MARK: 테스트 시작 버튼 Event
    @IBAction func startTest(_ sender: Any) {
        mikeGuideLabel.isHidden =  true
        mikeAccessLabel.isHidden = true
        mikeCenterYConstraint.isActive = false
        testStartBtn.isHidden = true
        testGuideLabel.isHidden = false
        testContentLabel.isHidden = false
        responseView.isHidden = false
        
        view.layoutIfNeeded()
        view.setNeedsUpdateConstraints()
        
        progressBar.isHidden = false
        startRecord()
        progressBar.startProgress(to: 100, duration: 10.0)
    }
    
    // MARK: 마이크 테스트 시작 함수
    func startRecord() {
        if (recognitionTask != nil) {
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let inputNode = audioEngine.inputNode
        let recordFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        guard let recognitionRequest = recognitionRequest else { return }
        recognitionRequest.shouldReportPartialResults = true
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        }
        catch {
            self.alertErrorMessage(.mike)
        }
        
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        }
        catch {
           self.alertErrorMessage(.mike)
        }
        var isFinal = false
        
        //        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, delegate: self)
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in
            if result != nil {
                isFinal = (result?.isFinal)!
                if result?.bestTranscription.formattedString.range(of: "mikeTest".localized) != nil {
                    self.testCheckImg.image = UIImage(named: Image.checkOrange.rawValue)
                    self.mikeOffImg.image = UIImage(named: Image.mikeOn.rawValue)
                    self.didFinishProgress(for: self.progressBar)
                    self.audioEngine.stop()
                    self.recognitionRequest?.endAudio()
                    self.recognitionRequest = nil
                    self.recognitionTask?.cancel()
                    self.recognitionTask = nil
                    self.progressBar.isHidden = true
                    self.progressLabel.isHidden = false
                    self.progressLabel.text = "mikeTest".localized
                    self.reloadBtn.isHidden = true
                    self.testCheckImg.isHidden = false
                    
                    let callVC = AppStoryboard.treat.instance.instantiateViewController(withIdentifier: VC.callVC.rawValue) as! CallViewController
                    self.navigationController?.pushViewController(callVC, animated: true)
                }
            }
            if error != nil || isFinal {
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
            }
            
        })
    }
    
    func alertErrorMessage(_ key: Message) {
        switch key {
        case .mike:
            let alert = UIAlertController(title: "error".localized, message: key.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in self.navigationController?.popViewController(animated: true)
            }))
            self.present(alert, animated: true, completion: nil)
        case .voiceAuthor:
            let alert = UIAlertController(title: "error".localized, message: key.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, completionHandler: nil)
                    }
                    else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        case .mikeAuthor:
            let alert = UIAlertController(title: "error".localized, message: key.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, completionHandler: nil)
                    }
                    else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }

    // MARK: 재시도 버튼 Event
    @IBAction func reLoadTest(_ sender: Any) {
        do {
            audioEngine.reset()
            try audioEngine.start()
            progressBar.isHidden = false
            progressLabel.isHidden = true
            progressBar.startProgress(to:100, duration: 10.0)
            reloadBtn.isHidden = false
        }
        catch {
            return print(error)
        }
    }
    
}


//@available(iOS 10.0, *)
extension MikeTestViewController: UICircularProgressRingDelegate {
    func didPauseProgress(for ring: UICircularProgressRing) {
        
    }
    
    func didContinueProgress(for ring: UICircularProgressRing) {
        
    }
    
    func didUpdateProgressValue(for ring: UICircularProgressRing, to newValue: CGFloat) {
        
    }
    
    func willDisplayLabel(for ring: UICircularProgressRing, _ label: UILabel) {
        
    }
    
    func didFinishProgress(for ring: UICircularProgressRing) {
        self.audioEngine.stop()
        progressBar.value = 0
        progressBar.isHidden = true
        progressLabel.isHidden = false
        progressLabel.text = "mikeFail".localized
        progressBar.isHidden = true
        reloadBtn.isHidden = false
        testCheckImg.image = UIImage(named: Image.failOrange.rawValue)
        testCheckImg.isHidden = false
        
    }
}

