//
//  String + toISO8601Date().swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/19/24.
//

import Foundation

extension String {
    func toISO8601Date() -> Date? {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter.date(from: self)
    }
}
