//
//  DiseaseDataSource.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 10. 25..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import Alamofire
import RxSwift

class DiseaseDataSource: NSObject, UICollectionViewDataSource {

    private let disposeBag = DisposeBag()
    
    var objects: [Disease] = []

    // MARK: 질병 데이터 수신 후 처리
    func fill(callback: @escaping (State) -> ()) {
        objects.removeAll()
        ApiUtil.getDiseaseList()
            .subscribe { event in
                switch event {
                case .success(let data):
                    for item in data {
                        self.objects.append(Disease(item))
                    }

                    callback(.success)
                case .error(let error):
                    callback(.fail)
                    debugPrint(error)
                }
            }.disposed(by: disposeBag)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Key.diseaseCell.rawValue, for: indexPath) as! DiseaseCell
        cell.contentView.layer.cornerRadius = 5
        cell.contentView.layer.masksToBounds = true
        let disease = objects[indexPath.item]
        cell.fill(with: disease, colorIndex: indexPath.item)
        return cell
    }

}
