//
//  GenericTableViewCell.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import UIKit

class GenericTableViewCell: UITableViewCell {

    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        $0.image = UIImage(named: "defaultprofile")
    }
    
    private let nicknameLabel = UILabel().then {
        $0.font = UIFont.boldSystemFont(ofSize: 16)
        $0.textColor = .offWhite
        $0.text = "알 수 없음"
    }
    
    private let contentLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.textColor = .offWhite
        $0.numberOfLines = 0
        $0.text = "알 수 없음"
    }
    
    private let timeLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 11)
        $0.textColor = .offWhite
        $0.text = "n시간 전"
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
            contentLabel,
            timeLabel
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
        
        timeLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(profileImageView.snp.top)
        }
    }
    
    func configure(with comment: Comment) {
        nicknameLabel.text = comment.creator.nick
        contentLabel.text = comment.content
        timeLabel.text = comment.createdAt.toISO8601Date()?.toRelativeString()
        if let profileImageUrl = comment.creator.profileImage, let url = URL(string: BaseURL.baseURL.rawValue + "/" + profileImageUrl) {
            profileImageView.loadImage(from: url)
            print("댓글창 프로필 이미지 url: \(url)")
        } else {
            profileImageView.image = UIImage(named: "defaultprofile")
        }
    }
    
    func configure(with participants: [Participant], lastChat: LastChat?, updatedAt: String) {
        let userID = UserDefaults.standard.string(forKey: "userID") ?? ""
        
        // userID와 다른 participant 찾기
        let otherParticipant = participants.first { $0.userID != userID }
        
        nicknameLabel.text = otherParticipant?.nick ?? "알 수 없음"
        contentLabel.text = lastChat?.content ?? "알 수 없음"
        timeLabel.text = updatedAt.toISO8601Date()?.toRelativeString()
        
        if let profileImageUrl = otherParticipant?.profileImage, let url = URL(string: BaseURL.baseURL.rawValue + "/" + profileImageUrl) {
            profileImageView.loadImage(from: url)
        } else {
            profileImageView.image = UIImage(named: "defaultprofile")
        }
    }
}

