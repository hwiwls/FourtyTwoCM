//
//  UIFont+Suit.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/15/24.
//

import UIKit

extension UIFont {
    static let aggro = Aggro()
    
    struct Aggro {
        // Light
        let aggroLight12 = UIFont(name: AggroStyle.light.name, size: 12)
        let aggroLight13 = UIFont(name: AggroStyle.light.name, size: 13)
        let aggroLight14 = UIFont(name: AggroStyle.light.name, size: 14)
        let aggroLight15 = UIFont(name: AggroStyle.light.name, size: 15)
        let aggroLight16 = UIFont(name: AggroStyle.light.name, size: 16)
        let aggroLight18 = UIFont(name: AggroStyle.light.name, size: 18)
        let aggroLight20 = UIFont(name: AggroStyle.light.name, size: 20)
        
        // Medium
        let aggroMedium12 = UIFont(name: AggroStyle.medium.name, size: 12)
        let aggroMedium13 = UIFont(name: AggroStyle.medium.name, size: 13)
        let aggroMedium14 = UIFont(name: AggroStyle.medium.name, size: 14)
        let aggroMedium15 = UIFont(name: AggroStyle.medium.name, size: 15)
        let aggroMedium16 = UIFont(name: AggroStyle.medium.name, size: 16)
        let aggroMedium18 = UIFont(name: AggroStyle.medium.name, size: 18)
        let aggroMedium20 = UIFont(name: AggroStyle.medium.name, size: 20)
        let aggroMedium32 = UIFont(name: AggroStyle.medium.name, size: 32)
        
        // Bold
        let aggroBold12 = UIFont(name: AggroStyle.bold.name, size: 12)
        let aggroBold13 = UIFont(name: AggroStyle.bold.name, size: 13)
        let aggroBold14 = UIFont(name: AggroStyle.bold.name, size: 14)
        let aggroBold15 = UIFont(name: AggroStyle.bold.name, size: 15)
        let aggroBold16 = UIFont(name: AggroStyle.bold.name, size: 16)
        let aggroBold18 = UIFont(name: AggroStyle.bold.name, size: 18)
        let aggroBold20 = UIFont(name: AggroStyle.bold.name, size: 20)
    }
    
    enum AggroStyle {
        case light
        case medium
        case bold
        
        var name: String {
            switch self {
            case .light: return "OTSBAggroL"
            case .medium: return "OTSBAggroM"
            case .bold: return "OTSBAggroB"
            }
        }
    }
}
