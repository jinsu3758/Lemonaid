//
//  DiseaseCell.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 25..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class DiseaseCell: UICollectionViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var labelView: UIView!

    // performs any clean up necessary to prepare the view for use again
    override func prepareForReuse() {
        super.prepareForReuse()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func fill(with disease: Disease, colorIndex: Int) {
        titleLabel.text = disease.title
        labelView.backgroundColor = UIColor.colors[colorIndex]
    }
}
