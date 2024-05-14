//
//  PostsViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/12/24.
//

import UIKit
import RxSwift
import RxCocoa

final class MyPostsViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    struct Input {
        let trigger: Observable<Void>
    }
    
    struct Output {
        let posts: Driver<[Post]>
        let errors: Driver<Error>
    }
    
    func transform(input: Input) -> Output {
        print("ViewModel 변환 시작")
        let errors = PublishSubject<Error>()
        
        let userId = UserDefaults.standard.string(forKey: "userID") ?? ""
        
        let posts = input.trigger
            .observe(on: MainScheduler.instance)
            .flatMapLatest { _ -> Observable<[Post]> in
                print("네트워크 요청 트리거 수신")
                let query = ViewMyPostsQuery(product_id: "ker0r0")
                return NetworkManager.performRequest(route: .viewMyPosts(userID: userId, query: query), dataType: FeedModel.self)
                    .map { $0.data }
                    .asObservable()
                    .catch { error in
                        print("Network error: \(error)")
                        errors.onNext(error)
                        return Observable.empty()
                    }
            }.asDriver(onErrorJustReturn: [])


        return Output(posts: posts, errors: errors.asDriver(onErrorJustReturn: NSError() as Error))
    }
}
