//
//  ReservationViewController.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import UIKit
import SnapKit
import iamport_ios
import WebKit

final class ReservationViewController: BaseViewController {
    var storeName: String?
    var productDetail: String?
    var productName: String?
    var priceValue: String?
    var imageUrls: [String]?
    var postID: String?  // 결제 기능에 사용될 postID
    
    private let storeNameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 20)
        $0.text = "스타벅스"
        $0.textColor = .offWhite
    }
    
    private let productImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
        $0.backgroundColor = .blue
        $0.clipsToBounds = true
    }
    
    private let productNameLabel = UILabel().then {
        $0.font = .boldSystemFont(ofSize: 19)
        $0.text = "아이스 아메리카노"
        $0.textColor = .offWhite
    }
    
    private let productDetailLabel = UILabel().then {
        $0.font = .systemFont(ofSize: 15)
        $0.text = "풍부한 에스프레소와 물이 어우러진 클래식한 아메리카노"
        $0.textColor = .placeHolderGray
        $0.numberOfLines = 3
    }
    
    private let borderView = UIView().then {
        $0.backgroundColor = .tabBarBorderGray
    }
    
    private let priceLabel = UILabel().then {
        $0.text = "가격"
        $0.font = .boldSystemFont(ofSize: 18)
        $0.textColor = .offWhite
    }
    
    private let countLabel = UILabel().then {
        $0.text = "1개"
        $0.font = .systemFont(ofSize: 16)
        $0.textColor = .offWhite
    }
    
    
    private let priceValueLabel = UILabel().then {
        $0.text = "4,500원"
        $0.font = .boldSystemFont(ofSize: 16)
        $0.textColor = .offWhite
    }
    
    private let borderView2 = UIView().then {
        $0.backgroundColor = .tabBarBorderGray
    }
    
    private let reserveBtn = PointButton(title: "Reserve")
    
    private lazy var closeButton = UIButton().then {
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = .offWhite
        $0.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
    }
    
    
    @objc private func closeButtonTapped() {
        dismiss(animated: true, completion: nil)
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    override func configView() {
        let price = priceValue?.formattedAsCurrency() ?? "가격 정보 없음"
        
        storeNameLabel.text = storeName
        productDetailLabel.text = productDetail
        productNameLabel.text = productName
        priceValueLabel.text = price

        if let firstImageUrl = imageUrls?.first, let url = URL(string: BaseURL.baseURL.rawValue + "/" + firstImageUrl) {
            // 이미지 뷰에 이미지 로드
            print("예약 상품 이미지 url: \(url)")
            productImageView.loadImage(from: url)
        }
        
        reserveBtn.addTarget(self, action: #selector(payForReserve), for: .touchUpInside)
    }
    
    @objc func payForReserve() {
        guard let sesacKey = Bundle.main.sesacKey else {
            print("payForReserve에서 sesacKey를 로드하지 못했습니다.")
            return
        }
        
        let payment = IamportPayment(
            pg: PG.html5_inicis.makePgRawName(pgId: "INIpayTest"),
            merchant_uid: "ios_\(sesacKey)_\(Int(Date().timeIntervalSince1970))",
            
            amount: priceValue ?? "").then {
        $0.pay_method = PayMethod.card.rawValue
        $0.name = productName
        $0.buyer_name = "정휘진"
        $0.app_scheme = "sesac"
        }
        
        lazy var wkWebView: WKWebView = {
            var view = WKWebView()
            view.backgroundColor = UIColor.clear
            return view
        }()
        
        Iamport.shared.paymentWebView(
            webViewMode: wkWebView,
            userCode: UserCode.userCode.rawValue,
            payment: payment) { [weak self] iamportResponse in
                print(String(describing: iamportResponse))
                
                let success = iamportResponse?.success
                let impUid = iamportResponse?.imp_uid
                
                if success == true {
                    let alert = UIAlertController(title: "결제 성공", message: "결제에 성공했습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                } else {
                    let alert = UIAlertController(title: "결제 실패", message: "결제에 실패했습니다.", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "확인", style: .default, handler: nil))
                    self?.present(alert, animated: true, completion: nil)
                }
                
                print ("결제에 성공했나요? \(String(describing: success))")
                print("결제 고유 번호: \(String(describing: impUid))")
            }
        
        
    }
    
    override func configHierarchy() {
        view.addSubviews([
            closeButton,
            storeNameLabel,
            productImageView,
            productNameLabel,
            productDetailLabel,
            borderView,
            priceLabel,
            countLabel,
            priceValueLabel,
            borderView2,
            reserveBtn
        ])
    }
    
    
    override func configLayout() {
        storeNameLabel.snp.makeConstraints {
            $0.top.leading.equalTo(view.safeAreaLayoutGuide).offset(16)
        }
        
        closeButton.snp.makeConstraints {
            $0.top.trailing.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.size.equalTo(24)
        }
        
        productImageView.snp.makeConstraints {
            $0.top.equalTo(storeNameLabel.snp.bottom).offset(20)
            $0.width.equalToSuperview()
            $0.height.equalTo(productImageView.snp.width)
        }
        
        productNameLabel.snp.makeConstraints {
            $0.top.equalTo(productImageView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        
        productDetailLabel.snp.makeConstraints {
            $0.top.equalTo(productNameLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        borderView.snp.makeConstraints {
            $0.height.equalTo(8)
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(productDetailLabel.snp.bottom).offset(24)
        }
        
        priceLabel.snp.makeConstraints {
            $0.top.equalTo(borderView.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(16)
        }
        
        countLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(16)
        }
        
        priceValueLabel.snp.makeConstraints {
            $0.top.equalTo(priceLabel.snp.bottom).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        borderView2.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(reserveBtn.snp.top).offset(-8)
        }
        
        reserveBtn.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            $0.height.equalTo(45)
        }
        
        
    }
    

}
