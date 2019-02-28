//
//  ReviewDataSource.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 29..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import RxSwift

class ReviewDataSource: NSObject, UICollectionViewDataSource {

    private let disposeBag = DisposeBag()
    var reviews: [Review] = []

    // MARK: 리뷰 데이터 수신 후 처리
    func fill(callback: @escaping (State) -> ()) {
        ApiUtil.getReview()
            .subscribe{ event in
                switch event {
                case .success(let data):
                    self.reviews = data
                    callback(.success)
                case .error(let error):
                    callback(.fail)
                    debugPrint(error)
                }
            }.disposed(by: disposeBag)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return reviews.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Key.reviewCell.rawValue, for: indexPath) as! ReviewCell
        let review = reviews[indexPath.item]
        cell.fill(with: review)
        return cell
    }

}
