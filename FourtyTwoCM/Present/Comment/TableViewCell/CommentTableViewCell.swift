//
//  CommentTableViewCell.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import UIKit
import SnapKit

final class CommentTableViewCell: UITableViewCell {
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = .offWhite
    }
    
    private let contentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .offWhite
        $0.numberOfLines = 0
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupViews() {
        addSubviews([
            profileImageView,
            nicknameLabel,
            contentLabel
        ])
        
        profileImageView.snp.makeConstraints {
            $0.size.equalTo(40)
            $0.top.equalToSuperview().offset(12)
            $0.leading.equalToSuperview().offset(20)
        }
        
        nicknameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
        }
        
        contentLabel.snp.makeConstraints {
            $0.top.equalTo(nicknameLabel.snp.bottom).offset(8)
            $0.trailing.equalToSuperview().inset(20)
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    func configure(with comment: Comment) {
        nicknameLabel.text = comment.creator.nick
        contentLabel.text = comment.content
        if let profileImageUrl = comment.creator.profileImage, let url = URL(string: BaseURL.baseURL.rawValue + "/" + profileImageUrl) {
            profileImageView.loadImage(from: url)
            print("댓글창 프로필 이미지 url: \(url)")
        } else {
            profileImageView.image = UIImage(named: "defaultprofile")
        }
    }
}
