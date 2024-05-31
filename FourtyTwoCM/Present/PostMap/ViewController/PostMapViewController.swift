//
//  PostMapViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/20/24.
//

//import UIKit
//import MapKit
//import CoreLocation
//import RxSwift
//import RxCocoa
//import Kingfisher
//
//class PostMapViewController: BaseViewController {
//
//    // MARK: - Properties
//    private let postMapView = MKMapView().then {
//        $0.preferredConfiguration = MKStandardMapConfiguration()
//        $0.isZoomEnabled = true
//        $0.isScrollEnabled = true
//        $0.isPitchEnabled = true
//        $0.showsUserLocation = true
//    }
//
//    private let locationManager = CLLocationManager()
//    private let viewModel = PostMapViewModel()
//    private var userLocation: CLLocation?
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupLocationManager()
//        registerMapAnnotationViews()
//    }
//    
//    override func configView() {
//        postMapView.delegate = self
//        postMapView.userTrackingMode = .follow
//    }
//    
//    override func configHierarchy() {
//        view.addSubviews([postMapView])
//    }
//
//    override func configLayout() {
//        postMapView.snp.makeConstraints { $0.edges.equalToSuperview() }
//    }
//
//    override func bind() {
//        let loadTrigger = Driver.just(())
//
//        let input = PostMapViewModel.Input(loadTrigger: loadTrigger)
//        let output = viewModel.transform(input: input)
//
//        output.posts
//            .drive(onNext: { [weak self] posts in
//                self?.addMarkers(for: posts)
//            })
//            .disposed(by: disposeBag)
//    }
//    
//    private func setupLocationManager() {
//        locationManager.delegate = self
//        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
//        locationManager.distanceFilter = 50
//        locationManager.requestWhenInUseAuthorization()
//        locationManager.startUpdatingLocation()
//    }
//
//    func registerMapAnnotationViews() {
//        postMapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotationView.self))
//    }
//
//    private func addMarkers(for posts: [Post]) {
//        postMapView.removeAnnotations(postMapView.annotations)
//
//        posts.forEach { post in
//            guard let latitude = Double(post.content1 ?? ""), let longitude = Double(post.content2 ?? "") else { return }
//
//            let annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
//            annotation.imageName = "\(BaseURL.baseURL.rawValue)/\(post.files.first ?? "")"
//            self.postMapView.addAnnotation(annotation)
//        }
//    }
//}
//
//// MARK: - CLLocationManagerDelegate
//extension PostMapViewController: CLLocationManagerDelegate {
//    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        if let location = locations.last {
//            userLocation = location
//            centerMapOnLocation(location: location)
//        }
//    }
//
//    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
//        print("유저 위치 찾기 실패: \(error.localizedDescription)")
//    }
//    
//    private func centerMapOnLocation(location: CLLocation) {
//        let regionRadius: CLLocationDistance = 1000
//        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
//        postMapView.setRegion(coordinateRegion, animated: true)
//    }
//}
//
//// MARK: - MKMapViewDelegate
//extension PostMapViewController: MKMapViewDelegate {
//    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
//        guard !(annotation is MKUserLocation) else { return nil }
//
//        let identifier = NSStringFromClass(CustomAnnotationView.self)
//        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView
//
//        if annotationView == nil {
//            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
//            annotationView?.canShowCallout = true
//            annotationView?.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
//        } else {
//            annotationView?.annotation = annotation
//        }
//
//        if let customAnnotation = annotation as? CustomAnnotation, let imageUrl = customAnnotation.imageName {
//            let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 52, height: 52))
//            if let url = URL(string: imageUrl) {
//                imageView.kf.setImage(with: url)
//            }
//            annotationView?.leftCalloutAccessoryView = imageView
//        }
//
//        return annotationView
//    }
//}

import UIKit
import MapKit
import CoreLocation
import RxSwift
import RxCocoa
import Kingfisher

class PostMapViewController: BaseViewController {

    // MARK: - Properties
    private let postMapView = MKMapView().then {
        $0.preferredConfiguration = MKStandardMapConfiguration()
        $0.isZoomEnabled = true
        $0.isScrollEnabled = true
        $0.isPitchEnabled = true
        $0.showsUserLocation = true
    }

    private let locationManager = CLLocationManager()
    private let viewModel = PostMapViewModel()
    private var userLocation: CLLocation?
    private var selectedAnnotationView: CustomAnnotationView?
    
    private let postDetailView = PostDetailView().then {
        $0.isHidden = true
        $0.layer.cornerRadius = 12
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLocationManager()
        registerMapAnnotationViews()
    }
    
    override func configView() {
        postMapView.delegate = self
        postMapView.userTrackingMode = .follow
    }
    
    override func configHierarchy() {
        view.addSubviews([
            postMapView,
            postDetailView
        ])
    }

    override func configLayout() {
        postMapView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        postDetailView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(36)
            $0.height.equalTo(180)
        }
    }

    override func bind() {
        let loadTrigger = Driver.just(())

        let input = PostMapViewModel.Input(loadTrigger: loadTrigger)
        let output = viewModel.transform(input: input)

        output.posts
            .drive(onNext: { [weak self] posts in
                self?.addMarkers(for: posts)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.distanceFilter = 50
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    func registerMapAnnotationViews() {
        postMapView.register(CustomAnnotationView.self, forAnnotationViewWithReuseIdentifier: NSStringFromClass(CustomAnnotationView.self))
    }

    private func addMarkers(for posts: [Post]) {
        postMapView.removeAnnotations(postMapView.annotations)

        posts.forEach { post in
            guard let latitude = Double(post.content1 ?? ""), let longitude = Double(post.content2 ?? "") else { return }

            let annotation = CustomAnnotation(coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude))
            annotation.post = post
            annotation.imageName = "\(BaseURL.baseURL.rawValue)/\(post.files.first ?? "")"
            self.postMapView.addAnnotation(annotation)
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension PostMapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            userLocation = location
            centerMapOnLocation(location: location)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("유저 위치 찾기 실패: \(error.localizedDescription)")
    }
    
    private func centerMapOnLocation(location: CLLocation) {
        let regionRadius: CLLocationDistance = 1000
        let coordinateRegion = MKCoordinateRegion(center: location.coordinate, latitudinalMeters: regionRadius, longitudinalMeters: regionRadius)
        postMapView.setRegion(coordinateRegion, animated: true)
    }
}

// MARK: - MKMapViewDelegate
extension PostMapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !(annotation is MKUserLocation) else { return nil }

        let identifier = NSStringFromClass(CustomAnnotationView.self)
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? CustomAnnotationView

        if annotationView == nil {
            annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
        } else {
            annotationView?.annotation = annotation
        }

        if let customAnnotation = annotation as? CustomAnnotation {
            annotationView?.update(with: customAnnotation)
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let annotationView = view as? CustomAnnotationView, let annotation = view.annotation as? CustomAnnotation else { return }

        selectedAnnotationView?.deselect()
        selectedAnnotationView = annotationView
        annotationView.select()
        
        if let post = annotation.post {
            postDetailView.configure(with: post)
            postDetailView.isHidden = false
        }
    }
}
