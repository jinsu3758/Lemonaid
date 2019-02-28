//
//  ReviewCell.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 29..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class ReviewCell: UICollectionViewCell {
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!

    func fill(with review: Review) {
        reviewLabel.text = review.comment
        var arr = review.date.components(separatedBy: " ")
        dateLabel.text = arr[0]
    }
}
