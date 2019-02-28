//
//  MapContainer.swift
//  Lemonaid
//
//  Created by 박진수 on 2018. 11. 22..
//  Copyright © 2018년 박진수. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import RxSwift

class MapContainer: UIViewController {
    
    var locationManager = CLLocationManager()
    var currentLocation: CLLocation?
    var mapView: GMSMapView!
    var placesClient: GMSPlacesClient!
    var zoomLevel: Float = 15.0
    var selectedPlace: GMSPlace?
    var mapDelegate: MapDelegate?
    var myMarker: GMSMarker!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(setAuthorization), name: UIApplication.didBecomeActiveNotification, object: nil)
        
        locationManager = CLLocationManager()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        setAuthorization()
        
        placesClient = GMSPlacesClient.shared()
        myMarker = GMSMarker()
        myMarker.title = "me".localized
        myMarker.icon = GMSMarker.markerImage(with: .blue)
        
        let camera = GMSCameraPosition.camera(withLatitude: -33.86, longitude: 151.20, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: view.bounds, camera: camera)
        mapView.settings.myLocationButton = true
        mapView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        mapView.delegate = self
        mapView.isHidden = true
        view = mapView
        
    }
    
    @objc func setAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .restricted, .denied:
            alertLocationService(.locationAuthor)
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        }
    }
    
    // MARK: 에러 Alert 출력 함수
    func alertLocationService(_ message: Message) {
        switch message {
        case .gps:
            let alert = UIAlertController(title: "error".localized, message: message.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in self.navigationController?.popViewController(animated: true)
            }))
            present(alert, animated: true, completion: nil)
        case .locationAuthor:
            let alert = UIAlertController(title: "error".localized, message: message.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: {
                _ in if let url = URL(string: UIApplication.openSettingsURLString) {
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.open(url, completionHandler: nil)
                    }
                    else {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
                else {
                    self.navigationController?.popViewController(animated: true)
                }
            }))
            present(alert, animated: true, completion: nil)
        case .network:
            let alert = UIAlertController(title: "error".localized, message: message.instance, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "ok".localized, style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            break
        }
    }
    
}

extension MapContainer: CLLocationManagerDelegate {
    
    // MARK: 위치 정보 response 처리 함수
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        self.myMarker.position = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        
        self.myMarker.map = self.mapView
        
        let camera = GMSCameraPosition.camera(withLatitude: location.coordinate.latitude,
                                              longitude: location.coordinate.longitude,
                                              zoom: zoomLevel)
        if mapView.isHidden == true {
            ApiUtil.getPharmacyList(location: "\(location.coordinate.latitude),\(location.coordinate.longitude)")
                .subscribe { event in
                    switch event {
                    case .success(let data):
                        self.mapDelegate?.stopIndicator()
                        for item in data {
                            let marker = GMSMarker()
                            marker.position = CLLocationCoordinate2D(latitude: item.lat, longitude: item.lng)
                            marker.title = item.name
                            marker.snippet = item.address
                            marker.map = self.mapView
                            if self.mapView.isHidden {
                                self.mapView.isHidden = false
                                self.mapView.camera = camera
                            }
                        }
                    case .error(let error):
                        self.alertLocationService(.network)
                        debugPrint(error)
                    }
                }
                .disposed(by: disposeBag)
        }
        
    }
    
    // MARK: 권환 처리 함수
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            self.locationManager.requestWhenInUseAuthorization()
            self.alertLocationService(.locationAuthor)
        case .notDetermined:
            self.locationManager.requestWhenInUseAuthorization()
        default:
            break
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager.stopUpdatingLocation()
        self.alertLocationService(.gps)
    }
}

extension MapContainer: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let addr = Address(marker.position.latitude, marker.position.longitude, marker.title!,marker.snippet!)
        self.mapDelegate?.sendAddr(addr)
        return false
    }
}
