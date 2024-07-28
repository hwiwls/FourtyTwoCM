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
    
    private let imageSubject: BehaviorSubject<UIImage>
    private let postTextRelay = BehaviorRelay<String>(value: "내용, 해시태그를 입력해주세요")
    private let textColorRelay = BehaviorRelay<UIColor>(value: .tabBarBorderGray)
    private let postSubmittedSubject = PublishRelay<Void>()
    private let errorMessageSubject = PublishRelay<String>()
    
    struct Input {
        let submitTap: Observable<Void>
        let textChanged: Observable<String>
        let editingBegan: Observable<Void>
        let editingEnded: Observable<Void>
    }
    
    struct Output {
        let postSubmitted: Driver<Void>
        let image: Driver<UIImage>
        let errorMessage: Driver<String>
        let postText: Driver<String>
        let textColor: Driver<UIColor>
    }
    
    init(image: UIImage) {
        self.imageSubject = BehaviorSubject(value: image)
    }
    
    func transform(input: Input) -> Output {
        input.editingBegan
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.postTextRelay.value == "내용, 해시태그를 입력해주세요" {
                    self.postTextRelay.accept("")
                    self.textColorRelay.accept(.white)
                }
            })
            .disposed(by: disposeBag)

        input.textChanged
            .subscribe(onNext: { [weak self] text in
                guard let self = self else { return }
                if text == "내용, 해시태그를 입력해주세요" {
                    self.textColorRelay.accept(.tabBarBorderGray)
                } else {
                    self.textColorRelay.accept(.white)
                }
                self.postTextRelay.accept(text)
            })
            .disposed(by: disposeBag)

        input.editingEnded
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                if self.postTextRelay.value.isEmpty {
                    self.postTextRelay.accept("내용, 해시태그를 입력해주세요")
                    self.textColorRelay.accept(.tabBarBorderGray)
                }
            })
            .disposed(by: disposeBag)
        
        input.submitTap
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .flatMapLatest { [weak self] _ -> Observable<[String]> in
                guard let self = self else { return Observable.just([]) }
                return self.uploadImage()
            }
            .flatMapLatest { [weak self] files -> Observable<Void> in
                guard let self = self else { return Observable.just(()) }
                return self.submitPost(with: files)
            }
            .subscribe(onNext: {
                self.postSubmittedSubject.accept(())
            }, onError: { error in
                let errorMessage = (error as? APIError)?.errorMessage ?? "알 수 없는 오류가 발생했습니다."
                self.errorMessageSubject.accept(errorMessage)
            })
            .disposed(by: disposeBag)

        return Output(
            postSubmitted: postSubmittedSubject.asDriver(onErrorJustReturn: ()),
            image: imageSubject.asDriver(onErrorDriveWith: .empty()),
            errorMessage: errorMessageSubject.asDriver(onErrorJustReturn: "알 수 없는 오류가 발생했습니다."),
            postText: postTextRelay.asDriver(),
            textColor: textColorRelay.asDriver()
        )
    }

    private func uploadImage() -> Observable<[String]> {
        guard let image = try? imageSubject.value() else {
            return Observable.just([])
        }
        
        let targetSize = CGSize(width: 2556, height: 1179)
        guard let resizedImage = image.resizedImage(targetSize: targetSize), let compressedData = resizedImage.compressedData(targetSizeInKB: 3000) else {
            print("이미지 압축 실패")
            errorMessageSubject.accept("이미지 압축 실패")
            return Observable.just([])
        }
        
        print("압축된 이미지 용량: \(compressedData.count) bytes")
        let uploadQuery = UploadImageQuery(files: compressedData)
        return NetworkManager.performMultipartRequest(route: .uploadFile(query: uploadQuery))
            .asObservable()
            .map { $0.files }
            .catch { [weak self] error in
                let errorMessage = (error as? APIError)?.errorMessage ?? "알 수 없는 오류가 발생했습니다."
                self?.errorMessageSubject.accept(errorMessage)
                return Observable.just([])
            }
    }

    private func submitPost(with files: [String]) -> Observable<Void> {
        guard let text = try? postTextRelay.value else {
            return Observable.just(())
        }
        return Permissions.shared.currentLocationObservable()
            .flatMapLatest { [weak self] location -> Observable<Void> in
                let latitude = location.coordinate.latitude.description
                let longitude = location.coordinate.longitude.description
                let query = UploadPostQuery(content: text, content1: latitude, content2: longitude, files: files, product_id: "ker0r0")
                return NetworkManager.performRequest(route: .uploadPost(query: query), dataType: UploadPostModel.self)
                    .asObservable()
                    .map { _ in () }
                    .catch { [weak self] error in
                        let errorMessage = (error as? APIError)?.errorMessage ?? "알 수 없는 오류가 발생했습니다."
                        self?.errorMessageSubject.accept(errorMessage)
                        return Observable.just(())
                    }
            }
    }
}
