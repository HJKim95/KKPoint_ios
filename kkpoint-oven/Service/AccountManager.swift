//
//  AccountManager.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/19.
//

import Foundation
import Security // 키체인 저장에 필요
import KakaoSDKAuth // 카카오 로그인
import NaverThirdPartyLogin // 네이버 로그인
import Alamofire

enum SocialType: String, Codable {
    case google
    case kakao
    case apple
    case naver
    case none
}

// 자동 로그인시, SNS에서 프로필을 못받아오기 때문에, 키체인에 유저 정보를 저장해야함.
struct KKPointUser: Codable {
    var socialType: SocialType
    var tokenSet: TokenSet?
    var uid: Int?
    var name: String?
    var email: String?
}

class AccountManager {
    static let shared = AccountManager()
    // MARK: - 새 쿠폰 여부
    /// 새로운 쿠폰 여부 받기
    func getNewCouponState() -> Bool {
        return UserDefaults.standard.bool(forKey: "newCoupon")
    }
    /// 새로운 쿠폰 여부 세팅
    func setNewCouponState(bool: Bool) {
        UserDefaults.standard.setValue(bool, forKey: "newCoupon")
    }
    
    // MARK: - 포인트
    var pointData: KKPointModel<AccountPointDataModel>?
    
    /// 서버에서 포인트 받아오기
    func getPoint() {
//        LottieManager.shared.startReload()
        NetworkManager.getMyPointData(page: 0) { [weak self] result in
            switch result {
            case .success(let response):
                self?.pointData = response
                NotificationCenter.default.post(name: Notification.Point.getPoint, object: self)
//                LottieManager.shared.stopReload()
            case .failure(let error):
                print("getMyPointData Error : \(error)")
//                LottieManager.shared.stopReload()
            }
        }
        
    }
    
    /// amount, content로 서버 포인트 수정하기
    func postPointHistory(amount: Int, content: String, handler: @escaping (() -> Void) ) {
        NetworkManager.postPointData(amount: amount, content: content) { [weak self] result in
            switch result {
            case .success(let data):
                // 포인트 수정 했으면, 다시 받아와서 UI들 갱신하기
                print(data)
                self?.getPoint()
                handler()
            case .failure(let error):
                print("postPointHistory Error : \(error)")
            }
        }
    }

    // MARK: - 출석체크
    var attendanceData = [[String]]()
    
    /// 서버에서 출석체크 받아오기
    func getAttendance() {
//        LottieManager.shared.startReload()
        let calendar = Formatter.Date.calendar
        let components = calendar.dateComponents([.year, .month], from: Date())
        guard let startOfMonth = calendar.date(from: components) else { return }
        let wholeDateFormatter = Formatter.Date.dateFormatterGetWholeDate
        let dateString = wholeDateFormatter.string(from: startOfMonth)
        NetworkManager.getMyAttendanceData(dateString: dateString) { [weak self] (result) in
            switch result {
            case .success(let data):
                var dateArray = [String]()
                guard let responseList = data.data else {return}
                for date in responseList {
                    dateArray.append(date.createdAt ?? "")
                }
                self?.attendanceData = [dateArray]
                NotificationCenter.default.post(name: Notification.Attendance.getAttendance, object: self)
//                LottieManager.shared.stopReload()
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "출석정보 관련 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
//                LottieManager.shared.stopReload()
                
            }
        }
    }
    
    // MARK: - 버전 정보
    var isRecentVersion: Bool? // 지금 최신 버전인지
    var lastVersion = "" // 다운로드를 위한 최신버전 이름
    
    // MARK: - 로그인 정보
    // 지금 로그인 되어있는지 여부
    var isLogged: Bool = false
    // 유저 정보
    var user: KKPointUser = KKPointUser(socialType: .none, tokenSet: nil, uid: nil, name: nil, email: nil)
    
    /// 자동 로그인 얻기 On Off 여부 On = true
    func getAutoLoginState() -> Bool {
        return UserDefaults.standard.bool(forKey: "autoLogin")
    }
    /// 자동 로그인 세팅
    func setAutoLoginState(bool: Bool) {
        UserDefaults.standard.setValue(bool, forKey: "autoLogin")
    }
    /// 자동 로그인 시도
    func tryAutoLogin() {
        // 키체인에 있는 유저 정보, 토큰 로드
        guard let loadedUser = loadUserItem() else {
            print("키체인 데이터 로드 실패"); return }
        user = loadedUser
        
        // 토큰 리프래쉬 시도
        guard let refreshToken = user.tokenSet?.refreshToken else { return }
        tryRefreshToken(refreshToken: refreshToken) {
            PermissionManager.alertToast()
        }
    }
    
    /// 토큰 리프레쉬 ( AccessToken이 거부당했을 때 or 자동 로그인할때 시도 )
    func tryRefreshToken(refreshToken: String, _ handler: @escaping () -> Void) {
        NetworkManager.refreshToken(refreshToken: refreshToken) { [weak self] (result) in
            switch result {
            case .failure(let error):
                print("토큰 리프래쉬 실패. 다시 로그인 해주세요. \(error)")
            case .success(let response):
                // iOS에 토큰 저장
                self?.user.tokenSet = response.data
                // 로그인 상태 On
                self?.isLogged = true
                // 로그인 대응 UI 작업
                NotificationCenter.default.post(name: Notification.Login.checkLogin, object: self)
                // 자동 로그인 여부 체크 (keyChain 저장)
                self?.checkNeedSaveKeyChain()
                // 리프래쉬 잘 받았으면~ 다시 리퀘스트!
                handler()
                // 로그인 했으면 포인트 정보 가져오기
                self?.getPoint()
            }
        }
    }
    
    // 로그인 or 회원가입시 계정 정보 세팅 + 로그인 대응 UI 작업
    func setSignInOrSignUpData<T> (socialType: SocialType, data: T) {
        // 계정 데이터 넣기
        if let signUpData = data as? SignUpResponse {
            user.uid = signUpData.uid
            user.name = signUpData.name
            user.email = signUpData.email
            user.tokenSet = signUpData.tokenSet
        } else if let signInData = data as? SignInResponse {
            user.uid = signInData.uid
            user.name = signInData.name
            user.email = signInData.email
            user.tokenSet = signInData.tokenSet
        } else {
            print("로그인 정보 세팅 타입 오류")
            return
        }
        user.socialType = socialType
        // 로그인 상태 On
        isLogged = true
        // 로그인 대응 UI 작업
        NotificationCenter.default.post(name: Notification.Login.checkLogin, object: self)
        // 자동 로그인 무조건 true
        AccountManager.shared.setAutoLoginState(bool: true)
        // 자동로그인 여부 체크 (keyChain 저장)
        checkNeedSaveKeyChain()
        // 구독 정보 변경
        NotificationCenter.default.post(name: Notification.Subscribe.checkSubscribe, object: self)
        // 로그인 했으면 포인트 정보 가져오기
        getPoint()
    }
    
    // 자동로그인 On Off 여부에 따라 키체인에 현재 user 데이터를 저장하거나 지움
    func checkNeedSaveKeyChain() {
        // 걍 무조건 자동로그인.
        if saveUserItem(user) { print("키체인 데이터 저장 성공") } else { print("키체인 데이터 저장 실패") }
        
//        if getAutoLoginState() { // 자동로그인 On 상태라면, 계정정보 키체인 저장
//            if saveUserItem(user) { print("키체인 데이터 저장 성공") } else { print("키체인 데이터 저장 실패") }
//        } else { // 자동로그인 Off 상태라면, 키체인에 있을 수도 있는 데이터 삭제
//            if deleteUserItem() { print("키체인 데이터 지우기 성공") } else { print("키체인 데이터 지우기 실패") }
//        }
    }
    
    /// 로그아웃
    func logout() {
        // 디테일한 회원탈퇴 처리방법. ( 해당 개발자 사이트의 통계 API를 정확히하려면 필요하다. 추후 필요하면 적용하자)
//        if user.socialType == .kakao {
//
//        } else if user.socialType == .naver {
//            let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
//            guard let clientID = loginInstance?.consumerKey,
//                  let clientSecret = loginInstance?.consumerSecret,
//                  let accessToken = UserDefaults.standard.string(forKey: "naverAccessToken") else {return}
//            let grantType = "delete"
//            let urlString = "https://nid.naver.com/oauth2.0/token?grant_type=\(grantType)&client_id=\(clientID)&client_secret=\(clientSecret)&access_token=\(accessToken)&service_provider=NAVER"
//            print(urlString)
//            AF.request(urlString, method: .get, encoding: JSONEncoding.default).responseJSON { response in
//                print(response.result)
//            }
//        }
//
        // 로그인 Off
        isLogged = false
        // 구독 리로드 막게 uid = nil, 토큰 리프래쉬 때문에 토큰도 지워야함.. 걍 다 지우자 ㄲㄲ
        user = KKPointUser(socialType: .none, tokenSet: nil, uid: nil, name: nil, email: nil)
        // 자동 로그인 끄기
        setAutoLoginState(bool: false)
        // 키체인에 있는 데이터 지우기
        if deleteUserItem() { print("키체인 데이터 지우기 성공") } else { print("키체인 데이터 지우기 실패") }
        // 로그아웃 대응 UI 작업
        NotificationCenter.default.post(name: Notification.Login.checkLogin, object: self)
        // 구독 정보 변경
        NotificationCenter.default.post(name: Notification.Subscribe.checkSubscribe, object: self)
    }
    
    // MARK: - 검색 관련
    /// 검색 기록 가져오기
    func getSearchRecord() -> [String] {
        return UserDefaults.standard.value(forKey: UserDefault.searchRecord) as? [String] ?? []
    }
    /// 검색 기록 넣기
    func setSearchRecord(record: String) {
        var newRecords = getSearchRecord()
        for (index, str) in newRecords.enumerated() where str == record {
            newRecords.remove(at: index)
            break
        }
        newRecords.insert(record, at: 0)
        if newRecords.count == 101 { newRecords.removeLast() }
        UserDefaults.standard.setValue(newRecords, forKey: UserDefault.searchRecord)
    }
    
    // MARK: - 키체인 저장
    /*
     SecKeychain 라는 디비가 있으며,
     이 디비에는 SecKeychainItem을 넣는다.
     Item에는 애플이 미리 지정한 각종 어트리뷰트들 kSecAttr이 있으며
     kSecAttr 중에 어떤 것들을 키(키체인 항목), 어떤 것들을 밸류로 사용할지 프로프래머가 지정한다.
     
     Keychain 관련 쿼리 키 값들
     let kSecClassValue                  = NSString(format: kSecClass)
     let kSecAttrAccountValue            = NSString(format: kSecAttrAccount)
     let kSecValueDataValue              = NSString(format: kSecValueData)
     let kSecAttrGenericValue            = NSString(format: kSecAttrGeneric)
     let kSecAttrServiceValue            = NSString(format: kSecAttrService)
     let kSecAttrAccessValue             = NSString(format: kSecAttrAccessible)
     let kSecMatchLimitValue             = NSString(format: kSecMatchLimit)
     let kSecReturnDataValue             = NSString(format: kSecReturnData)
     let kSecMatchLimitOneValue          = NSString(format: kSecMatchLimitOne)
     let kSecAttrAccessGroupValue        = NSString(format: kSecAttrAccessGroup)
     let kSecClassGenericPasswordValue   = NSString(format: kSecClassGenericPassword)
     */
    
    private let kSecAttrServiceStr: String = "kkPoint"
    private let kSecAttrAccountStr: String = "user"
    
    /// SecItemAdd함수를 사용해, 키체인 아이템 추가. 성공시 true
    func saveUserItem(_ user: KKPointUser) -> Bool {
        // 토큰셋을 JSON 인코딩하여 data로 가공
        guard let data = try? JSONEncoder().encode(user) else { return false }
        // data를 저장하기 위한 쿼리 (
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword, // 키체인 항목을 어떤 방식으로 만드느냐.
                                      // kSecClassGenericPassword는 kSecAttrService와 kSecAttrAccount의 조합을 사용.
                                      kSecAttrService: kSecAttrServiceStr, // 키체인 항목에 넣을 kSecAttrService의 값
                                      kSecAttrAccount: kSecAttrAccountStr, // 키체인 항목에 넣을 kSecAttrAccount의 값
                                      kSecAttrGeneric: data] // Generic이라는 attr를 밸류로 사용한다.
        _ = deleteUserItem() // 이미 있는 거 삭제 (이미 있을 때 Create하면 실패함) SecItemDelete만 하니까 안됨
        return SecItemAdd(query as CFDictionary, nil) == errSecSuccess
     }
    
    /// SecItemCopyMatching함수를 사용해, 키체인 아이템 로드. 성공시 읽은 tokenSet
    func loadUserItem() -> KKPointUser? {
        let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: kSecAttrServiceStr,
                                    kSecAttrAccount: kSecAttrAccountStr,
                                    kSecMatchLimit: kSecMatchLimitOne,
                                    kSecReturnAttributes: true,
                                    kSecReturnData: true]

        var item: CFTypeRef?
        if SecItemCopyMatching(query as CFDictionary, &item) != errSecSuccess { return nil }

        guard let existingItem = item as? [CFString: Any],
              let data = existingItem[kSecAttrGeneric] as? Data,
              let user = try? JSONDecoder().decode(KKPointUser.self, from: data) else { return nil }

        return user
    }
    
    /// SecItemDelete함수를 사용해, 키체인 아이템 삭제. 성공시 true
    func deleteUserItem() -> Bool {
      let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
                                    kSecAttrService: kSecAttrServiceStr,
                                    kSecAttrAccount: kSecAttrAccountStr]

      return SecItemDelete(query as CFDictionary) == errSecSuccess
    }
    
    /// SecItemUpdate함수를 사용해, 키체인 아이템 수정. 성공시 true
//    func updateTokenItem(_ user: TokenSet) -> Bool {
//      guard let data = try? JSONEncoder().encode(user) else { return false }
//
//      let query: [CFString: Any] = [kSecClass: kSecClassGenericPassword,
//                                    kSecAttrService: kSecAttrServiceStr,
//                                    kSecAttrAccount: kSecAttrAccountStr]
//      let attributes: [CFString: Any] = [kSecAttrAccount: "tokenSet",
//                                         kSecAttrGeneric: data]
//
//      return SecItemUpdate(query as CFDictionary, attributes as CFDictionary) == errSecSuccess
//    }
}
