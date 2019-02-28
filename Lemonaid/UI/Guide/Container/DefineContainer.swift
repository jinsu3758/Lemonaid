//
//  DefineViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 9..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class DefineContainer: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
//    @IBOutlet weak var defineLabel: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var defineLabel: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if splitText(text: SingleData.instance.disease.title!) {
            titleLabel.text = SingleData.instance.disease.title + "basisDfine".localized
        }
        else {
           titleLabel.text = SingleData.instance.disease.title + "noBasisDefine".localized
        }
        defineLabel.text = SingleData.instance.disease.define
        

    }
    
    // MARK: 받침여부 판별 함수
    func splitText(text: String) -> Bool {
        guard let text = text.last else { return false }
        
        let val = UnicodeScalar(String(text))?.value
        guard let value = val else { return false }
        
        let z = (value - 0xac00) % 28
        
        if z == 0 {
            return false
        }
        else {
            return true
        }
    }
    
    
}
