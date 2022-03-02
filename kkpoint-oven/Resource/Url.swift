//
//  Url.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/24.
//

import Foundation

#if DEV
let url = "biz01-dev.idol-master.kr"
#else
let url = "trot.idol-master.kr"
#endif

enum Url {
    static let kakaoTempleteRequestUrl = "https://developers.kakao.com"
    static let userUrl = "https://\(url)/kkpoint/user"
    static let attendanceUrl = "https://\(url)/kkpoint/attendance"
    static let pointUrl = "https://\(url)/kkpoint/pointHistory"
    static let shopUrl = "https://\(url)/kkpoint/shop"
    static let eventUrl = "https://\(url)/kkpoint/notice"
    static let couponListUrl = "https://\(url)/kkpoint/couponList/readAll"
    static let userCouponUrl = "https://\(url)/kkpoint/user_coupon"
    static let channelUrl = "https://\(url)/kkpoint/channel"
    static let videoUrl = "https://\(url)/kkpoint/video"
    static let subscribeUrl = "https://\(url)/kkpoint/subscribe"
    static let search = "https://\(url)/kkpoint/search"
    static let customerService = "https://\(url)/kkpoint/CustomerService"
    static let versionUrl = "https://\(url)/kkpoint/appInfo/readInfo"

}
