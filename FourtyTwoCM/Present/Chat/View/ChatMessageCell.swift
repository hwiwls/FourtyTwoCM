//
//  ChatMessageCell.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/15/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa

class ChatMessageCell: BaseTableViewCell {
    
    static let identifier = "ChatMessageCell"
    
    let bubbleBackgroundView = UIView().then {
        $0.layer.cornerRadius = 18
        $0.clipsToBounds = true
    }
    
    let messageLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = .systemFont(ofSize: 17)
        $0.textColor = .offWhite
    }
    
    private let disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: ChatMessage, isOutgoing: Bool) {
        messageLabel.text = message.content
        updateUI(isOutgoing: isOutgoing)
    }
    
    override func configHierarchy() {
        contentView.addSubviews([
            bubbleBackgroundView,
            messageLabel
        ])
    }
    
    override func configLayout() {
        bubbleBackgroundView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(4)
            $0.width.lessThanOrEqualTo(300)
        }
        
        messageLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(bubbleBackgroundView).inset(12)
            $0.top.bottom.equalTo(bubbleBackgroundView).inset(8)
        }
    }
    
    private func updateUI(isOutgoing: Bool) {
        bubbleBackgroundView.backgroundColor = isOutgoing ? .systemBlue : .superDarkGray
        
        if isOutgoing {
            bubbleBackgroundView.snp.remakeConstraints {
                $0.trailing.equalToSuperview().inset(24)
                $0.top.bottom.equalToSuperview().inset(4)
                $0.width.lessThanOrEqualTo(300)
            }
        } else {
            bubbleBackgroundView.snp.remakeConstraints {
                $0.leading.equalToSuperview().inset(24)
                $0.top.bottom.equalToSuperview().inset(4)
                $0.width.lessThanOrEqualTo(300)
            }
        }
        
        messageLabel.snp.remakeConstraints {
            $0.leading.trailing.equalTo(bubbleBackgroundView).inset(12)
            $0.top.bottom.equalTo(bubbleBackgroundView).inset(8)
        }
    }
}
