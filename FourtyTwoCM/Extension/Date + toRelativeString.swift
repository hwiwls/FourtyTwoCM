//
//  Date + .swift
//  FourtyTwoCM
//
//  Created by hwijinjeong on 7/26/24.
//

import Foundation

extension Date {
    func toRelativeString() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateTimeStyle = .named
        formatter.unitsStyle = .short
        let dateToString = formatter.localizedString(for: self, relativeTo: .now)
        return dateToString
    }
}
