//
//  RealmManager.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/23/24.
//

//import RealmSwift
//
//final class RealmManager {
//    static let shared = RealmManager()
//    private init() {}
//
//    func configureRealm(for userId: String) {
//        var config = Realm.Configuration()
//        
//        config.fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(userId).realm")
//        
//        Realm.Configuration.defaultConfiguration = config
//        if let fileURL = config.fileURL {
//                print("Realm file path for user \(userId): \(fileURL)")
//            }
//       
//    }
//}

import Foundation
import RealmSwift

final class RealmManager {
    static let shared = RealmManager()
    private var realms: [String: Realm] = [:]
    private var recentUsers: [String] = []
    private let cacheLimit = 5  // 메모리에 유지할 최대 사용자 수

    private init() {
        // 앱이 시작될 때, UserDefaults에서 최근 사용자 리스트를 복원합니다.
        if let savedUsers = UserDefaults.standard.array(forKey: "recentUsers") as? [String] {
            recentUsers = savedUsers
        }
    }
    
    private func realmConfiguration(for userId: String) -> Realm.Configuration {
        var config = Realm.Configuration()
        let fileURL = config.fileURL!.deletingLastPathComponent().appendingPathComponent("\(userId).realm")
        config.fileURL = fileURL
        return config
    }

    func configureRealm(for userId: String) -> Realm? {
        if let existingRealm = realms[userId] {
            updateRecentUsers(with: userId)
            return existingRealm
        } else {
            if recentUsers.count >= cacheLimit, let userToRemove = recentUsers.first {
                // 가장 오래된 사용자의 파일 삭제
                deleteRealmFiles(for: userToRemove)
                recentUsers.removeFirst()
            }

            do {
                let realm = try Realm(configuration: realmConfiguration(for: userId))
                realms[userId] = realm
                updateRecentUsers(with: userId)
                print("Realm file path for user \(userId): \(realm.configuration.fileURL!)")
                return realm
            } catch {
                print("Failed to open realm for user \(userId): \(error.localizedDescription)")
                return nil
            }
        }
    }

    private func updateRecentUsers(with userId: String) {
        if let index = recentUsers.firstIndex(of: userId) {
            recentUsers.remove(at: index)
        }
        recentUsers.append(userId)
        // 최근 사용자 리스트를 UserDefaults에 저장합니다.
        UserDefaults.standard.set(recentUsers, forKey: "recentUsers")
    }

    private func deleteRealmFiles(for userId: String) {
        let fileManager = FileManager.default
        let realmURL = realmConfiguration(for: userId).fileURL!
        let realmURLs = [
            realmURL,
            realmURL.appendingPathExtension("lock"),
            realmURL.appendingPathExtension("management")
        ]
        
        do {
            for url in realmURLs {
                if fileManager.fileExists(atPath: url.path) {
                    try fileManager.removeItem(at: url)
                    print("Deleted Realm file for user \(userId) at \(url.path)")
                }
            }
        } catch {
            print("Failed to delete Realm file for user \(userId): \(error.localizedDescription)")
        }
    }
}
