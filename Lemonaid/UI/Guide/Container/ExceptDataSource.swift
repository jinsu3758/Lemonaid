//
//  ExceptDataSource.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 12..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

class ExceptDataSource: NSObject, UICollectionViewDataSource {
    
    var objects: [String] = []
    
    func fill(data: [String]) {
        objects = data
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Key.exceptCell.rawValue, for: indexPath) as! ExceptCell
        let except = objects[indexPath.item]
        cell.fill(with: except)
        return cell
    }
}
