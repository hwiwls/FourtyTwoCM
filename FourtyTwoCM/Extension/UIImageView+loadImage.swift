//
//  loadImage.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 4/24/24.
//

import UIKit
import Kingfisher

extension UIImageView {
    func loadImage(from url: URL, placeHolderImage: UIImage? = nil, completion: (() -> Void)? = nil) {
        var accessToken: String = ""
        do {
            accessToken = try Keychain.shared.getToken(kind: .accessToken)
        } catch {
            print("loadImage에서 액세스토큰을 불러오지 못함: \(error)")
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

        self.kf.setImage(
            with: url,
            placeholder: placeHolderImage,
            options: [.requestModifier(modifier)], // .forceRefresh 제거
            completionHandler: { result in
                switch result {
                case .success(_):
                    completion?()
                case .failure(let error):
                    print("이미지 로딩 실패: \(error)")
                    self.loadImage(from: url, placeHolderImage: placeHolderImage, completion: completion) // 재시도 로직 추가
                }
            }
        )
    }
}
