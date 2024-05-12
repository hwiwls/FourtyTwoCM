//
//  CommentViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import Foundation
import RxSwift
import RxCocoa

final class CommentViewModel: ViewModelType {
    private let postId: String
    
    struct Input {
        let closeTrigger: Observable<Void>
        let textInput: Observable<String>
        let keyboardDismissalTrigger: Observable<Void>
        let submitCommentTrigger: Observable<Void>
        let commentText: Observable<String>
    }

    struct Output {
        let dismiss: Driver<Void>
        let submitButtonVisible: Driver<Bool>
        let keyboardDismiss: Driver<Void>
        let commentSubmitted: Driver<Comment>
        let errors: Driver<Error>
        let refreshComments: Driver<[Comment]>
    }
    
    init(postId: String) {
        self.postId = postId
    }
    
    var disposeBag = DisposeBag()

    func transform(input: Input) -> Output {
        let dismissAction = input.closeTrigger
            .asDriver(onErrorJustReturn: ())

        let submitButtonVisible = input.textInput
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
        
        let keyboardDismiss = input.keyboardDismissalTrigger
                    .asDriver(onErrorJustReturn: ())
        
        let errors = PublishSubject<Error>()
        let errorDriver = errors
                .asDriver(onErrorJustReturn: NSError(domain: "CommentError", code: -1, userInfo: nil) as Error)  // 에러도 Driver로 변환
        
        let commentSubmitted = input.submitCommentTrigger
                        .withLatestFrom(input.commentText)
                        .flatMapLatest { text -> Observable<Comment> in
                            let query = WriteCommentQuery(content: text)
                            return NetworkManager.performRequest(
                                route: .writeComment(postId: self.postId, query: query),
                                dataType: Comment.self
                            )
                            .asObservable()
                            .catch { error -> Observable<Comment> in
                                errors.onNext(error)
                                return Observable.empty()
                            }
                        }
                        .asDriver(onErrorDriveWith: Driver.empty())

                // 새 댓글 추가 후 댓글 리스트 새로고침
                let refreshComments = commentSubmitted
                    .flatMapLatest { _ -> Driver<[Comment]> in
                        NetworkManager.performRequest(
                            route: .viewCertainPost(postId: self.postId),
                            dataType: ViewCertainPostModel.self
                        )
                        .do(onSuccess: { viewCertainPostModel in
                            print("Fetched comments: \(viewCertainPostModel.comments)")
                        })
                        .map { $0.comments }
                        .asDriver(onErrorJustReturn: [])
                    }
        
        return Output(
            dismiss: dismissAction,
            submitButtonVisible: submitButtonVisible,
            keyboardDismiss: keyboardDismiss,
            commentSubmitted: commentSubmitted,
            errors: errorDriver,
            refreshComments: refreshComments
        )
            
    }
}
