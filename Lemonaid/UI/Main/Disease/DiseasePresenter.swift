//
//  MainPresenter.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 25..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit

public protocol ClickListener {
    func onClick(index: Int)
}

class DiseasePresenter: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    var callback: ClickListener?

    // Tells the delegate that the item at the specified index path was selected.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        callback?.onClick(index: indexPath.item)
    }

    // Asks the delegate for the size of the specified item’s cell.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let edgeInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        let cellHeight = collectionView.frame.height * 0.3
        return CGSize(width: collectionView.frame.width - edgeInsets.left - edgeInsets.right, height: cellHeight)
    }

    // Asks the delegate for the margins to apply to content in the specified section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 15.0, bottom: 10.0, right: 15.0)
    }

    // Asks the delegate for the spacing between successive items in the rows or columns of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }
   
    
    
}
