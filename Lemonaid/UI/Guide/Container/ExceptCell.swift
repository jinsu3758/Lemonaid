//
//  ExceptCell.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 12..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class ExceptCell: UICollectionViewCell {
    
    @IBOutlet weak var contentLabel: UILabel!
    
    func fill(with content: String) {
        contentLabel.text = content
    }
}
