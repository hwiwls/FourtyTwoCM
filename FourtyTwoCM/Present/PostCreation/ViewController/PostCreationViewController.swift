//
//  PostCreationViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit
import Then

final class PostCreationViewController: BaseViewController {
    var viewModel: PostCreationViewModel!

    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .offWhite
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }

    private let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .red
        $0.clipsToBounds = true
    }
    
    private let contentTitleImageView = UIImageView().then {
        $0.image = UIImage(named: "writelogo")
    }
    
    private let contentTitleLabel = UILabel().then {
        $0.text = "내용"
        $0.textColor = .offWhite
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textAlignment = .left
    }
    
    
    private let postTextView = UITextView().then {
        $0.backgroundColor = .clear
        $0.textColor = .placeHolderGray
        $0.font = .systemFont(ofSize: 15)
        $0.text = "내용, 해시태그를 입력해주세요"
    }
    
    private let uploadBtn = PointButton(title: "Upload")
    

    override func viewDidLoad() {
        super.viewDidLoad()
        print("post creation view controller loaded")
        postTextView.delegate = self
        setupToolbar()
    }
    
    override func bind() {
        let input = PostCreationViewModel.Input(
            submitTap: uploadBtn.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)

        output.image
            .bind(to: postImageView.rx.image)
            .disposed(by: disposeBag)

        output.postSubmitted
            .subscribe(onNext: { [weak self] _ in
                self?.dismiss(animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    
    private func setupToolbar() {
        let toolbar = UIToolbar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 44))
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "확인", style: .plain, target: self, action: #selector(dismissKeyboard))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.setItems([flexibleSpace, doneButton], animated: true)
        
        
        postTextView.inputAccessoryView = toolbar
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    override func configHierarchy() {
        view.addSubviews([
            closeButton,
            postImageView,
            contentTitleImageView,
            contentTitleLabel,
            postTextView,
            uploadBtn
        ])
    }
    
    override func configLayout() {
        closeButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(10)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.size.equalTo(44)
        }
        
        postImageView.snp.makeConstraints {
            $0.width.equalTo(100)
            $0.height.equalTo(170)
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(52)
            $0.centerX.equalToSuperview()
        }
        
        contentTitleImageView.snp.makeConstraints {
            $0.size.equalTo(20)
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(postImageView.snp.bottom).offset(32)
        }
        
        contentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(contentTitleImageView.snp.top)
            $0.height.equalTo(20)
            $0.leading.equalTo(contentTitleImageView.snp.trailing).offset(8)
        }
        
        postTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(18)
            $0.top.equalTo(contentTitleImageView.snp.bottom).offset(8)
            $0.height.equalTo(160)
        }
        
        uploadBtn.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).inset(20)
            $0.height.equalTo(50)
        }
        
    }
    
}

extension PostCreationViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        viewModel.updatePostText(textView.text)  // ViewModel에 텍스트 업데이트 함수 추가 필요
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == .placeHolderGray {
            textView.text = nil
            textView.textColor = .offWhite
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "내용, 해시태그를 입력해주세요"
            textView.textColor = .placeHolderGray
        }
    }
}
