//
//  SceneDelegate.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit
import SnapKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let scene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: scene)
        let rootViewController = UINavigationController(rootViewController: SignInViewController())

        window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
        
        setupTokenRefreshListener()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        NotificationCenter.default.post(name: .appDidBecomeActive, object: nil)
    }

    func sceneWillResignActive(_ scene: UIScene) {
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        NotificationCenter.default.post(name: .appDidEnterBackground, object: nil)
    }
    
    private func setupTokenRefreshListener() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleTokenRefreshFailure), name: NSNotification.Name("TokenRefreshFailed"), object: nil)
    }

    @objc private func handleTokenRefreshFailure() {
        try? Keychain.shared.deleteToken(kind: .accessToken)
        try? Keychain.shared.deleteToken(kind: .refreshToken)
        UserDefaults.standard.removeObject(forKey: "userID")
        
        DispatchQueue.main.async {
            self.changeRootViewControllerToSignIn()
        }
    }

    private func changeRootViewControllerToSignIn() {
        guard (window?.windowScene) != nil else { return }
        
        let signInVC = SignInViewController()
        signInVC.sessionExpiredMessage = "세션이 만료되었습니다. 재로그인 해주세요."
        
        let navController = UINavigationController(rootViewController: signInVC)
        window?.rootViewController = navController
        window?.makeKeyAndVisible()
    }
}

extension Notification.Name {
    static let appDidBecomeActive = Notification.Name("appDidBecomeActive")
    static let appDidEnterBackground = Notification.Name("appDidEnterBackground")
}
