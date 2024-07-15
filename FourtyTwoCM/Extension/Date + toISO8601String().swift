//
//  Date + toISO8601String().swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/19/24.
//

import Foundation

extension Date {
    func toISO8601String() -> String {
        let dateFormatter = ISO8601DateFormatter()
        dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return dateFormatter.string(from: self)
    }
}
