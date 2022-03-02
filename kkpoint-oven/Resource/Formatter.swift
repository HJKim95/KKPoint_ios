//
//  Formatter.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/24.
//

import Foundation

enum Formatter {
    enum Date {
        static let dateFormatterGetWholeDate: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy-MM-dd"
            return formatter
        }()
        
        static let pushAlertFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy년 MM월 dd일"
            return formatter
        }()
        
        static let checkUpdateFormatter: DateFormatter = {
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            return formatter
        }()
        
        static let dateFormatterGetYear: DateFormatter = { // For 출석체크
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "yyyy"
            return formatter
        }()
        
        static let dateFormatterGetMonth: DateFormatter = { // For 출석체크
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "M"
            return formatter
        }()
        
        static let dateFormatterGetDate: DateFormatter = { // For 출석체크
            let formatter = DateFormatter()
            formatter.locale = Locale(identifier: "ko_KR")
            formatter.dateFormat = "d"
            return formatter
        }()
        
        static let calendar: Calendar = {
            var cal = Calendar(identifier: .gregorian)
            cal.locale = Locale(identifier: "ko_KR")
            return cal
        }()
        
    }
    
    enum Number {
        static let numberFormatter: NumberFormatter = {
            let formatter = NumberFormatter()
            formatter.numberStyle = .decimal
            return formatter
        }()
        static func getFormattedNum(num: Int) -> String {
            return numberFormatter.string(from: NSNumber(value: num)) ?? ""
        }
    }
}
