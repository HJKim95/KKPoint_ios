//
//  AppDelegate.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/11.
//

import UIKit
import KakaoSDKCommon // 카카오 API를 사용하기 위한 공통 라이브러리
import KakaoSDKAuth // 카카오 로그인 API
import GoogleSignIn // 구글 로그인!!
import Firebase
import GoogleMobileAds // AdMob 관련
import NaverThirdPartyLogin
import AWSSNS // AWS APNS
import Alamofire

#if DEV
let SNSPlatformApplicationArn = "arn:aws:sns:ap-northeast-2:315314586007:app/APNS_SANDBOX/KKPoint_ios"
let topicArn = "arn:aws:sns:ap-northeast-2:315314586007:KKPoint"
let cognitoPoolId = "ap-northeast-2:dd551968-fdfe-48af-823c-ee4f80b3d483"
let googleClientId = "161647423221-c6enu5hg5lfarscpk21p8bufaesrutsp.apps.googleusercontent.com"
let kakapAppKey = "246df8603070787dc84a8950f1181aa7"
let naverCliendId = "v7HRtD1mTZEXS5nO2q8z"
let naverUrlScheme = "naverlogindev"
let naverSecret = "D8mb9S4hst"
let naverAppName = "KKPoint"
let myStatus = "-dev"
let isDev = true
#else
let SNSPlatformApplicationArn = "arn:aws:sns:ap-northeast-2:315314586007:app/APNS/KKPoint_ios_prod"
let topicArn = "arn:aws:sns:ap-northeast-2:315314586007:KKPoint_prod"
let cognitoPoolId = "ap-northeast-2:df3dc3a1-20de-4e5e-ac9e-7f1ee59e8334"
let googleClientId = "161647423221-04hg0kf9p8nbmncuu8rjd96phca6fpdc.apps.googleusercontent.com"
let kakapAppKey = "b5a815cea7e7e47c0da49c9b44e5b743"
let naverCliendId = "v7HRtD1mTZEXS5nO2q8z"
let naverUrlScheme = "naverlogin"
let naverSecret = "D8mb9S4hst"
let naverAppName = "KKPoint"
let myStatus = "-prod"
let isDev = false
#endif

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow()
        
        // 앱 버전을 확인하지 않고 바로 앱으로 진입하는 것을 막기 위함.
        self.window?.rootViewController = UIStoryboard.init(name: "LaunchScreen",
                                                            bundle: nil).instantiateInitialViewController()
        
        checkRegularTestAndUpdate()
        
        return true
    }
    
    private func applicationConfigure() {
        window?.makeKeyAndVisible()

        let checkIntro = UserDefault.checkIntro
        let checkIntroUserDefault = UserDefaults.standard.bool(forKey: checkIntro) // 만약 값이 없다면 false로 내려준다.

        if checkIntroUserDefault == false {
            window?.rootViewController = IntroViewController()
        } else {
            window?.rootViewController = UINavigationController(rootViewController: MainTabBarController())
        }

        UINavigationBar.appearance().barTintColor = UIColor(named: "elavated")
        UINavigationBar.appearance().isTranslucent = false
        
        // Use Firebase library to configure APIs
        FirebaseApp.configure()
        GADMobileAds.sharedInstance().start(completionHandler: nil)

        // splash 화면 1초간 보여주기
        sleep(1)

        // 카카오 로그인 및 공유 기능을 위한 카카오 API 연동
        KakaoSDKCommon.initSDK(appKey: kakapAppKey)

        // 구글 로그인
        GIDSignIn.sharedInstance().clientID = googleClientId
        
        // 네이버 로그인
        let naverInstance = NaverThirdPartyLoginConnection.getSharedInstance()
        // 네이버 앱으로 인증하는 방식을 활성화
        naverInstance?.isNaverAppOauthEnable = true
        // SafariViewController에서 인증하는 방식을 활성화
        naverInstance?.isInAppOauthEnable = true
        // 인증 화면을 iPhone의 세로 모드에서만 사용하기
        naverInstance?.isOnlyPortraitSupportedInIphone()
        
        // 네이버 아이디로 로그인하기 설정
        // 애플리케이션을 등록할 때 입력한 URL Scheme
        naverInstance?.serviceUrlScheme = naverUrlScheme
        // 애플리케이션 등록 후 발급받은 클라이언트 아이디
        naverInstance?.consumerKey = naverCliendId
        // 애플리케이션 등록 후 발급받은 클라이언트 시크릿
        naverInstance?.consumerSecret = naverSecret
        // 애플리케이션 이름
        naverInstance?.appName = naverAppName
        
        // AWS SNS Configure
        UNUserNotificationCenter.current().delegate = self
        let credentialsProvider = AWSCognitoCredentialsProvider(regionType: .APNortheast2,
           identityPoolId: cognitoPoolId)
        let configuration = AWSServiceConfiguration(region: .APNortheast2, credentialsProvider: credentialsProvider)
        AWSServiceManager.default().defaultServiceConfiguration = configuration
        
        if AccountManager.shared.getAutoLoginState() {
            AccountManager.shared.tryAutoLogin()
        }
    
    }
    // MARK: - AWS APNS
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var myToken = ""
        for index in 0..<deviceToken.count {
            myToken += String(format: "%02.2hhx", arguments: [deviceToken[index]])
        }
        print("My Token: ", myToken)
        // 토큰은 UserDefaults에 저장
//        UserDefaults.standard.set(myToken, forKey: "deviceTokenForSNS")
        /// Create a platform endpoint. In this case, the endpoint is a
        /// device endpoint ARN
        let sns = AWSSNS.default()
        guard let request = AWSSNSCreatePlatformEndpointInput() // AWS - SNS - Mobile - Push Notifications
        else { return }
        request.token = myToken
        request.platformApplicationArn = SNSPlatformApplicationArn
        // 앞서 지정한 Platform Application Arn에 endPoint등록(저장)
        sns.createPlatformEndpoint(request).continueWith(executor: AWSExecutor.mainThread(),
                                                         block: { (task: AWSTask!) -> AnyObject? in
            if task.error != nil {
                print("Error: \(String(describing: task.error))")
                return nil
            }
            let createEndpointResponse = task.result! as AWSSNSCreateEndpointResponse
            guard let endpointArnForSNS = createEndpointResponse.endpointArn
            else { return nil}
            // 기기당 개별 Arn
            print("endpointArn: \(endpointArnForSNS)")
            // 개별 Arn UserDefaults에 저장
//            UserDefaults.standard.set(endpointArnForSNS, forKey: "endpointArnForSNS")
            // 앞서 지정한 Topic에 create Subscription
            let subscribeInput = AWSSNSSubscribeInput()
            subscribeInput?.topicArn = topicArn
            subscribeInput?.endpoint = endpointArnForSNS
            subscribeInput?.protocols = "application"
            sns.subscribe(subscribeInput!).continueWith { (task) -> Any? in
                if task.error != nil {
                    print(task.error ?? "")
                    return nil
                }
                print("Creating Subscription Complete!")
                guard let subscriptionConfirmInput = AWSSNSConfirmSubscriptionInput()
                else { return nil }
                subscriptionConfirmInput.token = myToken
                subscriptionConfirmInput.topicArn = topicArn
                sns.confirmSubscription(subscriptionConfirmInput).continueWith { (task) -> Any? in
                    if task.error != nil {
                        // 왜 error가 있어야 confirm 인지..;;
                        print("Confirmed Subscription!")
                        return nil
                    }
                    return nil
                }
                return nil
            }
            return nil
        })
    }
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error.localizedDescription)
    }
    
    // Called when a notification is delivered to a foreground app.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("User Info = ", notification.request.content.userInfo)
        completionHandler([.alert, .badge, .sound])
    }
    // Called to let your app know which action was selected by the user for a given notification.
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("User Info = ", response.notification.request.content.userInfo)
        completionHandler()
    }

    // MARK: - Check version
    private func checkRegularTestAndUpdate() {

        NetworkManager.getVersionData { [weak self] (result) in
            switch result {
            case .success(let data):
                print(data)
                guard let startTime = data.data?.regularTestStartDate,
                      let endTime = data.data?.regularTestEndDate,
                      let minVersion = data.data?.minVersion,
                      let marketVersion = data.data?.marketVersion else {
                    self?.applicationConfigure()
                    return }
                
                let dateformatter = Formatter.Date.checkUpdateFormatter
                let nowDateString = dateformatter.string(from: Date())
                let startDateString = startTime.replacingOccurrences(of: "T", with: " ")
                let endDateString = endTime.replacingOccurrences(of: "T", with: " ")
                
                let nowDate = dateformatter.date(from: nowDateString)
                let startDate = dateformatter.date(from: startDateString)
                let endDate = dateformatter.date(from: endDateString)
                // 우선 임시로 force처리
                if nowDate! >= startDate! && nowDate! <= endDate! {
                    // 정기점검 시간에 들어있는 경우
                    let title = "안정적인 서비스 제공을 위해\n시스템을 점검하고 있습니다"
                    let message = "점검시간\n\(startDateString) ~\n \(endDateString)"
                    
                    PopupManager.shared.showPopup(mainStr: title, subStr: message,
                                                  positiveButtonOption: ButtonOption(title: "확인", handler: {
                                                    // 아무것도 못하기..
                                                    UIControl().sendAction(#selector(URLSessionTask.suspend),
                                                                           to: UIApplication.shared, for: nil)
                                                  }), enableBackgroundTouchOut: false)
                } else {
                    guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
                    else {
                        self?.applicationConfigure()
                        return }
                    AccountManager.shared.lastVersion = marketVersion
                    if self?.checkNeedForceUpdate(currentVersion: version, minVersion: minVersion) ?? true {
                        // 최소지원 버전보다 낮을 경우
                        let title = "업데이트가 필요해요"
                        let message = "현재 사용하시는 버전은\n더 이상 사용할 수 가 없어요\n안정적이고 편리한 이용을 위해\n" +
                                        "업데이트를 해주세요."
                        PopupManager.shared.showPopup(mainStr: title, subStr: message,
                                                      positiveButtonOption: ButtonOption(title: "업데이트 하러가기", handler: {
                                                        // 강제 업데이트
                                                        self?.updateVersion(version: "")
                                                      }), enableBackgroundTouchOut: false)
                    } else {
//                        guard let marketVersion = recentVersion?.components(separatedBy: "-")[0] else {return}
                        if version == marketVersion {
                            // 최신 버젼인 경우
                            AccountManager.shared.isRecentVersion = true
                            self?.applicationConfigure()
                        } else {
                            // 최소 지원버전은 충족하지만 업데이트가 필요한 경우
//                            AccountManager.shared.isRecentVersion = false // -> 출시전에만 우선 임시로 주석처리
                            AccountManager.shared.isRecentVersion = true
                            let checkUpdateAlert = UserDefault.checkUpdateAlert
                            let checkAlert = UserDefaults.standard.string(forKey: checkUpdateAlert)
                            if checkAlert == nil || (checkAlert != marketVersion) {
                                let title = "지금 업데이트 하시면\n더 편하고 안정적으로 이용할 수 있어요"
                                PopupManager.shared.showPopup(
                                    mainStr: title,
                                    positiveButtonOption: ButtonOption(title: "업데이트 하러가기") {
                                        self?.updateVersion(version: "") // 수정필요.
                                    },
                                    negativeButtonOption: ButtonOption(title: "다음에 업데이트") {
                                        UserDefaults.standard.setValue(marketVersion, forKey: checkUpdateAlert)
                                        self?.applicationConfigure()
                                    },
                                    enableBackgroundTouchOut: false
                                )
                            } else {
                                // 이미 업데이트 권유 알림을 받은 경우
                                self?.applicationConfigure()
                            }
                            
                        }
                    }
                }
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "버전 관련 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인") { },
                                              enableBackgroundTouchOut: true)
            }
        }
    }
    
    private func checkNeedForceUpdate(currentVersion: String, minVersion: String) -> Bool {
        // 0.0.0
        let currentVersionArr = currentVersion.components(separatedBy: ".")
        let minVersionArr = minVersion.components(separatedBy: ".")
        if currentVersion == minVersion { return false }
        if currentVersionArr[0] <= minVersionArr[0] {
            if currentVersionArr[0] < minVersionArr[0] {
                return true
            } else {
                if currentVersionArr[1] <= minVersionArr[1] {
                    if currentVersionArr[1] < minVersionArr[1] {
                        return true
                    } else {
                        if currentVersionArr[2] < minVersionArr[2] {
                            return true
                        } else {
                            return false
                        }
                    }
                }
            }
        }
        
        return false
    }
    
    private func updateVersion(version: String) {
        if isDev {
//            let downloadUrl = "itms-services://?action=download-manifest&url="
//            let target = "https://kkpoint-ios.s3.ap-northeast-2.amazonaws.com/\(version)/manifest.plist"
//            let url = "\(downloadUrl)\(target)"
//            if let url = URL(string: url) {
//                UIApplication.shared.open(url)
//            }
        } else {
            
        }
        
    }

    // MARK: - 런치스크린, 처음 뷰 로딩 이후 앱 전체의 지원방향을 설정하는 부분
    /// info.plist로 LaunchScreen 세로모드.
    /// 여기서 네비게이션 첫 화면 세로모드.
    /// 이후 네비게이션 메인 뷰컨에서 네비게이션 세로모드 적용한 후에는, 추후에 영상 전체화면에서 가로모드를 사용하기위해 .allButUpDown으로 바뀔 예정.
    var supportedInterfaceOrientation: UIInterfaceOrientationMask = .portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return supportedInterfaceOrientation
    }

    // MARK: - 네이버, 카카오 앱 로그인시 설정
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        if let naverInstance = NaverThirdPartyLoginConnection.getSharedInstance() {
            if naverInstance.isNaverThirdPartyLoginAppschemeURL(url) {
                NaverThirdPartyLoginConnection.getSharedInstance()?.application(app, open: url, options: options)
                return true
            }
        }
        if AuthApi.isKakaoTalkLoginUrl(url) {
            return AuthController.handleOpenUrl(url: url)
        }
        return false
    }
}
