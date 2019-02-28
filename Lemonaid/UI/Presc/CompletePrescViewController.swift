//
//  CompletePrescViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 23..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import RxSwift

class CompletePrescViewController: UIViewController {

    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "prescComplete".localized
        SingleData.instance.isPay = false
        ApiUtil.setRefund(false)
            .subscribe { event in
                switch event {
                case .completed:
                    break
                case .error(let error):
                    debugPrint(error)
                    print("set 에러!!!")
                }
            }
            .disposed(by: disposeBag)
    }
    
    @IBAction func startMain(_ sender: Any) {
        navigationController?.popToRootViewController(animated: true)
        let mainVC = AppStoryboard.main.instance.instantiateViewController(withIdentifier: VC.mainVC.rawValue) as! MainViewController
        navigationController?.pushViewController(mainVC, animated: true)
    }
    
   

}
