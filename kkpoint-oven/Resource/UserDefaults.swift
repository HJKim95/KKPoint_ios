//
//  UserDefaults.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/24.
//

import Foundation

enum UserDefault {
    static let personalID = "personalID" // 계정 id -> Int
    static let tutorial = "tutorial" // -> Bool
    static let permission = "permission"
    static let didLogin = "didLogin" // 로그인, 로그아웃 여부 -> Bool
    static let pushAlertDate = "pushAlertDate" // -> String
    static let pushAlert = "pushAlert" // -> Bool
    static let firstPushAlertSet = "firstPushAlertSet" // -> Bool
    static let searchRecord = "searchRecord" // -> [String]
    static let didAgeCheck = "didAgeCheck" // -> Bool
    static let checkUpdateAlert = "checkUpdateAlert" // 업데이트 권유 알림 받았는지 여부 (해당 버젼을 기억)
    static let checkIntro = "checkIntro" // IntroVC 보았는지 여부 -> Bool
}

