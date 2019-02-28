//
//  ExceptContainer.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 12..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class ExceptContainer: UIViewController {
    
    @IBOutlet weak var exceptCollectionView: UICollectionView!
    @IBOutlet weak var introLabel: UILabel!
    
    private let exceptDataSource = ExceptDataSource()
    private let exceptPresenter = ExceptPresenter()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        exceptCollectionView.dataSource = exceptDataSource
        exceptCollectionView.delegate = exceptPresenter
        
        introLabel.text = SingleData.instance.disease.exceptComment
        exceptDataSource.fill(data: SingleData.instance.disease.exceptTarget)
        exceptCollectionView.reloadData()
    }
}

