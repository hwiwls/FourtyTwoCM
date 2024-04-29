//
//  IconBtn.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/21/24.
//

import UIKit

class IconButton: UIButton {
    
    init(image: String) {
        super.init(frame: .zero)

        var config = UIButton.Configuration.plain()
        config.image = UIImage(systemName: image)?
            .withRenderingMode(.alwaysOriginal)
            .withTintColor(.offWhite)
        config.imagePadding = 0
        
        config.baseForegroundColor = .offWhite
        config.baseBackgroundColor = .clear

        self.configuration = config
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}


