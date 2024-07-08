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
    var disposeBag = DisposeBag()
    
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
        let errors: Driver<String>
        let refreshComments: Driver<[Comment]>
    }
    
    init(postId: String) {
        self.postId = postId
    }

    func transform(input: Input) -> Output {
        let dismissAction = input.closeTrigger
            .asDriver(onErrorJustReturn: ())

        let submitButtonVisible = input.textInput
            .map { !$0.isEmpty }
            .distinctUntilChanged()
            .asDriver(onErrorJustReturn: false)
        
        let keyboardDismiss = input.keyboardDismissalTrigger
            .asDriver(onErrorJustReturn: ())

        let errorRelay = PublishRelay<String>()
        
        let commentSubmitted = input.submitCommentTrigger
            .withLatestFrom(input.commentText)
            .flatMapLatest { text -> Observable<Comment> in
                let query = WriteCommentQuery(content: text)
                return NetworkManager.performRequest(
                    route: Router.writeComment(postId: self.postId, query: query),
                    dataType: Comment.self
                )
                .asObservable()
                .catch { error -> Observable<Comment> in
                    if let apiError = error as? APIError {
                        errorRelay.accept(apiError.errorMessage)
                    } else {
                        errorRelay.accept("알 수 없는 오류가 발생했습니다.")
                    }
                    return Observable.empty()
                }
            }
            .asDriver(onErrorDriveWith: Driver.empty())
        
        let refreshComments = commentSubmitted
            .flatMapLatest { _ -> Driver<[Comment]> in
                NetworkManager.performRequest(
                    route: Router.viewCertainPost(postId: self.postId),
                    dataType: ViewCertainPostModel.self
                )
                .map { $0.comments }
                .asDriver(onErrorJustReturn: [])
            }

        let errorDriver = errorRelay.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다.")
        
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
