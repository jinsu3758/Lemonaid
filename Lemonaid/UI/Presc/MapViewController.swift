//
//  MapViewController.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 20..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import RxSwift

protocol MapDelegate {
    func sendAddr(_ addr: Address)
    func stopIndicator()
}

class MapViewController: UIViewController {
    
    var selectedPharmacy: String = ""
    var selectedAddr: Address?  //선택된 약국 데이터
    private let disposeBag = DisposeBag()
    
    @IBOutlet weak var progressView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        self.navigationItem.title = "pick up".localized
        
        progressView.hidesWhenStopped = true
        progressView.startAnimating()
    }
    
    // MARK: 선택된 약국 데이터 post후 이벤트 처리
    @IBAction func selectPharmacy(_ sender: Any) {
        if let addr = selectedAddr {
            let alert = UIAlertController(title: "selectPharmacy".localized, message: "\(addr.name)\(addr.address)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "cancel".localized, style: .default, handler: nil))
            alert.addAction(UIAlertAction(title: "ok".localized, style: .destructive, handler: { _ in
                ApiUtil.setPharmacy(addr: addr).subscribe { event in
                    switch event {
                    case .completed:
                        let completeVC = AppStoryboard.presc.instance.instantiateViewController(withIdentifier: VC.completePrescVC.rawValue) as! CompletePrescViewController
                        self.navigationController?.pushViewController(completeVC, animated: true)
                        self.progressView.isHidden = false
                    case .error(let error):
                        debugPrint(error)
                        let alert = UIAlertController(title: "error".localized, message: Message.network.instance, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                        self.progressView.isHidden = false
                    }
                    }.disposed(by: self.disposeBag)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
        else {
            let alert = UIAlertController(title: "error".localized, message: Message.selectPharmacy.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let container = segue.destination as! MapContainer
        container.mapDelegate = self
    }
}

extension MapViewController: MapDelegate {
    // MARK: 주소 get
    func sendAddr(_ addr: Address) {
        selectedAddr = addr
    }
    func stopIndicator() {
        progressView.isHidden = true
    }
}
