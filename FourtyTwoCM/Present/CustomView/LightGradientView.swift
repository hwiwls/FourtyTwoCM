//
//  LightGradientView.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/14/24.
//

import UIKit

class LightGradientView: UIView {
    override open class var layerClass: AnyClass {
       return CAGradientLayer.classForCoder()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGradient()
    }

    private func setupGradient() {
        guard let gradientLayer = self.layer as? CAGradientLayer else { return }
        
        // Define the colors of the gradient
        let topColor = UIColor.black.withAlphaComponent(0.1) // Lighter black at the top
        let bottomColor = UIColor.black.withAlphaComponent(0.8) // Darker black at the bottom

        // Assign the colors and their locations
        gradientLayer.colors = [topColor.cgColor, bottomColor.cgColor]
        gradientLayer.locations = [0.0, 1.0] // From top (0%) to bottom (100%)
        
        // Set the direction of the gradient
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // Start at the top middle
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0) // End at the bottom middle
    }
}
