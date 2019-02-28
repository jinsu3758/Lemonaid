//
//  ExamViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 13..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import WebKit

class ExamViewController: UIViewController {
    
    @IBOutlet weak var progressImage: UIImageView!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var progress: UIProgressView!
    
    var webView: WKWebView!
    var processPool: WKProcessPool?
    var isCookie: Bool = false
    let cookie = HTTPCookie(properties: [
        .path: Cookie.path.rawValue,
        .domain: Cookie.domain.rawValue,
        .name: Cookie.name.rawValue,
        .value: SingleData.instance.deviceId!,
        ])
    var state: Message = .examExit
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        navigationItem.title = SingleData.instance.disease.title + "exam".localized
        loadWebView(Path.question.instance)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = self.container.bounds
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == Key.estimateProgress.rawValue) {
            progress.progress = Float(webView.estimatedProgress)
            progress.isHidden = webView.estimatedProgress == 1
        }
    }
    
    deinit {
        webView.removeObserver(self, forKeyPath: Key.estimateProgress.rawValue)
    }
    
    func initWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = SingleData.instance.processPool
        
        // MARK: 비로그인 시 쿠키설정
        if #available(iOS 11.0, *) {} else {
            if !SingleData.instance.isLogin {
                let str = SingleData.instance.getJSCookiesString(for: [cookie!])
                let userContentController = WKUserContentController()
                let cookieScript = WKUserScript(source: str , injectionTime: .atDocumentStart, forMainFrameOnly: false)
                userContentController.addUserScript(cookieScript)
                webConfiguration.userContentController = userContentController
                isCookie = true
            }
        }
        
        guard let containerView = container else { return }
        webView = WKWebView(frame: containerView.bounds, configuration: webConfiguration)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        webView.scrollView.delegate = self
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.addObserver(self, forKeyPath: Key.estimateProgress.rawValue, options: .new, context: nil)
        container.addSubview(webView)
        
        let mainBtn = UIBarButtonItem(title: "backMain".localized, style: .plain, target: self, action: #selector(backBtnAction(sender:)))
        navigationItem.leftBarButtonItem = mainBtn
    }
    
    
    
    // MARK: URL에 쿼리문을 넣어 웹뷰에 로드해주는 함수
    func loadWebView(_ url: String) {
        if var url = URLComponents(string: url) {
            url.queryItems = [URLQueryItem(name: Key.diseaseName.rawValue, value: SingleData.instance.disease.title), URLQueryItem(name: Key.priority.rawValue, value: Key.priorityValue.rawValue)]
            guard let request = url.url else { return }
            webView.load(URLRequest(url: request))
        }
    }
    
    @objc func backBtnAction(sender: UIBarButtonItem) {
        alertMessage(state)
    }
    
    func alertMessage(_ message: Message) {
        switch message {
        case .network:
            let alert = UIAlertController(title: "error".localized, message: message.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        case .examExit, .signExit, .orderExit, .payExit:
            let alert = UIAlertController(title: message.instance, message: nil, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "backMain".localized, style: .destructive, handler: { _ in self.navigationController?.popToRootViewController(animated: true)
                let mainVC = AppStoryboard.main.instance.instantiateViewController(withIdentifier: VC.mainVC.rawValue) as! MainViewController
                self.navigationController?.pushViewController(mainVC, animated: true)
            }))
            present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
}

extension ExamViewController: WKNavigationDelegate, WKUIDelegate, UIScrollViewDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // MARK: 비로그인 시 쿠키설정
        if !SingleData.instance.isLogin && !isCookie {
            if #available(iOS 11.0, *) {
                guard let cookie = cookie else { return }
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(cookie, completionHandler: nil)
            }
            isCookie = true
        }
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        alertMessage(.network)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse
        , decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        // MARK: 웹뷰 response에서 header값을 파싱하여 이벤트 처리
        if let response = navigationResponse.response as? HTTPURLResponse {
            let headers = response.allHeaderFields
            if let deviceId = headers[Key.loginDeviceId.rawValue] as? String {
                SingleData.instance.deviceId = deviceId
                UserDefaultsUtil.setString(.deviceId, id: deviceId)
            }
            guard let location = headers[Key.location.rawValue] as? String else {
                decisionHandler(.allow)
                return
            }
            switch location
            {
            case Flow.cash.rawValue:
                self.navigationItem.title = "pay".localized
                self.state = .payExit
            case Flow.order.rawValue:
                self.navigationItem.title = "order".localized
                self.state = .orderExit
                progressImage.image = UIImage(named: Image.progressPay.instance)
            case Flow.login.rawValue:
                self.navigationItem.title = "login".localized
                self.state = .signExit
            case Flow.signIn.rawValue:
                self.navigationItem.title = "signIn".localized
            case Flow.fail.rawValue:
                navigationController?.popToRootViewController(animated: true)
                let mainVC = AppStoryboard.main.instance.instantiateViewController(withIdentifier: VC.mainVC.rawValue) as! MainViewController
                navigationController?.pushViewController(mainVC, animated: true)
            // MARK: 웹뷰 완료
            case Flow.end.rawValue:
                SingleData.instance.isLogin = true
                let mikeVC = AppStoryboard.treat.instance.instantiateViewController(withIdentifier: VC.mikeTestVC.rawValue) as! MikeTestViewController
                self.navigationController?.pushViewController(mikeVC, animated: true)
            default:
                break
            }
        }
        else {
            self.alertMessage(.network)
        }
        
        decisionHandler(.allow)
        
        //        if let response = navigationResponse.response as? HTTPURLResponse,
        //           let headers = response.allHeaderFields as? [String : String],
        //           let responseUrl = response.url {
        //            print("쿠키받자!!!!")
        //             decisionHandler(.allow)
        //            let cookies = HTTPCookie.cookies(withResponseHeaderFields: headers, for: responseUrl)
        //
        //            for cookie in cookies {
        //                print("\(cookie.name)!!!")
        //                switch cookie.value
        //                {
        //                case Flow.cash.rawValue:
        //                    self.navigationItem.title = "pay".localized
        //                case Flow.order.rawValue:
        //                    self.navigationItem.title = "order".localized
        //                    progressImage.image = UIImage(named: Image.progressPay.instance)
        //                case Flow.login.rawValue:
        //                    self.navigationItem.title = "login".localized
        //                case Flow.signIn.rawValue:
        //                    self.navigationItem.title = "signIn".localized
        //                // MARK: 웹뷰 완료
        //                case Flow.end.rawValue:
        //                    SingleData.instance.isLogin = true
        //                    let mikeVC = AppStoryboard.treat.instance.instantiateViewController(withIdentifier: VC.mikeTestVC.rawValue) as! MikeTestViewController
        //                    self.navigationController?.pushViewController(mikeVC, animated: true)
        //                default:
        //                    break
        //                }
        //            }
        //        }
        //        else {
        //            let alert = UIAlertController(title: "error".localized, message: ErrorMessage.network.rawValue, preferredStyle: .alert)
        //            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
        //                _ in self.navigationController?.popViewController(animated: true)
        //            }))
        //            present(alert, animated: true, completion: nil)
        //        }
        
    }
    
    
    // MARK: 웹뷰 Alert 창 처리
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: message, message: nil, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "ok".localized, style: .cancel, handler: {
            _ in completionHandler()
        })
        alert.addAction(cancelAction)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    
    // MARK: 가로 스크롤 제어
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (scrollView.contentOffset.x > 0){
            scrollView.contentOffset = CGPoint(x: 0, y: scrollView.contentOffset.y)
        }
    }
    
    
}


