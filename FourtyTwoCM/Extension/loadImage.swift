//
//  loadImage.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/24/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(from url: URL, placeHolderImage: UIImage? = nil) {
        var accessToken: String = ""
        
        do {
            accessToken = try Keychain.shared.getToken(kind: .accessToken)
            print("access Token을 겟또: \(accessToken)")
        } catch {
            print("Error retrieving access token: \(error)")
        }
        
        guard let sesacKey = Bundle.main.sesacKey else {
            print("sesacKey를 로드하지 못했습니다.")
            return 
        }
        
        let modifier = AnyModifier { request in
            var request = request
            request.setValue(accessToken, forHTTPHeaderField: HTTPHeader.authorization.rawValue)
            request.setValue(sesacKey, forHTTPHeaderField: HTTPHeader.sesacKey.rawValue)
            return request
        }
        self.kf.setImage(with: url, placeholder: placeHolderImage, options: [.requestModifier(modifier), .forceRefresh])
    }
}
