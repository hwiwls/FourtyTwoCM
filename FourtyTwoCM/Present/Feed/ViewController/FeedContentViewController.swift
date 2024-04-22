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
    private let viewModel = FeedContentViewModel()
    
    private let postProgressbar = UIProgressView(progressViewStyle: .bar).then {
        $0.trackTintColor = .unactiveGray
        $0.progressTintColor = .offWhite
        $0.progress = 0.5
    }
    
    private let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(named: "SampleImg1")
        $0.backgroundColor = .white
    }
    
    private let postShadowView = GradientView()
    
    private let userProfileIamgeView = UIImageView().then {
        $0.image = UIImage(named: "SampleProfileImg")
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
        userProfileIamgeView.layer.cornerRadius = userProfileIamgeView.frame.height / 2
        userProfileIamgeView.clipsToBounds = true
    }
    
    override func configHierarchy() {
        view.addSubviews([
            postImageView,
            postProgressbar,
            postShadowView,
            userProfileIamgeView,
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
            $0.leading.trailing.equalTo(view.safeAreaLayoutGuide).inset(20)
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
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
            $0.trailing.equalTo(btnStackView.snp.leading).offset(-12)
        }
        
        btnStackView.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview().inset(20)
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
        
        userProfileIamgeView.snp.makeConstraints {
            $0.width.height.equalTo(40)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalTo(postContentLabel.snp.top).offset(-12)
        }
        
        userIDLabel.snp.makeConstraints {
            $0.leading.equalTo(userProfileIamgeView.snp.trailing).offset(8)
            $0.centerY.equalTo(userProfileIamgeView)
        }
        
        
    }
    

}