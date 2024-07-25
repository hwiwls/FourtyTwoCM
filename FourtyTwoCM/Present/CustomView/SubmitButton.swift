//
//  SubmitButton.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/18/24.
//

import UIKit

class SubmitButton: UIButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupButton()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupButton()
    }

    private func setupButton() {
        setImage(UIImage(systemName: "arrow.up")?.withRenderingMode(.alwaysOriginal).withTintColor(.black), for: .normal)
        titleLabel?.font = .boldSystemFont(ofSize: 16)
        backgroundColor = .offWhite
        layer.cornerRadius = 15
        clipsToBounds = true
    }
}
