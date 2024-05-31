//
//  BaseView.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit

class BaseView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        configView()
        configHierarchy()
        configLayout()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() {
        
    }
    
    func configHierarchy() {
        
    }
    
    func configLayout() {
        
    }
}
