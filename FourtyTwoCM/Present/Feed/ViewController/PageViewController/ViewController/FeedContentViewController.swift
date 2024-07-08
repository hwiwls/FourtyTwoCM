//
//  FeedContentViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class FeedContentViewController: BaseViewController {
    var viewModel: FeedContentViewModel!

    private let postProgressbar = UIProgressView(progressViewStyle: .bar).then {
        $0.trackTintColor = .unactiveGray
        $0.progressTintColor = .offWhite
        $0.progress = 0.0
    }
    
    let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "SampleImg1")
        $0.backgroundColor = .white
    }
    
    private let postShadowView = GradientView()
    
    private let userProfileImageView = UIImageView().then {
        $0.image = UIImage(named: "defaultprofile")
        $0.backgroundColor = .borderGray
        $0.contentMode = .scaleAspectFill
    }
    
    private let userIDLabel = UILabel().then {
        $0.text = "shinyu"
        $0.textColor = .offWhite
        $0.font = .boldSystemFont(ofSize: 16)
    }
    
    private let postContentLabel = UILabel().then {
        $0.text = "연남 프로토콜 오늘 사람 없어서 작업하기 너무 좋다,,, 오실 분들은 오늘 오셔야 합니다 !"
        $0.numberOfLines = 0
        $0.textColor = .offWhite
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .left
        $0.setLineSpacing(lineSpacing: 3)
    }
    
    private let btnStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.axis = .vertical
        $0.spacing = 20
    }
    
    private let likePostBtn = IconButton(image: "heart")
    
    private let savePostBtn = IconButton(image: "bookmark")
    
    private let commentPostBtn = IconButton(image: "message")
    
    private let ellipsisPostBtn = IconButton(image: "ellipsis")
    
    let goReservationBtn = CustomButton()
    
    private let followBtn = UIButton().then {
        $0.setTitle("팔로우", for: .normal)
        $0.setTitleColor(.offWhite, for: .normal)
        $0.backgroundColor = .clear
        $0.layer.borderColor = UIColor.offWhite.cgColor
        $0.layer.cornerRadius = 5
        $0.layer.masksToBounds = true
        $0.titleLabel?.font = .boldSystemFont(ofSize: 11)
        $0.layer.borderWidth = 0.5
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        goReservationBtn.addTarget(self, action: #selector(goReservationButtonTapped), for: .touchUpInside)
    }
    
    @objc func goReservationButtonTapped() {
        guard let post = try? viewModel.post.value() else { return }

        
        let reservationVC = ReservationViewController()
        reservationVC.modalPresentationStyle = .overFullScreen
        
        reservationVC.storeName = post.creator.nick
        reservationVC.productDetail = post.content
        reservationVC.productName = post.content4
        reservationVC.priceValue = post.content5
        reservationVC.imageUrls = post.files
        reservationVC.postID = post.postID
        if let tabBar = self.tabBarController {
            
            tabBar.present(reservationVC, animated: true, completion: nil)
        } else {
            self.present(reservationVC, animated: true, completion: nil)
        }
    }

    
    override func viewDidLayoutSubviews() {
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height / 2
        userProfileImageView.clipsToBounds = true
    }
    
    
    func loadPost(post: Post) {
        viewModel = FeedContentViewModel(post: post)
       
    }

    override func bind() {
        guard let viewModel = viewModel else { return }

        let input = FeedContentViewModel.Input(
            viewDidLoadTrigger: .just(()),
            likeBtnTapped: likePostBtn.rx.tap.asObservable(),
            ellipsisBtnTapped: ellipsisPostBtn.rx.tap.asObservable(),
            followBtnTapped: followBtn.rx.tap.asObservable(),
            commentPostBtnTapped: commentPostBtn.rx.tap.asObservable()
        )
        
        let output = viewModel.transform(input: input)
        
        viewModel.isLiked
            .asDriver(onErrorJustReturn: false)
            .drive(onNext: { [weak self] isLiked in
                self?.updateLikeButton(isLiked: isLiked)
            })
            .disposed(by: disposeBag)
        
        output.content
            .drive(postContentLabel.rx.text)
            .disposed(by: disposeBag)

        output.nickname
            .drive(userIDLabel.rx.text)
            .disposed(by: disposeBag)

        output.profileImageUrl
            .compactMap { URL(string: $0 ?? "") }
            .drive(onNext: { [weak self] url in
                print("feed url: \(url)")
                self?.userProfileImageView.loadImage(from: url)
            })
            .disposed(by: disposeBag)

        output.postImageUrl
            .compactMap { URL(string: $0 ?? "") }
            .drive(onNext: { [weak self] url in
                self?.postImageView.loadImage(from: url)
            })
            .disposed(by: disposeBag)
        

        output.likeStatus
            .drive(onNext: { [weak self] isLiked in
                self?.updateLikeButton(isLiked: isLiked)
            })
            .disposed(by: disposeBag)

        output.ellipsisVisibility
            .drive(ellipsisPostBtn.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.likeButtonImage
            .drive(onNext: { [weak self] imageName in
                self?.likePostBtn.setImage(UIImage(systemName: imageName), for: .normal)
            })
            .disposed(by: disposeBag)
        
        output.showActionSheet
            .drive(onNext: { [weak self] _ in
                self?.showActionSheet()
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .asDriver(onErrorJustReturn: "")
            .drive(onNext: { [weak self] message in
                self?.showToast(message: message)
            })
            .disposed(by: disposeBag)
        
        output.goReservationVisibility
               .drive(goReservationBtn.rx.isHidden)
               .disposed(by: disposeBag)
        
        output.formattedPrice
            .drive(onNext: { [weak self] price in
                self?.goReservationBtn.updatePriceLabel(price: price)
            })
            .disposed(by: disposeBag)

        output.imageUrls
            .drive(onNext: { [weak self] urls in
                if let firstUrl = urls.first, let url = URL(string: BaseURL.baseURL.rawValue + "/" + firstUrl) {
                    self?.goReservationBtn.updateIconImageView(with: url)
                }
            })
            .disposed(by: disposeBag)
        
        output.followState
            .drive(onNext: { [weak self] isFollowing in
                self?.followBtn.setTitle(isFollowing ? "팔로잉" : "팔로우", for: .normal)
            })
            .disposed(by: disposeBag)

        output.isFollowButtonHidden
            .drive(followBtn.rx.isHidden)
            .disposed(by: disposeBag)
        
        output.comments
            .drive(onNext: { [weak self] comments in
                guard let self = self else { return }
                let commentsVC = CommentViewController()
                commentsVC.viewModel = CommentViewModel(postId: self.viewModel.currentPostId ?? "") 
                commentsVC.comments.onNext(comments)
                commentsVC.modalPresentationStyle = .overFullScreen
                self.present(commentsVC, animated: true, completion: nil)
            })
            .disposed(by: disposeBag)
    }
    
    private func showToast(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        self.present(alert, animated: true, completion: nil)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showActionSheet() {
        guard let postID = viewModel.currentPostId else { return }

        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.confirmDeletion(postID: postID)
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    private func updateLikeButton(isLiked: Bool) {
        let imageName = isLiked ? "heart.fill" : "heart"
        likePostBtn.setImage(UIImage(systemName: imageName), for: .normal)
    }
    
    func updateProgressBar(progress: Float) {
        if progress == 0 {
            postProgressbar.progress = 0
        } else {
            UIView.animate(withDuration: 7.0, animations: { [weak self] in
                self?.postProgressbar.setProgress(1.0, animated: true)
            })
        }
    }
    
    override func configHierarchy() {
        view.addSubviews([
            postImageView,
            postProgressbar,
            postShadowView,
            userProfileImageView,
            userIDLabel,
            postContentLabel,
            btnStackView,
            goReservationBtn,
            followBtn
        ])
        
        btnStackView.addArrangedSubviews([
            likePostBtn,
            savePostBtn,
            commentPostBtn,
            ellipsisPostBtn
        ])
    }
    
    override func configLayout() {
        postProgressbar.snp.makeConstraints {
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(12)
            $0.top.equalToSuperview().offset(58)
        }
        
        postImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        postShadowView.snp.makeConstraints {
            $0.leading.bottom.trailing.equalToSuperview()
            $0.height.equalTo(300)
        }
        
        postContentLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(28)
            $0.trailing.equalTo(btnStackView.snp.leading).offset(-12)
        }
        
        btnStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalTo(postContentLabel.snp.bottom).offset(-4)
            $0.width.equalTo(40)
        }
        
        likePostBtn.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        savePostBtn.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        commentPostBtn.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        ellipsisPostBtn.snp.makeConstraints {
            $0.size.equalTo(40)
        }
        
        userProfileImageView.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.leading.equalToSuperview().offset(16)
            $0.bottom.equalTo(postContentLabel.snp.top).offset(-12)
        }
        
        userIDLabel.snp.makeConstraints {
            $0.leading.equalTo(userProfileImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(userProfileImageView)
        }
        
        goReservationBtn.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.bottom.equalTo(userProfileImageView.snp.top).offset(-20)
            $0.height.equalTo(120)
            $0.trailing.equalTo(btnStackView.snp.leading).offset(-20)
        }
        
        followBtn.snp.makeConstraints {
            $0.leading.equalTo(userIDLabel.snp.trailing).offset(12)
            $0.top.bottom.equalTo(userIDLabel)
            $0.width.equalTo(48)
            $0.height.equalTo(24)
        }
    }
}
