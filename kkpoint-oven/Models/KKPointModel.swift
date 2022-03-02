//
//  KKPointAccountModel.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/26.
//

import Foundation
import UIKit

struct KKPointModel<T: Decodable>: Decodable {
    var transactionTime: String?
    var resultCode: String?
    var description: String?
    var data: T?
    var pagination: Pagination?
}

struct AccountModel: Decodable {
    var idx: Int?
    var socialType: String?
    var name: String?
    var email: String?
    var enableAlarm: Bool?
    var enableAlarmDate: String?
    var createdAt: String?
    var updatedAt: String?
    
    var dictionary: [String: Any] {
        return ["socialType": socialType!,
                "name": name!,
                "email": email!,
                "enableAlarm": enableAlarm!,
                "enableAlarmDate": enableAlarmDate!]
    }
}

struct AccountPointDataModel: Decodable {
    var totalPoints: Int
    var pointApiResponseList: [PointHistoryModel]
}

struct AttendanceModel: Decodable {
    var idx: Int?
    var uid: Int?
    var createdAt: String?
    
    var dictionary: [String: Any] {
        return ["uid": uid!]
    }
}

struct PointHistoryModel: Decodable {
    var amount: Int?
    var content: String?
    var createdAt: String?
    
    var dictionary: [String: Any] {
        return ["amount": amount!,
                "content": content!]
    }
}

struct NoticeEventModel: Decodable {
    var idx: Int?
    var title: String?
    var contentUrl: String?
    var startDate: String?
    var endDate: String?
    var displayFlag: Bool?
    var content: String?
}

struct Pagination: Decodable {
    var totalPages: Int
    var totalElements: Int
    var currentPage: Int
    var currentElements: Int
}

// MARK: - Coupon 관련 모델

struct CouponList: Decodable {
    let idx: Int
    let couponName: String
    let admin: String
    let dueDate: String
    let homepage: String
    let homepageUrl: String
    let validDate: String
    let itemDescription: String
    let itemCsDescription: String
    let deliverDescription: String
    let refundDescription: String
    let price: Int
}

struct UserCoupon: Decodable {
    let idx: Int
    let uid: Int
    var admin: String?
    var couponName: String?
    let createdAt: String
    let couponId: String
    let validDate: String
    var homepage: String?
    var homepageUrl: String?
}

// MARK: - Channel 관련 모델
/// Channel API 회신 값들
struct ChannelResponse: Decodable {
    let data: [Channel]
}
struct Channel: Decodable {
    let cid: String
    let profileUrl: String?
    let description: String
    let descriptionAdmin: String?
    let createdAt: String
    let updatedAt: String
    let cname: String
    let subscribeCnt: Int
    let videoCnt: Int
}
struct ChannelHome: Decodable {
    let channel: Channel
    let isSubscribed: Bool
    let videoList: [Video]
}

// MARK: - Video 관련 모델
/// Video API 회신 값들
struct VideoResponse: Decodable {
    let data: [Video]
    let pagination: Pagination
}
struct Video: Decodable {
    let vid: String
    let largeThumbnailUrl: String?
    let smallThumbnailUrl: String?
    let title: String?
    let views: Int
    let category: String
    let duration: Int
    let cid: String
    let description: String?
    let createdAt: String
    let channelProfileUrl: String?
    let channelCName: String
}
struct RelatedVideosResponse: Decodable {
    let data: RelatedVideos
    struct RelatedVideos: Decodable {
        let video: Video
        let relatedVideos: [Video]
    }
}

// MARK: - Subscribe
struct SubscribeResponse: Decodable {
    let data: Bool
}

// MARK: - Sign 로그인 관련 모델
struct SignInRequest: Decodable {
    let name: String
    let accessToken: String
    let socialType: SocialType
    let uuid: String
}
struct SignInResponse: Decodable {
    let tokenSet: TokenSet?
    let name: String?
    let email: String?
    let socialType: String?
    let uid: Int?
    let needSignUp: Bool
}
struct TokenSet: Codable {
    let accessToken: String?
    let refreshToken: String?
}

struct SignUpRequest: Decodable {
    let name: String
    let accessToken: String
    let socialType: SocialType
    let uuid: String
    let enableAlert: Bool
}
struct SignUpResponse: Decodable {
    let tokenSet: TokenSet
    let name: String
    let email: String
    let socialType: String
    let uid: Int
}

// MARK: - 서버와 잘 통신 되었는지 확인만 하는 모델
struct HttpCheck: Decodable {
    let resultCode: String
}
// MARK: - 검색시 채널, 구독여부, 영상들 한번에 들고오는 모델
struct SearchData: Decodable {
    let videoList: [Video]
    let channelList: [Channel]
    let subscribeList: [Bool]
}

// MARK: - 시연 구현을 위한 임시 더미 모델
struct Product {
    let imgName: String
    let name: String
    let price: Int
}

// MARK: - 문의하기
struct CustomerService: Decodable {
    let content: String
    let userEmail: String
    let userName: String
    let userId: Int
}

// MARK: - 버전관련
struct VersionModel: Codable {
    var minVersion: String?
    var marketVersion: String?
    var regularTestMessage: String?
    var regularTestStartDate: String?
    var regularTestEndDate: String?
}
// MARK: - 팝업에 줄수 있는 옵션들
/// 팝업 외부 배경색, 팝업 내부 배경색
struct BackgroundColorOption {
    let popupViewColor: UIColor
    let unableViewColor: UIColor
    
}
/// 버튼 하나하나의 옵션
struct ButtonOption {
    let title: String
    let handler: (() -> Void)
}

struct RelatedVideoItem: Decodable {
    let vid: String
    let vitemImageUrl: String
    let vitemName: String
    let vitemPrice: Int
    let vitemLinkUrl: String
}

// MARK: - 보호자 확인 팝업
enum Operator {
    case add
    case mul
}
