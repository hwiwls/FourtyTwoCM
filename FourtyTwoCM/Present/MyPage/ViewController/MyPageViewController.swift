//
//  MyPageViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/15/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

final class MyPageViewController: BaseViewController {
    
    private let viewModel = MyPageViewModel()
    
    var myPageTabmanController: MyPageTabmanViewController!
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 40
        $0.image = UIImage(systemName: "person.fill")
    }
    
    private let usernameLabel = UILabel().then {
        $0.text = "shinyu"
        $0.textColor = .offWhite
        $0.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        $0.textAlignment = .center
    }
    
    private let followerLabel = UILabel().then {
        $0.text = "0 follower"
        $0.textColor = .offWhite
        $0.font = .aggro.aggroLight15
        $0.textAlignment = .center
    }
    
    private let borderlabel = UILabel().then {
        $0.text = "|"
        $0.textColor = .offWhite
        $0.font = .aggro.aggroLight15
        $0.textAlignment = .center
    }
    
    private let followingLabel = UILabel().then {
        $0.text = "0 following"
        $0.textColor = .offWhite
        $0.font = .aggro.aggroLight15
        $0.textAlignment = .center
    }
    
    private let editBtn = UIButton().then {
        $0.backgroundColor = UIColor.offWhite
        $0.setTitle(".edit", for: .normal)
        $0.setTitleColor(.black, for: .normal)
        $0.titleLabel?.font = .aggro.aggroMedium13
        $0.layer.cornerRadius = 5
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func bind() {
        let input = MyPageViewModel.Input(loadProfileTrigger: .just(()))
        let output = viewModel.transform(input: input)
                
        output.profileImageURL
            .drive(onNext: { [weak self] url in
                if let urlString = url?.absoluteString, let url = URL(string: BaseURL.baseURL.rawValue + "/" + urlString) {
                    print("mypage url: \(url)")
                    self?.profileImageView.loadImage(from: url, placeHolderImage: UIImage(named: "defaultprofile"))
                } else {
                    self?.profileImageView.image = UIImage(named: "defaultprofile")
                }
            })
            .disposed(by: disposeBag)

                
        output.username
            .drive(usernameLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.followerCount
            .drive(followerLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.followingCount
            .drive(followingLabel.rx.text)
            .disposed(by: disposeBag)
        
        output.error
            .drive(onNext: { error in
                print("An error occurred: \(error.localizedDescription)")
            })
            .disposed(by: disposeBag)
    }
    
    override func configView() {
        myPageTabmanController = MyPageTabmanViewController()
        addChild(myPageTabmanController)
        view.addSubview(myPageTabmanController.view)
        myPageTabmanController.didMove(toParent: self)

        myPageTabmanController.view.translatesAutoresizingMaskIntoConstraints = false
    }
    
    override func configHierarchy() {
        view.addSubviews([
            profileImageView,
            usernameLabel,
            followerLabel,
            borderlabel,
            followingLabel,
            editBtn
        ])
    }
    
    override func configLayout() {
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.width.height.equalTo(80)
        }
        
        usernameLabel.snp.makeConstraints {
            $0.top.equalTo(profileImageView.snp.bottom).offset(12)
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        followerLabel.snp.makeConstraints {
            $0.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
            $0.top.equalTo(usernameLabel.snp.bottom).offset(10)
        }
        
        borderlabel.snp.makeConstraints {
            $0.top.equalTo(followerLabel)
            $0.leading.equalTo(followerLabel.snp.trailing).offset(8)
        }
        
        followingLabel.snp.makeConstraints {
            $0.top.equalTo(usernameLabel.snp.bottom).offset(10)
            $0.leading.equalTo(borderlabel.snp.trailing).offset(8)
        }
        
        editBtn.snp.makeConstraints {
            $0.top.equalTo(usernameLabel)
            $0.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(28)
            $0.width.equalTo(68)
        }
        
        myPageTabmanController.view.snp.makeConstraints {
            $0.top.equalTo(followingLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalTo(view)
            $0.bottom.equalTo(view.safeAreaLayoutGuide)
        }
    }

    
}
