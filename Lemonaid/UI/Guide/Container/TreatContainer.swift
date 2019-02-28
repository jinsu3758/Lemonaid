//
//  TreatContainer.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 13..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class TreatContainer: UIViewController {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentLabel.text =  SingleData.instance.disease.treatAndRisk
    }
    
}

