//
//  Notification.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/24.
//

import Foundation

// MARK: - Custom Notification
public extension Notification {
    class Login {
        static let checkLogin = Notification.Name("didLogin")
    }
    class Attendance {
        static let didPresentToday = Notification.Name("didPresentToday")
        static let getAttendance = Notification.Name("getAttendance")
    }
    struct Subscribe {
        static let checkSubscribe = Notification.Name("changeSubscribe")
    }
    struct Point {
        static let getPoint = Notification.Name("getPoint")
    }
}
