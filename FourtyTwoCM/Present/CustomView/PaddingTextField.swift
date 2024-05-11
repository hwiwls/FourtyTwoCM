//
//  PaddingTextField.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/11/24.
//

import UIKit

class PaddedTextField: UITextField {
    var textInsets: UIEdgeInsets = .zero
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    private func commonInit() {
        autocorrectionType = .no
        autocapitalizationType = .none
        smartDashesType = .no
        smartInsertDeleteType = .no
        smartQuotesType = .no
        spellCheckingType = .no
    }
    

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: textInsets)
    }

    override func rightViewRect(forBounds bounds: CGRect) -> CGRect {
        var rect = super.rightViewRect(forBounds: bounds)
        rect.origin.x -= 20
        rect.size.width = 70 
        return rect
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if let rightView = self.rightView {
            let rightViewWidth: CGFloat = 52
            let rightViewHeight: CGFloat = 28
            rightView.frame = CGRect(
                x: self.bounds.width - rightViewWidth - 8,
                y: (self.bounds.height - rightViewHeight) / 2,
                width: rightViewWidth,
                height: rightViewHeight
            )
        }
    }
}
