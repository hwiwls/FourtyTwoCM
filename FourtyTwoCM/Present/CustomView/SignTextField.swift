//
//  SignTextField.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import UIKit

class SignTextField: UITextField {
    
    init(placeholderText: String) {
        super.init(frame: .zero)
        
        textColor = .white
        placeholder = placeholderText
        textAlignment = .left
        borderStyle = .none
        backgroundColor = .superDarkGray
        layer.cornerRadius = 5
        let placeholderAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: UIColor.placeHolderGray,
            .font: UIFont.systemFont(ofSize: 14)
        ]
        attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: placeholderAttributes)
        
        
        addLeftPadding()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}

