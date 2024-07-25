//
//  BaseTableViewCell.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/15/24.
//

import UIKit

class BaseTableViewCell: UITableViewCell {
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        configView()
        configHierarchy()
        configLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configView() { }
    func configHierarchy() { }
    func configLayout() { }
    
}
