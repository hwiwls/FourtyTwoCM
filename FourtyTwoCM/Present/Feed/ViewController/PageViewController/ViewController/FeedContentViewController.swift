//
//  FeedContentViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

final class FeedContentViewController: BaseViewController {
    
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
        $0.image = UIImage(named: "")
        $0.backgroundColor = .red
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        userProfileImageView.layer.cornerRadius = userProfileImageView.frame.height / 2
        userProfileImageView.clipsToBounds = true
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
    
    func loadPost(post: Post) {
        self.postContentLabel.text = post.content
        self.userIDLabel.text = post.creator.nick
    
        let baseURL = BaseURL.baseURL.rawValue
    
        if let profileImageUrl = post.creator.profileImage {
            let url = URL(string: baseURL + "/" + profileImageUrl)!
            print("프로필이미지 url: \(String(describing: url))")
            self.userProfileImageView.loadImage(from: url)
        }

        if let firstFile = post.files.first {
            let url = URL(string: baseURL + "/" + firstFile)!
            print("프로필이미지 url: \(String(describing: url))")
            self.postImageView.loadImage(from: url)
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
            $0.top.equalToSuperview().offset(60)
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
            $0.bottom.equalToSuperview().inset(20)
            $0.trailing.equalTo(btnStackView.snp.leading).offset(-12)
        }
        
        btnStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        likePostBtn.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        savePostBtn.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        commentPostBtn.snp.makeConstraints {
            $0.size.equalTo(30)
        }
        
        ellipsisPostBtn.snp.makeConstraints {
            $0.size.equalTo(30)
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
        
        
    }
    

}
