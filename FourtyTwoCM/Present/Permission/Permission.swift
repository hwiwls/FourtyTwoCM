//
//  Permission.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/1/24.
//

import UIKit
import CoreLocation
import AVFoundation
import Photos
import RxSwift

class Permissions: NSObject, CLLocationManagerDelegate {
    static let shared = Permissions()

    let locationManager = CLLocationManager()
    let isLocationAuthorized = BehaviorSubject<Bool>(value: false)
    let isCameraAuthorized = BehaviorSubject<Bool>(value: false)
    let isPhotosAuthorized = BehaviorSubject<Bool>(value: false)

    private override init() {
        super.init()
        locationManager.delegate = self
        checkPermissions()
    }

    func checkPermissions() {
        checkCameraAuthorization()
        checkPhotosAuthorization()
        checkUserDeviceLocationServiceAuthorization()
    }

    func checkCameraAuthorization() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .notDetermined:
            print("카메라 허용 거부 1")
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    self?.isCameraAuthorized.onNext(granted)
                    if !granted {
                        self?.showRequestAccessAlert(for: "카메라")
                    }
                }
            }
        case .restricted, .denied:
            print("카메라 허용 거부 2")
            showRequestAccessAlert(for: "카메라")
        case .authorized:
            print("카메라 허용 성공")
            isCameraAuthorized.onNext(true)
        @unknown default:
            fatalError("Unhandled case for AVCaptureDevice authorization status")
        }
    }

    func checkPhotosAuthorization() {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            print("갤러리 허용 x 1")
            PHPhotoLibrary.requestAuthorization { [weak self] status in
                DispatchQueue.main.async {
                    self?.isPhotosAuthorized.onNext(status == .authorized)
                    if status != .authorized {
                        self?.showRequestAccessAlert(for: "갤러리")
                    }
                }
            }
        case .restricted, .denied:
            print("갤러리 허용 x 2")
            showRequestAccessAlert(for: "갤러리")
        case .authorized:
            print("갤러리 허용")
            isPhotosAuthorized.onNext(true)
        case .limited:
            print("갤러리 허용 x 3")
            print("limited")
        @unknown default:
            fatalError("Unhandled case for PHPhotoLibrary authorization status")
        }
    }

    func checkUserDeviceLocationServiceAuthorization() {
            let authorizationStatus: CLAuthorizationStatus
            if #available(iOS 14.0, *) {
                authorizationStatus = locationManager.authorizationStatus
            } else {
                authorizationStatus = CLLocationManager.authorizationStatus()
            }

            switch authorizationStatus {
            case .notDetermined:
                print("위치 권한 상태가 결정되지 않음, 권한 요청 가능")
                // 권한 상태가 결정되지 않음, 권한 요청 가능
                locationManager.requestWhenInUseAuthorization()
            case .restricted, .denied:
                // 권한이 제한되거나 거부됨, 설정으로 유도
                print("위치 권한이 제한되거나 거부됨, 설정으로 유도")
                showRequestAccessAlert(for: "위치")
            case .authorizedWhenInUse, .authorizedAlways:
                // 권한 허용됨, 위치 업데이트 시작
                print("위치 권한 허용됨, 위치 업데이트 시작")
                isLocationAuthorized.onNext(true)
                locationManager.startUpdatingLocation()
            default:
                print("Unhandled authorization status")
            }
        }

    func checkUserCurrentLocationAuthorization(_ status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        case .denied, .restricted:
            showRequestAccessAlert(for: "위치")
        case .authorizedWhenInUse, .authorizedAlways:
            isLocationAuthorized.onNext(true)
            locationManager.startUpdatingLocation()
        default:
            print("Unhandled authorization status")
        }
    }

    func showRequestAccessAlert(for service: String) {
        let alert = UIAlertController(
            title: "\(service) 접근 허용 필요",
            message: "\(service) 서비스 사용을 위해 접근 권한이 필요합니다.\n디바이스의 '설정 > 개인정보 보호'에서 \(service) 서비스를 켜주세요.",
            preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        alert.addAction(cancel)
        alert.addAction(goSetting)
        
        // ViewController에서 present 해야 하므로, Notification 사용 또는 Delegate 설정 필요
        NotificationCenter.default.post(name: NSNotification.Name("PresentAlert"), object: nil, userInfo: ["alert": alert])
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("locationManager >> didUpdateLocations ")
        
        var longitude = CLLocationDegrees()
        var latitude = CLLocationDegrees()
         
        if let location = locations.first {
            longitude = location.coordinate.latitude
            latitude = location.coordinate.longitude
        }
        locationManager.stopUpdatingLocation()
        
        print("위도: \(latitude)")
        print("경도: \(longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Failed to get location: \(error)")
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        checkUserDeviceLocationServiceAuthorization()
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkUserDeviceLocationServiceAuthorization()
    }
    
    
}
