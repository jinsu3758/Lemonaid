//
//  PrescViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 19..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class PrescViewController: UIViewController {
    
    @IBOutlet weak var prescSuccessLabel: UILabel!
    @IBOutlet weak var prescFailLabel: UILabel!
    @IBOutlet weak var moveBtn: UIButton!
    @IBOutlet weak var prescImg: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.hidesBackButton = true
        
        navigationItem.title = "prescIssue".localized
//        prescSuccessLabel.text = SingleData.instance.disease.medicineName + "prescSuccess".localized
        prescFailLabel.text = "prescFail".localized
    }

    @IBAction func moveVC(_ sender: Any) {
        let mapVC = AppStoryboard.presc.instance.instantiateViewController(withIdentifier: VC.mapVC.rawValue) as! MapViewController
        self.navigationController?.pushViewController(mapVC, animated: true)
    }
    
}
