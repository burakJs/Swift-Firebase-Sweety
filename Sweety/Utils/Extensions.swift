//
//  Extensions.swift
//  Sweety
//
//  Created by Burak İmdat on 9.12.2021.
//

import Foundation
import Firebase

extension Query {
    func newWhere() -> Query {
        let dateData = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        guard let today = Calendar.current.date(from: dateData),
              let end = Calendar.current.date(byAdding: .hour, value: 24, to: today),
              let start = Calendar.current.date(byAdding: .day, value: 2, to: today) else {
                    fatalError("No records found in the specified range")
              }
//        return whereField(PUBLISH_DATE, isLessThanOrEqualTo: end).whereField(PUBLISH_DATE, isGreaterThanOrEqualTo: start).limit(to: 30)
        return whereField(PUBLISH_DATE, isLessThanOrEqualTo: end).whereField(PUBLISH_DATE, isGreaterThanOrEqualTo: today).limit(to: 30)
    }
}
