//
//  ViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 25..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import RxSwift
import UICircularProgressRing
import RxCocoa
import PushKit
import CallKit
import Quickblox
import QuickbloxWebRTC


class MainViewController: UIViewController {
    
    @IBOutlet weak var diseaseCollectionView: UICollectionView!     // 질병리스트 collectionView
    @IBOutlet weak var reviewCollectionView: UICollectionView!      // 리뷰리스트 collectionView
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var progress: UICircularProgressRing!
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var reloadBtn: UIButton!
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var diseaseHeightConstraint: NSLayoutConstraint!
    
    private let diseaseDataSource: DiseaseDataSource = DiseaseDataSource()
    private let diseasePresenter: DiseasePresenter = DiseasePresenter()
    private let reviewDataSource: ReviewDataSource = ReviewDataSource()
    private let reviewPresenter: ReviewPresenter = ReviewPresenter()
    private let disposeBag = DisposeBag()
    private let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    private var isInit: Bool = true
    var disease: Disease = Disease("")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        appDelegate.mainDelegate = self
        CallManager.instance.addDelegate(self)
        
        diseaseCollectionView.dataSource = diseaseDataSource
        diseaseCollectionView.delegate = diseasePresenter
        diseaseCollectionView.translatesAutoresizingMaskIntoConstraints = false
        diseasePresenter.callback = self
        
        reviewCollectionView.dataSource = reviewDataSource
        reviewCollectionView.delegate = reviewPresenter
        
        if UserDefaultsUtil.isEmpty(key: .deviceId) {
            loadList()
        }
        
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: Image.logo.instance)
        navigationItem.titleView = imageView
        
        toolbar.barTintColor = UIColor.groupTableViewBackground
        
        progress.maxValue = 100
        progress.delegate = self
        
        reloadBtn.setBackgroundImage(UIImage(named: Image.reload.instance), for: .normal)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        if SingleData.instance.isLogin {
            loginBtn.setTitle("logout".localized, for: .normal)
        }
        else {
            loginBtn.setTitle("login".localized, for: .normal)
        }
    }
    
    @IBAction func reload(_ sender: Any) {
        if isInit {
            loadList()
        }
        else {
            appDelegate.getInitData()
        }
    }
    
    func loadList() {
        // MARK: 질병 리스트 GET
        diseaseDataSource.fill(callback: { code in
            self.handleView(code, callback: {
                self.diseaseCollectionView.reloadData()
                self.diseaseHeightConstraint.constant = self.diseaseCollectionView.collectionViewLayout.collectionViewContentSize.height
                self.view.layoutIfNeeded()
            })
        })
        
        // MARK: 리뷰 리스트 GET
        reviewDataSource.fill(callback: { code in
            self.handleView(code, callback: {
                self.reviewCollectionView.reloadData()
            })
        })
    }
    
    func handleView(_ state: State, callback: () -> ()) {
        switch state {
        case .success:
            if titleView.isHidden {
                titleView.isHidden = false
                diseaseCollectionView.isHidden = false
                reviewCollectionView.isHidden = false
            }
            reloadBtn.isEnabled = false
            reloadBtn.isHidden = true
            callback()
        case .fail:
            self.alertErrorMessage(.network)
            titleView.isHidden = true
            diseaseCollectionView.isHidden = true
            reviewCollectionView.isHidden = true
            self.reloadBtn.isEnabled = true
            self.reloadBtn.isHidden = false
        }
    }
    
    func alertErrorMessage(_ message: Message) {
        switch message {
        case .refund:
            let alert = UIAlertController(title: "refund".localized, message: message.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in SingleData.instance.isPay = false
                ApiUtil.setRefund(false)
                    .subscribe { event in
                        switch event {
                        case .completed:
                            break
                        case .error(let error):
                            debugPrint(error)
                            self.alertErrorMessage(.network)
                        }
                    }
                    .disposed(by: self.disposeBag)
            }))
            self.present(alert, animated: true, completion: nil)
        case .network:
            let alert = UIAlertController(title: "error".localized, message: message.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension MainViewController: ClickListener, initDelegate {
    /// 질병리스트 Click Event
    ///
    /// - Parameter index: 선택된 질병의 index
    func onClick(index: Int) {
        SingleData.instance.disease.title = self.diseaseDataSource.objects[index].title
        self.progress.isHidden = false
        progress.startProgress(to: 100, duration: 0.03)
        SingleData.instance.disease.getDisease(callback: { value in
            if let data = value {
                SingleData.instance.disease = data
                SingleData.instance.disease.colorIndex = index
                let guideVC = AppStoryboard.guide.instance
                    .instantiateViewController(withIdentifier: VC.guideVC.rawValue) as! GuideViewController
                self.didFinishProgress(for: self.progress)
                self.navigationController?.pushViewController(guideVC, animated: true)
            }
            else {
                self.alertErrorMessage(.network)
            }
        })
    }
    
    func checkInitData(_ state: State) {
        switch state {
        case .success:
            isInit = true
            loadList()
        case .fail:
            handleView(state, callback: {
                isInit = false
            })
        }
    }
}

// MARK: - ProgressBar관련 작업
extension MainViewController: UICircularProgressRingDelegate {
    func didUpdateProgressValue(for ring: UICircularProgressRing, to newValue: CGFloat) {
    }
    
    func didContinueProgress(for ring: UICircularProgressRing) {
        
    }
    
    func willDisplayLabel(for ring: UICircularProgressRing, _ label: UILabel) {
        
    }
    
    func didPauseProgress(for ring: UICircularProgressRing) {
        progress.value = 100
    }
    
    func didFinishProgress(for ring: UICircularProgressRing) {
        progress.value = 0
        self.progress.isHidden = true
    }
}


extension MainViewController: CallManagerDelegate, VideoCallDelegate {
    func didFailedNetwork() {
        let alert = UIAlertController(title: nil, message: "networkError".localized, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .destructive, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    func callManager(_ callManager: CallManager, didAcceptFromUser userName: String) {
        let videoVC = AppStoryboard.treat.instance.instantiateViewController(withIdentifier: VC.videoVC.rawValue) as! VideoViewController
        videoVC.delegate = self
        self.navigationController?.pushViewController(videoVC, animated: true)
    }
    
    func callManager(_ callManager: CallManager, didRejectToUser userName: String) {
        
    }
}
