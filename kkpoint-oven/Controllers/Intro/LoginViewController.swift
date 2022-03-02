//
//  LoginViewController.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/18.
//

import UIKit
import KakaoSDKAuth // 카카오 로그인
import KakaoSDKUser // 카카오 유저정보 가져오기
import GoogleSignIn // 구글 로그인
import AuthenticationServices // 애플 로그인
import NaverThirdPartyLogin // 네이버 로그인
import Alamofire

class LoginViewController: UIViewController {
    // MARK: - Params
    let loginInstance = NaverThirdPartyLoginConnection.getSharedInstance()
    
    // MARK: - Views
    private let googleIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "icnJoinGoogle24")
    }
    private let kakaoIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "icnJoinKakao24")
    }
    private let naverIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "icnJoinNaver24")
    }
    private let appleIcon: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "icnJoinApple24")
    }
    // 맨 위에 제목 레이블
    private let titleLabel = UILabel().then {
        $0.text = "회원가입 / 로그인"
        $0.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary01")
    }
    // 구글 로그인 버튼
    private let google = UIButton(type: .system).then {
        $0.setTitle("구글로 로그인", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        $0.backgroundColor = Resource.Color.social_login_google
        $0.setTitleColor(Resource.Color.white00, for: .normal)
        $0.layer.cornerRadius = 23
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(tabGoogleLogin), for: .touchUpInside)
    }
    // 카카오 로그인 버튼
    private let kakao = UIButton(type: .system).then {
        $0.setTitle("카카오로 로그인", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        $0.backgroundColor = Resource.Color.social_login_kakao
        $0.setTitleColor(Resource.Color.grey08, for: .normal)
        $0.layer.cornerRadius = 23
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(tabKakaoLogin), for: .touchUpInside)
    }
    // 네이버 로그인 버튼
    private let naver = UIButton(type: .system).then {
        $0.setTitle("네이버로 로그인", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        $0.backgroundColor = Resource.Color.social_login_naver
        $0.setTitleColor(Resource.Color.white00, for: .normal)
        $0.layer.cornerRadius = 23
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(tabNaverLogin), for: .touchUpInside)
    }
    // 애플 로그인 버튼
    private let apple = UIButton(type: .system).then {
        $0.setTitle("Apple로 로그인", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        $0.backgroundColor = Resource.Color.white00
        $0.setTitleColor(Resource.Color.grey08, for: .normal)
        $0.layer.cornerRadius = 23
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Resource.Color.grey03.cgColor
        $0.layer.masksToBounds = true
        $0.addTarget(self, action: #selector(tabAppleLogin), for: .touchUpInside)
    }
   
    // 다음에 가입하기 버튼
    private let signUpNext = UIButton(type: .system).then {
        $0.setTitle("다음에 가입하기 >", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.setTitleColor(UIColor(named: "disable"), for: .normal)
        $0.addTarget(self, action: #selector(dismissToMain), for: .touchUpInside)
    }
    
    // MARK: - Methods
    /// 구글 로그인 버튼 클릭 -> Delegate로 이어짐
    @objc func tabGoogleLogin() {
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance().signIn()
    }
    /// 카카오 로그인 버튼 클릭
    @objc func tabKakaoLogin() {
        if !UserApi.isKakaoTalkLoginAvailable() {
            UserApi.shared.loginWithKakaoAccount { oauthToken, error in
                // 에러 처리
                if let error = error { print(error); return }
                // 로그인 리퀘스트 생성
                let signInRequest = SignInRequest(name: "",
                                                  accessToken: oauthToken?.accessToken ?? "",
                                                  socialType: .kakao,
                                                  uuid: "string")
                // 로그인 리퀘스트 발싸
                NetworkManager.signIn(request: signInRequest) { [weak self] result in
                    self?.signInResultProcessor(request: signInRequest, result: result)
                }
            }
        }
        
        let serviceTerms = ["tag1", "tag2"]
        UserApi.shared.loginWithKakaoTalk(serviceTerms: serviceTerms) { oauthToken, error in // 카톡으로 로그인 실시
            // 에러 처리
            if let error = error { print(error); return }
            // 로그인 리퀘스트 생성
            let signInRequest = SignInRequest(name: "",
                                              accessToken: oauthToken?.accessToken ?? "",
                                              socialType: .kakao,
                                              uuid: "string")
            // 로그인 리퀘스트 발싸
            NetworkManager.signIn(request: signInRequest) { [weak self] result in
                self?.signInResultProcessor(request: signInRequest, result: result)
            }
        }
    }
    /// 애플 로그인 버튼 클릭 -> Delegate로 이어짐
    @objc func tabAppleLogin() {
        if #available(iOS 13.0, *) {
            let appleIDProvider = ASAuthorizationAppleIDProvider()
            let request = appleIDProvider.createRequest()
            request.requestedScopes = [.fullName, .email]
            let authorizationController = ASAuthorizationController(authorizationRequests: [request])
            
            authorizationController.delegate = self
            authorizationController.presentationContextProvider = self
            authorizationController.performRequests()
        } else {
            ToastManager.showToast(message: "애플 로그인은 iOS 13.0 이상부터 가능합니다.")// , isTopWindow: false)
        }
    }
    /// 네이버 로그인 버튼 클릭 -> Delegate로 이어짐
    @objc func tabNaverLogin() {
        loginInstance?.delegate = self
        loginInstance?.requestThirdPartyLogin()
    }
    
    /// 로그인 결과 프로세서, 핸들러
    private func signInResultProcessor(request: SignInRequest, result: Result<KKPointModel<SignInResponse>, NetworkManager.NetworkError>) {
        switch result {
        case .failure(let error): // SNS 계정 인증 실패
            // 네이버 토큰 삭제 // 매번 동의하기 눌러주기 위함이였음..
            loginInstance?.requestDeleteToken()
            switch error {
            case .naverInvaildNameOrEmail:
                ToastManager.showToast(message: "네이버 로그인시 필수 약관에 동의해주세요.")
            default:
                ToastManager.showToast(message: "로그인 오류 발생")
            }
            print(error)
            
        case .success(let response): // SNS 계정 인증 성공
            guard let data = response.data else { return }
            if data.needSignUp { // 등록되지않은 유저 -> 회원가입 절차
                // 로그인시 사용했던 리퀘스트 + 앞에서 선택한 권한으로 이후 회원가입시 리퀘스트 생성
                let signUpRequest = SignUpRequest(name: request.name,
                                            accessToken: request.accessToken,
                                            socialType: request.socialType,
                                            uuid: request.uuid,
                                            enableAlert: true)
                self.dismissToRegister(request: signUpRequest)
            } else { // 등록되어있는 유저 -> 그대로 로그인
                // 계정 정보 저장
                AccountManager.shared.setSignInOrSignUpData(socialType: request.socialType, data: data)
                // 홈으로
                self.dismissToMain()
                // 네이버 토큰 삭제 // 매번 동의하기 눌러주기 위함이였음..
                loginInstance?.requestDeleteToken()
            }
        }
        AdiscopeManager.shared.adiscopeInit() // 로그인 정보를 토대로 다시 initalize
    }
    /// 다음에 가입하기 버튼 클릭 ( 그냥 홈화면으로 ) 혹은 로그인 성공
    @objc func dismissToMain() {
        Utilities.toHome()
        dismiss(animated: true) {
            PermissionManager.alertToast()
        }
    }
    /// 회원가입 화면으로
    private func dismissToRegister(request: SignUpRequest) {
        dismiss(animated: true) {
            let registerVC = RegisterViewController()
            registerVC.request = request
            registerVC.modalPresentationStyle = .fullScreen
            registerVC.loginInstance = self.loginInstance
            Utilities.topViewController()?.present(registerVC, animated: true) { }
        }
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        GIDSignIn.sharedInstance().delegate = self
        setupLayout()
    }
    /// 구독창에서 회원가입시 다시 로그인창 뜨는 버그 대응. 로그인창에 로그인감지 노티 추가
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(dismissOnNoti),
                                               name: Notification.Login.checkLogin, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self, name: Notification.Login.checkLogin, object: nil)
    }
    @objc func dismissOnNoti() {
        dismiss(animated: true)
    }
    
    private func setupLayout() {
        let sideMargin = 40
        view.backgroundColor = UIColor(named: "elavated")
        
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(40)
            $0.centerX.equalToSuperview()
        }
        view.addSubview(kakao)
        kakao.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(-27.5)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.height.equalTo(46)
        }
        kakao.addSubview(kakaoIcon)
        kakaoIcon.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(11)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
        }
        
        view.addSubview(google)
        google.snp.makeConstraints {
            $0.bottom.equalTo(kakao.snp.top).offset(-10)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.height.equalTo(46)
        }
        google.addSubview(googleIcon)
        googleIcon.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(11)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
        }
        
        view.addSubview(naver)
        naver.snp.makeConstraints {
            $0.top.equalTo(kakao.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.height.equalTo(46)
        }
        naver.addSubview(naverIcon)
        naverIcon.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(11)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
        }
        
        view.addSubview(apple)
        apple.snp.makeConstraints {
            $0.top.equalTo(naver.snp.bottom).offset(10)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.height.equalTo(46)
        }
        apple.addSubview(appleIcon)
        appleIcon.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(11)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(24)
        }
        
        view.addSubview(signUpNext)
        signUpNext.snp.makeConstraints {
            $0.top.equalTo(apple.snp.bottom).offset(10)
            $0.centerX.equalToSuperview()
        }
    }
}
// 구글 로그인 Delegate
extension LoginViewController: GIDSignInDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error?) {
        if let error = error { print(error); return }
        guard let accessToken = user.authentication.idToken, let name = user.profile.name else {
            print("Error : User Data Not Found"); return }
        let signInRequest = SignInRequest(name: name, accessToken: accessToken, socialType: .google, uuid: "string")
        NetworkManager.signIn(request: signInRequest) { [weak self] result in
            self?.signInResultProcessor(request: signInRequest, result: result)
        }
    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        // 유저가 앱에서 연결을 해제할때 수행되는 함수
        print("구글 로그아웃")
    }
}
// 애플 로그인 Delegate
@available(iOS 13.0, *)
extension LoginViewController: ASAuthorizationControllerDelegate,
                               ASAuthorizationControllerPresentationContextProviding {
    // Apple ID 연동 성공 시
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        // Apple ID
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // 이름
            let names = appleIDCredential.fullName?.description ?? "" // "givenName: 영호 familyName: 박 "
            let nameArray = names.split(separator: " ")
            var name: String = ""
            if nameArray.count > 3 {
                name = (nameArray[3] + nameArray[1]).description
            }

            // accessToken (Data -> 아스키 인코딩 -> 스트링)
            let accessToken = String(data: appleIDCredential.identityToken!, encoding: .ascii) ?? ""

            // 로그인 리퀘스트 생성
            let signInRequest = SignInRequest(name: name, accessToken: accessToken, socialType: .apple, uuid: "string")
//            // 로그인 리퀘스트 발싸
            NetworkManager.signIn(request: signInRequest) { [weak self] result in
                self?.signInResultProcessor(request: signInRequest, result: result)
            }
        default:
            break
        }
    }
    
    // context를 어디에 띄울지
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}
// 네이버 로그인 Delegate
extension LoginViewController: NaverThirdPartyLoginConnectionDelegate {
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        print("네이버 토큰 리프레쉬")
        oauth20ConnectionDidFinishRequestACTokenWithAuthCode()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        print("네이버 토큰 딜리트")
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        guard let isValidAccessToken = loginInstance?.isValidAccessTokenExpireTimeNow() else { return }
        if !isValidAccessToken {
            ToastManager.showToast(message: "네이버 로그인 오류")
            return
        }
        guard let tokenType = loginInstance?.tokenType else { return }
        guard let accessToken = loginInstance?.accessToken else { return }
        // 디테일한 회원탈퇴 처리를 위한 accessToken 저장. ( 해당 개발자 사이트의 통계 API를 정확히하려면 필요하다. 추후 필요하면 적용하자)
//        UserDefaults.standard.setValue(accessToken, forKey: "naverAccessToken")
        
        let authorization = "\(tokenType) \(accessToken)"
        let signInRequest = SignInRequest(name: "", accessToken: authorization, socialType: .naver, uuid: "string")
        NetworkManager.signIn(request: signInRequest) { [weak self] result in
            self?.signInResultProcessor(request: signInRequest, result: result)
        }
    }
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        print("[Error] :", error.localizedDescription)
    }
}
