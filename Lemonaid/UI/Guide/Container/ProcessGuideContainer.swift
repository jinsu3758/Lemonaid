//
//  ProcessGuideContainer.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 1..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class ProcessGuideContainer: UIViewController {
    
    @IBOutlet weak var guideExamLabel: UILabel!
    @IBOutlet weak var guideExamImage: UIImageView!
    @IBOutlet weak var guidePayLabel: UILabel!
    @IBOutlet weak var guidePrescLabel: UILabel!
    @IBOutlet weak var guidePickLabel: UILabel!
    @IBOutlet weak var mainLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guideExamLabel.superview?.addConstraint(NSLayoutConstraint(item: guideExamLabel, attribute: .centerX, relatedBy: .equal,
                                                                   toItem: guideExamLabel.superview, attribute: .centerX,
                                                                   multiplier: 1, constant: guideExamImage.frame.width/2))
        
        mainLabel.text = SingleData.instance.disease.medicineName + "remoteGuideContent".localized
        guideExamLabel.text = SingleData.instance.disease.guideExam
        guidePayLabel.text = SingleData.instance.disease.guidePay
        guidePickLabel.text = SingleData.instance.disease.guidePick
        guidePrescLabel.text = SingleData.instance.disease.guidePresc
    }
}

