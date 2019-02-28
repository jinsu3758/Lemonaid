//
//  ExamGuideViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 13..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class ExamGuideViewController: UIViewController {
    
    @IBOutlet weak var contentLabal: UILabel!
    @IBOutlet weak var loginBtn: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = SingleData.instance.disease.title + "exam".localized
        contentLabal.text = SingleData.instance.disease.guideStart
        
        let backBtn = UIBarButtonItem(image: UIImage(named: Image.back.rawValue), style: .plain, target: self, action: #selector(backBtnAction(sender:)))
        self.navigationItem.leftBarButtonItem = backBtn
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.hidesBackButton = true
        
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
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onLogin(_ sender: Any) {
        let loginVC = AppStoryboard.main.instance.instantiateViewController(withIdentifier: VC.loginVC.rawValue) as! LoginViewController
        self.navigationController?.pushViewController(loginVC, animated: true)
    }
}

