//
//  BaseView.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit

class BaseCollectionView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
        setHierarchy()
        setConstraints()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setHierarchy() { }
    func configure() { }
    func setConstraints() { }
}
