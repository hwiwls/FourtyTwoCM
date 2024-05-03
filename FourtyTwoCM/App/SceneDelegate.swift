//
//  SceneDelegate.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit
import SnapKit
import Then

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
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }
    
    private func setupTokenRefreshListener() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleTokenRefreshFailure), name: NSNotification.Name("TokenRefreshFailed"), object: nil)
        }

        @objc private func handleTokenRefreshFailure() {
            // 토큰 삭제 등 세션 청소
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

