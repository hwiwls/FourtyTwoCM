//
//  CustomTabBar.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import UIKit

final class CustomTabBar: UITabBar {
    let middleButton = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60)).then {
        $0.backgroundColor = .offWhite
        $0.layer.cornerRadius = 30
        $0.setImage(UIImage(systemName: "plus")?.withTintColor(.black, renderingMode: .alwaysOriginal), for: .normal)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let tabBarHeight = frame.height
        // 위치를 5픽셀 더 높게 조정
        middleButton.center = CGPoint(x: frame.width / 2, y: tabBarHeight / 2 - 20)
        addSubview(middleButton)
    }
}

