//
//  CustomButton.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import UIKit
import SnapKit
import Then

class CustomButton: UIControl {

    private let iconImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.image = UIImage(systemName: "storefront")?.withRenderingMode(.alwaysOriginal).withTintColor(.lightGray)
        $0.tintColor = .white
        $0.backgroundColor = .offWhite
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
    }

    private let priceLabel = UILabel().then {
        $0.text = "990원 한끼통살"
        $0.textColor = .white
        $0.font = UIFont.systemFont(ofSize: 14)
        $0.numberOfLines = 1
    }
    
    private let moreInfoView = UIView().then {
        $0.backgroundColor = .offWhite
        $0.layer.cornerRadius = 5
    }

    private let moreInfoLabel = UILabel().then {
        $0.text = "더 알아보기"
        $0.textColor = .darkGray
        $0.font = .boldSystemFont(ofSize: 14)
    }

    private let chevronImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(systemName: "chevron.right")
        $0.tintColor = .black
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        self.backgroundColor = UIColor.black.withAlphaComponent(0.4)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    }

    private func setupViews() {
        
        // 뷰 추가
        addSubview(iconImageView)
        addSubview(priceLabel)
        addSubview(moreInfoView)
        moreInfoView.addSubview(moreInfoLabel)
        moreInfoView.addSubview(chevronImageView)
        
        self.layer.cornerRadius = 10
            self.clipsToBounds = true

        // 아이콘 레이아웃
        iconImageView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(12)
            $0.size.equalTo(40)
        }

        // 가격 레이블 레이아웃
        priceLabel.snp.makeConstraints {
            $0.leading.equalTo(iconImageView.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(8)
            $0.centerY.equalTo(iconImageView)
        }
        
        
        moreInfoView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview().inset(12)
            $0.height.equalTo(36)
        }

        // 더 알아보기 뷰 레이아웃
        moreInfoLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(8)
        }

        // Chevron 아이콘 레이아웃
        chevronImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(8)
        }
    }
}

extension CustomButton {
    func updatePriceLabel(price: String) {
            DispatchQueue.main.async {
                self.priceLabel.text = price
            }
        }

    func updateIconImageView(with url: URL) {
        print("iconimageurl: \(url)")
        
        iconImageView.loadImage(from: url)
    }
}
