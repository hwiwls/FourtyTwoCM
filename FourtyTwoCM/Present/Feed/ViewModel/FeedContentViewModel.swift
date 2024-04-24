//
//  FeedContentViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import Foundation
import RxSwift
import RxCocoa

class FeedContentViewModel {
    var post: BehaviorSubject<Post>

    init(post: Post) {
        self.post = BehaviorSubject<Post>(value: post)
    }

    struct Output {
        let profileImageUrl: Observable<URL?>
        let firstPostImageUrl: Observable<URL?>
        let contentText: Observable<String>
        let userIDText: Observable<String>
    }

    func transform() -> Output {
        let profileImageUrl = post.map { post in
            guard let profileImageString = post.creator.profileImage else { return URL(string:"") }
            return URL(string: profileImageString)
        }

        let firstPostImageUrl = post.map { post in
            guard let firstImageUrl = post.files.first else { return URL(string:"") }
            return URL(string: firstImageUrl)
        }

        let contentText = post.map { $0.content }
        let userIDText = post.map { $0.creator.nick }

        return Output(
            profileImageUrl: profileImageUrl,
            firstPostImageUrl: firstPostImageUrl,
            contentText: contentText,
            userIDText: userIDText
        )
    }
}
