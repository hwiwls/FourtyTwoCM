//
//  PointButton.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/16/24.
//

import UIKit

class PointButton: UIButton {
    
    init(title: String) {
        super.init(frame: .zero)
        
        setTitle(title, for: .normal)
        setTitleColor(.black, for: .normal)
        backgroundColor = .offWhite
        layer.cornerRadius = 10
        titleLabel?.font = .aggro.aggroMedium18
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

