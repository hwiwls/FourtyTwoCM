//
//  UIColor+CustomColor.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/13/24.
//

import UIKit

extension UIColor {
    static let customColor = CustomColors()
    
    struct CustomColors {
        let offWhiteColor = UIColor(named: "OffWhiteColor") ?? .white
        
        let placeHolderGray = UIColor(named: "PlaceHolderGray") ?? .white
        
        let superDarkGray = UIColor(named: "SuperDarkGray") ?? .white
        
        let backgroundBlack = UIColor(named: "BackgroundBlack") ?? .white
    }
}
