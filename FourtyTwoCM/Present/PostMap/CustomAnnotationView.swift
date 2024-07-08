//
//  CustomAnnotationView.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 6/21/24.
//

import Foundation
import MapKit
import SnapKit
import Kingfisher

final class CustomAnnotationView: MKAnnotationView {
    
    lazy var backgroundView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 29
        $0.clipsToBounds = true
    }
    
    lazy var customImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .lightGray
        $0.layer.cornerRadius = 26
        $0.clipsToBounds = true
    }
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        configLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configLayout() {
        addSubview(backgroundView)
        backgroundView.addSubview(customImageView)
        
        backgroundView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.height.equalTo(58)
        }
        
        customImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(52)
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        customImageView.image = nil
    }
    
    override func prepareForDisplay() {
        super.prepareForDisplay()
        
        guard let annotation = annotation as? CustomAnnotation else { return }
        
        if let imageUrl = annotation.imageName, let url = URL(string: imageUrl) {
            customImageView.kf.setImage(with: url)
        }
        
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    func update(with annotation: CustomAnnotation) {
        if let imageUrl = annotation.imageName, let url = URL(string: imageUrl) {
            customImageView.kf.setImage(with: url)
        }
    }
    
    func select() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        }
    }
    
    func deselect() {
        UIView.animate(withDuration: 0.3) {
            self.backgroundView.transform = .identity
        }
    }
}
