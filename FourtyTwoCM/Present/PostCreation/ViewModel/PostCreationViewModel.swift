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
import ImageIO

final class PostCreationViewModel: ViewModelType {
    var disposeBag = DisposeBag()
    
    private let imageSubject: BehaviorSubject<UIImage>
    private let postTextViewSubject = BehaviorSubject<String>(value: "")
    private let postSubmittedSubject = PublishSubject<Void>()
    private let errorMessageSubject = PublishSubject<String>()
    
    struct Input {
        let submitTap: Observable<Void>
    }
    
    struct Output {
        let postSubmitted: Observable<Void>
        let image: Observable<UIImage>
        let errorMessage: Observable<String>
    }
    
    init(image: UIImage) {
        self.imageSubject = BehaviorSubject(value: image)
    }
    
    func updatePostText(_ text: String) {
        postTextViewSubject.onNext(text)
    }
    
    func transform(input: Input) -> Output {
        input.submitTap
            .flatMapLatest { [weak self] _ -> Observable<[String]> in
                guard let self = self else { return Observable.just([]) }
                return self.uploadImage()
            }
            .flatMapLatest { [weak self] files -> Observable<Void> in
                guard let self = self else { return Observable.just(()) }
                return self.submitPost(with: files)
            }
            .subscribe(onNext: { [weak self] _ in
                self?.postSubmittedSubject.onNext(())
            }, onError: { [weak self] error in
                self?.errorMessageSubject.onNext((error as? APIError)?.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
            })
            .disposed(by: disposeBag)

        return Output(
            postSubmitted: postSubmittedSubject.asObservable(),
            image: imageSubject.asObservable(),
            errorMessage: errorMessageSubject.asObservable()
        )
    }

    private func uploadImage() -> Observable<[String]> {
        guard let image = try? imageSubject.value() else {
            return Observable.just([])
        }
        
        let targetSize = CGSize(width: 2556, height: 1179) // 해상도
        guard let resizedImage = image.resizedImage(targetSize: targetSize), let compressedData = resizedImage.compressedData(targetSizeInKB: 3000) else {   // 용량. 3000KB
            print("이미지 압축 실패")
            errorMessageSubject.onNext("이미지 압축 실패")
            return Observable.just([])
        }
        
        print("압축된 이미지 용량: \(compressedData.count) bytes")
        let uploadQuery = UploadImageQuery(files: compressedData)
        return NetworkManager.performMultipartRequest(route: .uploadFile(query: uploadQuery))
            .asObservable()
            .map { $0.files }
            .catch { [weak self] error in
                self?.errorMessageSubject.onNext((error as? APIError)?.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                return Observable.just([])
            }
    }

    private func submitPost(with files: [String]) -> Observable<Void> {
        guard let text = try? postTextViewSubject.value() else {
            return Observable.just(())
        }
        return Permissions.shared.currentLocationObservable()
            .flatMap { [weak self] location -> Observable<Void> in
                let latitude = location.coordinate.latitude.description
                let longitude = location.coordinate.longitude.description
                let query = UploadPostQuery(content: text, content1: latitude, content2: longitude, files: files, product_id: "ker0r0")
                return NetworkManager.performRequest(route: .uploadPost(query: query), dataType: UploadPostModel.self)
                    .asObservable()
                    .map { _ in () }
                    .catch { [weak self] error in
                        self?.errorMessageSubject.onNext((error as? APIError)?.errorMessage ?? "알 수 없는 오류가 발생했습니다.")
                        return Observable.just(())
                    }
            }
    }
}
