//
//  d.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/24/24.
//

import UIKit
import SnapKit

final class PostDetailView: BaseView {
    private let imageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }
    
    private let quoteOpenImageView = UIImageView().then {
        $0.image = UIImage(named: "quotes_icon_open")
        $0.contentMode = .scaleAspectFit
    }
    
    private let postContentLabel = UILabel().then {
        $0.textColor = .black
        $0.numberOfLines = 4
        $0.font = .systemFont(ofSize: 15)
        $0.textAlignment = .left
    }
    
    private let quotesCloseImageView = UIImageView().then {
        $0.image = UIImage(named: "quotes_icon_close")
        $0.contentMode = .scaleAspectFit
    }
    
    private let createdAtLabel = UILabel().then {
        $0.textColor = .placeHolderGray
        $0.font = .systemFont(ofSize: 12)
        $0.textAlignment = .right
    }
    
    private let creatorLabel = UILabel().then {
        $0.textColor = .black
        $0.font = .systemFont(ofSize: 14)
        $0.textAlignment = .right
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func configHierarchy() {
        addSubviews([
            imageView,
            quoteOpenImageView,
            postContentLabel,
            quotesCloseImageView,
            createdAtLabel,
            creatorLabel
        ])
    }
    
    override func configLayout() {
        imageView.snp.makeConstraints {
            $0.top.leading.bottom.equalToSuperview().inset(16)
            $0.width.equalTo(100)
        }
        
        quoteOpenImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(12)
            $0.leading.equalTo(imageView.snp.trailing).offset(16)
            $0.size.equalTo(20)
        }

        postContentLabel.snp.makeConstraints {
            $0.top.equalTo(quoteOpenImageView.snp.bottom)
            $0.leading.equalTo(quoteOpenImageView.snp.trailing).offset(-4)
            $0.trailing.equalToSuperview().inset(20)
        }
        
        quotesCloseImageView.snp.makeConstraints {
            $0.top.equalTo(postContentLabel.snp.bottom)
            $0.trailing.equalToSuperview().inset(16)
            $0.size.equalTo(20)
        }

        createdAtLabel.snp.makeConstraints {
            $0.top.equalTo(quotesCloseImageView.snp.bottom).offset(8)
            $0.leading.equalTo(postContentLabel)
            $0.trailing.equalToSuperview().inset(16)
        }

        creatorLabel.snp.makeConstraints {
            $0.top.equalTo(createdAtLabel.snp.bottom).offset(4)
            $0.leading.equalTo(postContentLabel)
            $0.trailing.equalToSuperview().inset(16)
        }
    }

    func configure(with post: Post) {
        postContentLabel.text = post.content
        createdAtLabel.text = post.createdAt
        creatorLabel.text = "by @\(post.creator.nick)"

        if let imageUrlString = post.files.first, let imageUrl = URL(string: "\(BaseURL.baseURL.rawValue)/\(imageUrlString)") {
            imageView.loadImage(from: imageUrl)
        } else {
            imageView.image = UIImage(named: "placeholder")
        }
    }
}
