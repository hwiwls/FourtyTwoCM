//
//  MyPostsCollectionViewCell.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/13/24.
//

import UIKit
import SnapKit

final class PostCollectionViewCell: BaseCollectionViewCell {
    private let postImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let postGradientView = LightGradientView()
    
    private let profileImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.clipsToBounds = true
    }
    
    private let userIdLabel = UILabel().then {
        $0.text = "userId"
        $0.textColor = .white
        $0.font = .boldSystemFont(ofSize: 13)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        postImageView.image = nil
        userIdLabel.text = nil
        profileImageView.image = nil
    }

    override func configView() {
        contentView.layer.cornerRadius = 10
        contentView.clipsToBounds = true
    }
    
    
    override func configHierarchy() {
        contentView.addSubviews([
            postImageView,
            postGradientView,
            profileImageView,
            userIdLabel
        ])
    }
    
    override func configLayout() {
        postImageView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        postGradientView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        profileImageView.snp.makeConstraints {
            $0.leading.bottom.equalToSuperview().inset(8)
            $0.size.equalTo(40)
        }

        userIdLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(8)
            $0.centerY.equalTo(profileImageView.snp.centerY)
            $0.trailing.equalToSuperview().inset(8)
        }
    }
    
    func configure(with post: Post) {
        userIdLabel.text = post.creator.nick

        guard let firstFile = post.files.first,
              let fullImageUrl = URL(string: "\(BaseURL.baseURL.rawValue)/\(firstFile)") else {
            postImageView.image = UIImage(named: "SampleImg1")
            return
        }
        postImageView.loadImage(from: fullImageUrl, placeHolderImage: UIImage(named: "SampleImg1"))

        guard let profileImage = post.creator.profileImage,
              let fullProfileImageUrl = URL(string: "\(BaseURL.baseURL.rawValue)/\(profileImage)") else {
            profileImageView.image = UIImage(named: "SampleProfileImg")
            return
        }
        profileImageView.loadImage(from: fullProfileImageUrl, placeHolderImage: UIImage(named: "SampleProfileImg")) {
            DispatchQueue.main.async {
                self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.width / 2
            }
        }
    }

}

