//
//  SignUpViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit
import SnapKit
import Then

final class SignUpViewController: UIViewController {
    
    let tempLabel = UILabel().then {
        $0.text = ""
        $0.textColor = .white
        $0.font = .aggro.aggroLight16
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .black
        
        view.addSubview(tempLabel)
        tempLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }
    

}
