//
//  LoginViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 14..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import WebKit
import RxSwift
import Alamofire

class LoginViewController: UIViewController {
    
    @IBOutlet weak var container: UIView!
    private let disposeBag = DisposeBag()
    
    var webView: WKWebView!
    var isCookie: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initWebView()
        navigationItem.title = "login".localized
        
        // MARK: 로그아웃 시
        if SingleData.instance.isLogin {
            ApiUtil.getId()
                .subscribe { event in
                    switch event {
                    case .success(let data):
                        print("디바이스 id 다시 받기 : \(data)!!!")
                        SingleData.instance.isLogin = false
                        SingleData.instance.deviceId = data
                        UserDefaultsUtil.setString(.deviceId, id: data)
                        self.loadWebView(Path.logout.instance)
                    case .error(let error):
                        debugPrint(error)
                        let alert = UIAlertController(title: "error".localized, message: Message.network.instance, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                            _ in self.navigationController?.popViewController(animated: true)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
                .disposed(by: disposeBag)
        }
        else {
            loadWebView(Path.login.instance)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        webView.frame = self.container.bounds
    }
    
    func initWebView() {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.processPool = SingleData.instance.processPool
        
        // MARK: 비로그인 시 쿠키설정
        if #available(iOS 11.0, *) {} else {
            if !SingleData.instance.isLogin && !isCookie {
                let cookie = HTTPCookie(properties: [
                    .path: Cookie.path.rawValue,
                    .domain: Cookie.domain.rawValue,
                    .name: Cookie.name.rawValue,
                    .value: SingleData.instance.deviceId!,
                    ])
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
        container.addSubview(webView)
        
        let backBtn = UIBarButtonItem(image: UIImage(named: Image.back.instance), style: .plain, target: self, action: #selector(backBtnAction(sender:)))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationItem.hidesBackButton = true
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    func loadWebView(_ url: String) {
        if let request_url = URL(string: url) {
            let request = URLRequest(url: request_url)
            webView.load(request)
        }
        else {
            let alert = UIAlertController(title: "error".localized, message: Message.request.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        }
    }
    
    @objc func backBtnAction(sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }
}

extension LoginViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let alert = UIAlertController(title: "error".localized, message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
            _ in self.navigationController?.popViewController(animated: true)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        // MARK: 비로그인 시 쿠키설정
        if !SingleData.instance.isLogin && !isCookie {
            if #available(iOS 11.0, *) {
                let cookie = HTTPCookie(properties: [
                    .path: Cookie.path.rawValue,
                    .domain: Cookie.domain.rawValue,
                    .name: Cookie.name.rawValue,
                    .value: SingleData.instance.deviceId!,
                    ])
                guard let mCookie = cookie else { return }
                webView.configuration.websiteDataStore.httpCookieStore.setCookie(mCookie, completionHandler: nil)
            }
            isCookie = true
        }
    }
    
    // MARK: Header 추출 후, 이벤트 처리
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        if let response = navigationResponse.response as? HTTPURLResponse {
            let headers = response.allHeaderFields
            // MARK: 회원가입 이동 시
            if let location = headers[Key.location.rawValue] as? String, location == Flow.signIn.rawValue {
                self.navigationItem.title = "signIn".localized
            }
            // MARK: 로그인 완료 시
            if let isLogin = headers[Key.isLogin.rawValue] as? String, isLogin == Flow.onLogin.rawValue {
                SingleData.instance.isLogin = true
                navigationController?.popViewController(animated: true)
            }
            if let deviceId = headers[Key.loginDeviceId.rawValue] as? String {
                print("로그인 시 디바이사 ㅡid받음 : \(deviceId)!!")
                SingleData.instance.deviceId = deviceId
                UserDefaultsUtil.setString(.deviceId, id: deviceId)
            }
        }
        decisionHandler(.allow)
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
}
