//
//  PermissionViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/1/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class PermissionsViewController: BaseViewController {
    private var viewModel = PermissionsViewModel()
    
    private let titleLabel = UILabel().then {
        $0.text = "Welcome!👋🏻"
        $0.textAlignment = .left
        $0.font = .aggro.aggroMedium32
        $0.textColor = .offWhite
    }
    
    private let subtitleLabel = UILabel().then {
        $0.text = "반가워요:) 앱의 사용성을 위해 위치, 카메라 및 갤러리 접근 권한이 필요해요."
        $0.textAlignment = .left
        $0.numberOfLines = 2
        $0.addCharacterSpacing()
        $0.font = .systemFont(ofSize: 15)
        $0.textColor = .offWhite
    }
    
    private let startBtn = PointButton(title: "시작하기")
    
    private let viewDidLoadSubject = PublishSubject<Void>()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
                self,
                selector: #selector(handlePermissionAlert(notification:)),
                name: NSNotification.Name("PresentAlert"),
                object: nil
            )
        
        startBtn.addTarget(self, action: #selector(btnclick), for: .touchUpInside)
    }
    
    @objc func btnclick() {
        print("버튼을 클릭했습니다")
    }
    
    @objc func handlePermissionAlert(notification: Notification) {
        if let alert = notification.userInfo?["alert"] as? UIAlertController {
            DispatchQueue.main.async { [weak self] in
                self?.present(alert, animated: true)
            }
        }
    }
    
    deinit {
        print("deinit")
        NotificationCenter.default.removeObserver(self)
    }
    
    override func bind() {
        let input = PermissionsViewModel.Input(
            viewDidLoad: viewDidLoadSubject.asObservable(),
            agreeButtonTapped: startBtn.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        output.showPermissionAlert
            .subscribe(onNext: { [weak self] message in
                self?.showAlert(message: message)
            })
            .disposed(by: disposeBag)
        
        output.navigateToTabBar
            .subscribe(onNext: { [weak self] in
                do {
                    let isLocationAuthorized = try Permissions.shared.isLocationAuthorized.value()
                    let isCameraAuthorized = try Permissions.shared.isCameraAuthorized.value()
                    let isPhotosAuthorized = try Permissions.shared.isPhotosAuthorized.value()
                    
                    if isLocationAuthorized && isCameraAuthorized && isPhotosAuthorized {
                        UserDefaults.standard.set(true, forKey: "isPermissioned")
                    }
                    self?.navigateToTabBarController()
                } catch {
                    print("Error reading permission status: \(error)")
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func configNav() {
        self.navigationItem.title = "사용자 권한 설정"
        self.navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.offWhite]
        
        let backImage = UIImage(systemName: "chevron.left")?.withRenderingMode(.alwaysOriginal).withTintColor(.offWhite)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: backImage, style: .plain, target: self, action: #selector(backButtonTapped))
    }
    
    @objc private func backButtonTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            titleLabel,
            subtitleLabel,
            startBtn
        ])
        
        
    }
    
    override func configLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(50)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
        }
        
        startBtn.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-50)
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(40)
        }
        
    }
    
    private func showAlert(message: String) {
        print("에엥")
        let alert = UIAlertController(
            title: "권한 설정이 필요합니다.", message: "서비스 사용을 위해 접근 권한이 필요합니다.\n디바이스의 '설정 > 개인정보 보호'에서 서비스를 켜주세요.",
            preferredStyle: .alert)
        let goSetting = UIAlertAction(title: "설정으로 이동", style: .destructive) { _ in
            if let appSetting = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(appSetting)
            }
        }
        let cancel = UIAlertAction(title: "취소", style: .default)
        alert.addAction(cancel)
        alert.addAction(goSetting)
        present(alert, animated: true)
    }
    
    private func navigateToTabBarController() {
        let tabBarVC = TabBarController()
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let sceneDelegate = windowScene.delegate as? SceneDelegate,
              let window = sceneDelegate.window else {
            return
        }

        UIView.transition(with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
            window.rootViewController = tabBarVC
        })
    }

}
