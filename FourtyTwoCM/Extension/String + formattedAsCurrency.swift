//
//  String + formattedAsCurrency.swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 5/5/24.
//

import Foundation

extension String {
    func formattedAsCurrency(locale: Locale = Locale(identifier: "ko_KR")) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = locale
        numberFormatter.currencySymbol = ""  // 통화 기호 제거
        numberFormatter.maximumFractionDigits = 0  // 소수점 이하 자릿수 제한

        if let number = Double(self), let formattedString = numberFormatter.string(from: NSNumber(value: number)) {
            return formattedString + "원"  // "원" 단위 추가
        }
        return self  // 변환 실패 시 원본 문자열 반환
    }
}
