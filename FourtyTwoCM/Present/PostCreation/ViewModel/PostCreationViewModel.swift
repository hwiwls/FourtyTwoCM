//
//  PostCreationViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import UIKit
import RxSwift
import RxCocoa

final class PostCreationViewModel: ViewModelType {
    var disposeBag = DisposeBag()

    struct Input {
        let submitTap: Observable<Void>
    }

    struct Output {
        let postSubmitted: Observable<Void>
        let image: Observable<UIImage>
    }

    private let imageSubject: BehaviorSubject<UIImage>
    private let postSubmittedSubject = PublishSubject<Void>()

    init(image: UIImage) {
        self.imageSubject = BehaviorSubject(value: image)
    }

    func transform(input: Input) -> Output {
        input.submitTap
            .subscribe(onNext: { [weak self] _ in
                self?.postSubmittedSubject.onNext(())
            })
            .disposed(by: disposeBag)

        return Output(
            postSubmitted: postSubmittedSubject.asObservable(),
            image: imageSubject.asObservable()
        )
    }
}
