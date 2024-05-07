//
//  CustomTabBar.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/4/24.
//

import UIKit
//import Then

final class CustomTabBar: UITabBar {
    let middleButton = UIButton(frame: CGRect(x: 0, y: 0, width: 70, height: 70)).then {
        $0.backgroundColor = .black
        $0.layer.cornerRadius = 35 // 버튼의 크기의 절반 값을 주어 동그라미 형태를 만듭니다.
        $0.setImage(UIImage(systemName: "plus")?.withTintColor(.white, renderingMode: .alwaysOriginal), for: .normal)
    }
    
}

