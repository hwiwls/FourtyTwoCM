//
//  PostMapViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/20/24.
//

import UIKit
import MapKit
import CoreLocation

class PostMapViewController: BaseViewController, CLLocationManagerDelegate {
    
    private let postMapView = MKMapView().then {
        $0.preferredConfiguration = MKStandardMapConfiguration()
        $0.isZoomEnabled = true
        $0.isScrollEnabled = true
        $0.isPitchEnabled = true
        $0.showsUserLocation = true
    }
    
    private let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
    }
    
    override func configHierarchy() {
        view.addSubviews([
            postMapView
        ])
    }
    
    override func configLayout() {
        postMapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            centerMapOnLocation(location: location)
            locationManager.stopUpdatingLocation()
        }
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        postMapView.setRegion(coordinateRegion, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("유저 위치 불러오기 실패: \(error.localizedDescription)")
    }
}
