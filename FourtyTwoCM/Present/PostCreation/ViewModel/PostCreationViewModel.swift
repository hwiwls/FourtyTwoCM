//
//  PostCreationViewModel.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import CoreLocation

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
    private let postTextViewSubject = BehaviorSubject<String>(value: "")
    private let postSubmittedSubject = PublishSubject<Void>()

    init(image: UIImage) {
        self.imageSubject = BehaviorSubject(value: image)
    }
    
    func updatePostText(_ text: String) {
            postTextViewSubject.onNext(text)
        }
    
    func transform(input: Input) -> Output {
        input.submitTap
            .flatMapLatest { [weak self] _ -> Observable<[String]> in
                guard let self = self, let imageData = try? self.imageSubject.value().pngData() else {
                    return Observable.just([])
                }
                let uploadQuery = UploadImageQuery(files: imageData)
                return NetworkManager.performMultipartRequest(route: .uploadFile(query: uploadQuery))
                    .asObservable()
                    .map { $0.files }
            }
            .flatMapLatest { [weak self] files -> Observable<Void> in
                guard let self = self, let text = try? self.postTextViewSubject.value() else {
                    return Observable.just(())
                }
                return Permissions.shared.currentLocationObservable()
                    .flatMap { location -> Observable<Void> in
                        let latitude = location.coordinate.latitude.description
                        let longitude = location.coordinate.longitude.description
                        let query = UploadPostQuery(content: text, content1: latitude, content2: longitude, files: files, product_id: "ker0r0")
                        return NetworkManager.performRequest(route: .uploadPost(query: query), dataType: UploadPostModel.self)
                            .asObservable()
                            .map { _ in () }
                    }
            }
            .subscribe(onNext: { [weak self] _ in
                NotificationCenter.default.post(name: .postUploaded, object: nil)
                self?.postSubmittedSubject.onNext(())
            }, onError: { error in
                // 오류 처리
                print("Error uploading post: \(error)")
            })
            .disposed(by: disposeBag)

        return Output(
            postSubmitted: postSubmittedSubject.asObservable(),
            image: imageSubject.asObservable()
        )
    }


}

extension Notification.Name {
    static let postUploaded = Notification.Name("postUploaded")
}
