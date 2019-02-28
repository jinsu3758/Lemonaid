//
//  GuideViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 30..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

protocol ContainerDelegate {
    func alterContainer(_ key: Int)
}

class GuideViewController: UIViewController {
    
    var backBtn: UIBarButtonItem?
    
    @IBOutlet weak var guideContainer: UIView!
    @IBOutlet weak var mainContainer: UIView!
    @IBOutlet weak var defineContainer: UIView!
    @IBOutlet weak var treatContainer: UIView!
    @IBOutlet weak var exceptContainer: UIView!
    @IBOutlet weak var loginBtn: UIButton!
    
    var container: MainGuideContainer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = SingleData.instance.disease.title
        backBtn = UIBarButtonItem(image: UIImage(named: Image.back.instance), style: .plain, target: self, action: #selector(backBtnAction(sender:)))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.hidesBackButton = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let container = segue.destination as? MainGuideContainer else { return }
        container.containerDelegate = self
        
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
    
    @objc func backBtnAction(sender: UIBarButtonItem) {
        if mainContainer.alpha == 1 {
            self.navigationController?.popViewController(animated: true)
        }
        else {
            mainContainer.alpha = 1
            self.guideContainer.alpha = 0
            self.defineContainer.alpha = 0
            self.treatContainer.alpha = 0
            self.exceptContainer.alpha = 0
        }
    }
    
    @IBAction func onLogin(_ sender: Any) {
        let loginVC = AppStoryboard.main.instance.instantiateViewController(withIdentifier: VC.loginVC.rawValue) as! LoginViewController
        navigationController?.pushViewController(loginVC, animated: true)
    }
}


// MARK: containerView 뒤로가기 클릭시 이벤트 처리
extension GuideViewController: ContainerDelegate {
    func alterContainer(_ key: Int) {
        switch key {
        case Container.processGuide.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.guideContainer.alpha = 1
                self.mainContainer.alpha = 0
                self.defineContainer.alpha = 0
                self.treatContainer.alpha = 0
                self.exceptContainer.alpha = 0
            })
        case Container.define.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.guideContainer.alpha = 0
                self.mainContainer.alpha = 0
                self.defineContainer.alpha = 1
                self.treatContainer.alpha = 0
                self.exceptContainer.alpha = 0
            })
        case Container.treat.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.guideContainer.alpha = 0
                self.mainContainer.alpha = 0
                self.defineContainer.alpha = 0
                self.treatContainer.alpha = 1
                self.exceptContainer.alpha = 0
            })
        case Container.except.rawValue:
            UIView.animate(withDuration: 0.5, animations: {
                self.guideContainer.alpha = 0
                self.mainContainer.alpha = 0
                self.defineContainer.alpha = 0
                self.treatContainer.alpha = 0
                self.exceptContainer.alpha = 1
            })
        default:
            break
        }
        
    }
}

