//
//  NetworkAPI.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/15.
//

import Foundation

extension NetworkManager {
    // MARK: - Account
    /// 로그인
    class func signIn(request: SignInRequest, handler: @escaping NetworkResultHandler<KKPointModel<SignInResponse>>) {
        NetworkManager.request(urlString: Url.userUrl+"/signin",
                               method: .post,
                               parameters: ["accessToken": request.accessToken, // SNS의 accessToken
                                            "name": request.name,
                                            "socialType": request.socialType.rawValue,
                                            "uuid": request.uuid],
                               handler)
    }
    /// 회원 가입
    class func singUp(request: SignUpRequest, handler: @escaping NetworkResultHandler<KKPointModel<SignUpResponse>>) {
        NetworkManager.request(urlString: Url.userUrl+"/signup",
                               method: .post,
                               parameters: ["accessToken": request.accessToken, // SNS의 accessToken
                                            "enableAlert": request.enableAlert,
                                            "name": request.name,
                                            "socialType": request.socialType.rawValue,
                                            "uuid": request.uuid],
                               handler)
    }
    /// 리프레쉬 토큰으로 토큰 재발급 ( = 자동 로그인 )
    class func refreshToken(refreshToken: String, handler: @escaping NetworkResultHandler<KKPointModel<TokenSet>>) {
        NetworkManager.request(urlString: Url.userUrl+"/refreshAccessToken?refreshToken=\(refreshToken)",
                               method: .post,
                               handler)
    }
    
    class func updateMyInfo(parameters: [String: Any], handler: @escaping NetworkResultHandler<KKPointModel<AccountModel>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(urlString: Url.userUrl,
                               method: .put,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               parameters: parameters,
                               handler)
    }
    
    class func deleteMyInfo(handler: @escaping NetworkResultHandler<KKPointModel<AccountModel>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(urlString: Url.userUrl,
                               method: .delete,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               handler)
    }
    
    // MARK: - Point
    class func postPointData(amount: Int, content: String, handler: @escaping NetworkResultHandler<KKPointModel<PointHistoryModel>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else {
            LottieManager.shared.stopReload()
            return
        }
        NetworkManager.request(urlString: Url.pointUrl,
                               method: .post,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               parameters: ["amount": amount, "content": content, "idx": 0],
                               handler)
    }
    
    class func getMyPointData(page: Int, handler: @escaping NetworkResultHandler<KKPointModel<AccountPointDataModel>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else {
            LottieManager.shared.stopReload()
            return
        }
        let pageString = String(page)
        NetworkManager.request(urlString: Url.userUrl+"/pointHistory?page=\(pageString)",
                               method: .get,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               handler)
    }

    // MARK: - Attendance
    class func postAttendanceData(handler: @escaping NetworkResultHandler<KKPointModel<AttendanceModel>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else {
            LottieManager.shared.stopReload()
            return
        }
        NetworkManager.request(urlString: Url.attendanceUrl,
                               method: .post,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               handler)
    }
    
    class func getMyAttendanceData(dateString: String, handler: @escaping NetworkResultHandler<KKPointModel<[AttendanceModel]>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else {
            LottieManager.shared.stopReload()
            return
        }
        NetworkManager.request(urlString: Url.userUrl+"/attendance?date=\(dateString)",
                               method: .get,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               handler)
    }

    // MARK: - Coupon
    /// 상점 쿠폰들 가져오기
    class func getCouponListData(handler: @escaping NetworkResultHandler<KKPointModel<[CouponList]>>) {
       NetworkManager.request(
           urlString: Url.couponListUrl,
           method: .get,
           handler)
    }
    
    /// 유저의 쿠폰들 가져오기
    class func getUserCoupons(page: Int, handler: @escaping NetworkResultHandler<KKPointModel<[UserCoupon]>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(urlString: Url.userCouponUrl+"s?page=\(page)",
                               method: .get,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               handler)
    }
    /// 유저 쿠폰 등록
    class func postUserCoupon(couponListId: Int, handler: @escaping NetworkResultHandler<KKPointModel<UserCoupon>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(urlString: Url.userCouponUrl+"?couponListId=\(couponListId)",
                               method: .post,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               handler)
    }

    // MARK: - NoticeEvent
    class func getNoticeEventData(page: Int, handler: @escaping NetworkResultHandler<KKPointModel<[NoticeEventModel]>>) {
        let pageString = String(page)
        NetworkManager.request(urlString: Url.eventUrl+"?page=\(pageString)", method: .get, handler)
    }
    
    // MARK: - Channel
    class func getMyChannels(page: Int, handler: @escaping NetworkResultHandler<ChannelResponse>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(
            urlString: Url.channelUrl+"s/subscribed?page=\(page)",
            method: .get,
            headers: ["X-AUTH-TOKEN": accessToken],
            handler)
    }
    
    class func getChannelHome(cid: String, handler: @escaping NetworkResultHandler<KKPointModel<ChannelHome>>) {
        let uid = AccountManager.shared.user.uid ?? 0
        NetworkManager.request(
            urlString: Url.channelUrl+"/home?uid=\(uid)&cid=\(cid)",
            method: .get,
            handler)
    }
    
    // MARK: - Subscribe
    class func getSubscribe(cid: String, handler: @escaping NetworkResultHandler<SubscribeResponse>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(
            urlString: Url.subscribeUrl+"/status?cid=\(cid)",
            method: .get,
            headers: ["X-AUTH-TOKEN": accessToken],
            handler)
    }
    
    class func postSubscribe(cid: String, handler: @escaping NetworkResultHandler<HttpCheck>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(
            urlString: Url.subscribeUrl+"?cid=\(cid)",
            method: .post,
            headers: ["X-AUTH-TOKEN": accessToken],
            handler)
    }

    class func deleteSubscribe(cid: String, handler: @escaping NetworkResultHandler<HttpCheck>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(
            urlString: Url.subscribeUrl+"?cid=\(cid)",
            method: .delete,
            headers: ["X-AUTH-TOKEN": accessToken],
            handler)
    }
    
    // MARK: - Video
    /// 내가 구독한 채널들의 비디오들 불러오기
    class func getMyChannelsVideos(page: Int, handler: @escaping NetworkResultHandler<VideoResponse>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else { return }
        NetworkManager.request(
            urlString: Url.videoUrl+"s/subscribed?page=\(page)",
            method: .get,
            headers: ["X-AUTH-TOKEN": accessToken],
            handler) }
    
    /// 모든 비디오 불러오기
    class func getAllVideos(page: Int, handler: @escaping NetworkResultHandler<VideoResponse>) {
        NetworkManager.request(
            urlString: Url.videoUrl+"s?page=\(page)",
            method: .get,
            handler) }
    
    class func getVideoViewsUpdate(vid: String, handler: @escaping NetworkResultHandler<KKPointModel<Video>>) {
        NetworkManager.request(
            urlString: Url.videoUrl+"s/update?vid=\(vid)",
            method: .get,
            handler) }
    
    /// 비디오로 연관비디오 불러오기
    class func getRelatredVideos(vid: String, handler: @escaping NetworkResultHandler<RelatedVideosResponse>) {
        NetworkManager.request(
            urlString: Url.videoUrl+"s/related/\(vid)",
            method: .get,
            handler) }
    
    /// 비디오로 연관상품 불러오기
    class func getRelatedItems(vid: String, handler: @escaping NetworkResultHandler<KKPointModel<[RelatedVideoItem]>>) {
        NetworkManager.request(
            urlString: Url.videoUrl+"/relatedItem/\(vid)",
            method: .get,
            handler) }
    
    /// 한 채널의 비디오 불러오기
    class func getChannelVideos(cid: Int, page: Int, handler: @escaping NetworkResultHandler<VideoResponse>) {
        NetworkManager.request(
            urlString: Url.videoUrl+"s/channel/\(cid)?page=\(page)",
            method: .get,
            handler) }
    
    // MARK: - Search
    /// uid와 검색문자열로 채널, 영상, 채널의 구독여부를 들고온다
    class func getSearchData(searchStr: String, handler: @escaping NetworkResultHandler<KKPointModel<SearchData>>) {
        let uid = AccountManager.shared.user.uid ?? 0
        NetworkManager.request(
            urlString: Url.search+"?uid=\(uid)&searchText=\(searchStr)",
            method: .get,
            handler) }
    
    /// uid와 검색문자열로 채널의 구독여부를 refresh
    class func getRefreshedSubscribeData(searchStr: String, handler: @escaping NetworkResultHandler<KKPointModel<[Bool]>>) {
        let uid = AccountManager.shared.user.uid ?? 0
        NetworkManager.request(
            urlString: Url.search+"/refreshChannel"+"?uid=\(uid)&searchText=\(searchStr)",
            method: .get,
            handler) }
    
    // MARK: - CustomerService
    class func postCSData(content: String, handler: @escaping NetworkResultHandler<KKPointModel<CustomerService>>) {
        guard let accessToken = AccountManager.shared.user.tokenSet?.accessToken else {
            LottieManager.shared.stopReload()
            return
        }
        NetworkManager.request(urlString: Url.customerService,
                               method: .post,
                               headers: ["X-AUTH-TOKEN": accessToken],
                               parameters: ["content": content,
                                            "userEmail": AccountManager.shared.user.email ?? "이메일 오류",
                                            "userName": AccountManager.shared.user.name ?? "이름 오류"],
                               handler)
    }
    
    // MARK: - CustomerService
    class func getVersionData(handler: @escaping NetworkResultHandler<KKPointModel<VersionModel>>) {
        NetworkManager.request(urlString: Url.versionUrl+"?os=ios",
                               method: .get,
                               handler)
    }
    
}
