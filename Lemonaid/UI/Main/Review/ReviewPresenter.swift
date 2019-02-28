//
//  ReviewPresenter.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 29..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit



class ReviewPresenter: NSObject, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    var cellSize: CGSize?
    // Tells the delegate that the item at the specified index path was selected.
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    // Asks the delegate for the size of the specified item’s cell.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let edgeInsets = self.collectionView(collectionView, layout: collectionViewLayout, insetForSectionAt: indexPath.section)
        return CGSize(width: collectionView.frame.width - edgeInsets.left - edgeInsets.right, height: collectionView.frame.height)
    }
    
    // Asks the delegate for the margins to apply to content in the specified section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 5.0, left: 10.0, bottom: 5.0, right: 10.0)
    }
    
    // Asks the delegate for the spacing between successive items in the rows or columns of a section.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 20.0
    }
    
    
    
    
    
}

