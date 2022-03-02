//
//  MyAccountViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class MyAccountViewController: UIViewController {
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "내 정보"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        return navBar
    }()

    private let myNameLabel: UILabel = {
        let label = UILabel()
        label.text = AccountManager.shared.user.name
        label.textColor = UIColor(named: "primary02")
        label.textAlignment = .left
        return label
    }()
    
    private lazy var changeNameButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("수정", for: .normal)
        button.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(Resource.Color.orange06, for: .normal)
        button.addTarget(self, action: #selector(changeName), for: .touchUpInside)
        return button
    }()

    private let loginNameLabel: UILabel = {
        let label = UILabel()
        label.text = AccountManager.shared.user.socialType.rawValue
        label.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        label.textColor = UIColor(named: "primary02")
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그아웃", for: .normal)
        button.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        button.contentHorizontalAlignment = .right
        button.setTitleColor(Resource.Color.orange06, for: .normal)
        button.addTarget(self, action: #selector(pressLogout), for: .touchUpInside)
        return button
    }()

    private let pushNotiLabel: UILabel = {
        let label = UILabel()
        label.text = "앱 푸시 수신 동의"
        label.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        label.textColor = UIColor(named: "primary02")
        label.sizeToFit()
        label.textAlignment = .left
        return label
    }()

    private let pushDateLabel: UILabel = {
        let label = UILabel()
        label.text = "YY.MM.DD"
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        label.textColor = UIColor(named: "primary02")
        label.textAlignment = .right
        label.sizeToFit()
        return label
    }()

    private lazy var pushSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.onTintColor = Resource.Color.orange01
        mySwitch.thumbTintColor = Resource.Color.orange06
        mySwitch.addTarget(self, action: #selector(onClickSwitch(sender:)), for: .valueChanged)
        return mySwitch
    }()
    
    private lazy var revokeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("탈퇴하기", for: .normal)
        button.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        button.contentHorizontalAlignment = .left
        button.titleLabel?.sizeToFit()
        button.setTitleColor(UIColor(named: "primary02"), for: .normal)
        button.addTarget(self, action: #selector(revokeAccount), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인 하세요.", for: .normal)
        button.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 16, letterSpacing: -1)
        button.setTitleColor(Resource.Color.white00, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.backgroundColor = Resource.Color.orange06
        button.addTarget(self, action: #selector(showLogin), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "elavated")
        setupLayouts()
        // 처음 뷰 로드할 때 권한 체크.
        checkPermissionChange()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // 포그라운드 돌아오는거 감지
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionChangeForObjC),
                                                   name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.addObserver(self, selector: #selector(checkPermissionChangeForObjC),
                                                   name: UIApplication.willEnterForegroundNotification, object: nil)
        }
        // 내정보에서 로그인, 로그아웃, 회원가입 감지
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkLoginAndLayout),
                                               name: Notification.Login.checkLogin,
                                               object: nil)
        
        myNameLabel.text = AccountManager.shared.user.name
        myNameLabel.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        checkLoginAndLayout()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AdiscopeManager.shared.showInterStitial()
    }
    
    /// 옵저버 없애기
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: Notification.Login.checkLogin, object: nil)
        if #available(iOS 13.0, *) {
            NotificationCenter.default.removeObserver(self, name: UIScene.willEnterForegroundNotification, object: nil)
        } else {
            NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification,
                                                      object: nil)
        }
    }
    /// 포그라운드 돌아왔을 때 권한 체크.
    @objc func checkPermissionChangeForObjC() {
        checkPermissionChange()
    }
    /// 저번이랑 알람 권한 달라진건 없는지 체크한다. + 디바이스와 버튼 UI의 상태가 같게 세팅
    private func checkPermissionChange() {
        let userDefaults: Bool = PermissionManager.getUserDefaults()
        PermissionManager.getDevicePermission { [weak self] in // 디바이스 권한 true
            if !userDefaults { // 하지만 앱 종료하기 전엔 false 였는데..
                // 날짜 및 UserDefaults 갱신.
                PermissionManager.setUserDefaultsDateUseDate(date: Date())
                PermissionManager.setUserDefaults(bool: true)
            }
            DispatchQueue.main.async {
                self?.switchOn()
            }
        } isOffHandler: { [weak self] in  // 디바이스 권한 false
            if userDefaults { // 하지만 앱 종료하기 전엔 true 였는데..
                // 날짜 및 UserDefaults 갱신.
                PermissionManager.setUserDefaultsDateUseDate(date: Date())
                PermissionManager.setUserDefaults(bool: false)
            }
            DispatchQueue.main.async {
                self?.switchOff()
            }
        }
        DispatchQueue.main.async { [weak self] in
            // 날짜 띄우기
            self?.pushDateLabel.text = PermissionManager.getUserDefaultsDate()
            self?.pushDateLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        }
    }

    private func setupLayouts() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        view.addSubview(customNavigationBar)
        view.addSubview(myNameLabel)
        view.addSubview(changeNameButton)
        view.addSubview(loginNameLabel)
        view.addSubview(logoutButton)
        view.addSubview(pushNotiLabel)
        view.addSubview(pushDateLabel)
        view.addSubview(pushSwitch)
        view.addSubview(revokeButton)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        changeNameButton.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(22)
            make.right.equalToSuperview().offset(-19)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }
        
        myNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(changeNameButton.snp.left)
            make.height.equalTo(17)
        }

        logoutButton.snp.makeConstraints { (make) in
            make.top.equalTo(myNameLabel.snp.bottom).offset(46)
            make.right.equalToSuperview().offset(-19)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }

        loginNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(myNameLabel.snp.bottom).offset(47)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(logoutButton.snp.left)
            make.height.equalTo(17)
        }

        pushNotiLabel.snp.makeConstraints { (make) in
            make.top.equalTo(loginNameLabel.snp.bottom).offset(47)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(17)
        }

        pushSwitch.snp.makeConstraints { (make) in
            make.top.equalTo(loginNameLabel.snp.bottom).offset(44)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.width.equalTo(40)
        }

        pushDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(loginNameLabel.snp.bottom).offset(46)
            make.left.equalTo(pushNotiLabel.snp.right)
            make.right.equalTo(pushSwitch.snp.left).offset(-14)
            make.height.equalTo(20)
        }

        revokeButton.snp.makeConstraints { (make) in
            make.top.equalTo(pushNotiLabel.snp.bottom).offset(47)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(17)
        }
    }
    
    private func switchOn() {
        self.pushSwitch.thumbTintColor = Resource.Color.orange06
        self.pushSwitch.isOn = true
    }
    private func switchOff() {
        self.pushSwitch.thumbTintColor = nil
        self.pushSwitch.isOn = false
    }
    
    @objc func checkLoginAndLayout() {
        if AccountManager.shared.isLogged {
            loginConstraint()
            myNameLabel.text = AccountManager.shared.user.name
            myNameLabel.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
            loginNameLabel.text = AccountManager.shared.user.socialType.rawValue
            loginNameLabel.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
            checkPermissionChange()
        } else {
            logoutConstraint()
        }
    }
    
    private func logoutConstraint() {
        myNameLabel.alpha = 0
        changeNameButton.alpha = 0
        loginNameLabel.alpha = 0
        logoutButton.alpha = 0
        revokeButton.alpha = 0
        view.addSubview(loginButton)
        pushNotiLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(17)
        }
        pushSwitch.snp.remakeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(20)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.width.equalTo(40)
        }
        pushDateLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(22)
            make.right.equalTo(pushSwitch.snp.left).offset(-14)
            make.height.equalTo(20)
        }
        loginButton.snp.makeConstraints { (make) in
            make.top.equalTo(pushNotiLabel.snp.bottom).offset(24)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(50)
        }
    }
    
    private func loginConstraint() {
        myNameLabel.alpha = 1
        changeNameButton.alpha = 1
        loginNameLabel.alpha = 1
        logoutButton.alpha = 1
        revokeButton.alpha = 1
        loginButton.alpha = 0
        changeNameButton.snp.remakeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(22)
            make.right.equalToSuperview().offset(-19)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }
        myNameLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(changeNameButton.snp.left)
            make.height.equalTo(17)
        }
        logoutButton.snp.remakeConstraints { (make) in
            make.top.equalTo(myNameLabel.snp.bottom).offset(46)
            make.right.equalToSuperview().offset(-19)
            make.width.equalTo(80)
            make.height.equalTo(20)
        }
        loginNameLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(myNameLabel.snp.bottom).offset(47)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(17)
        }
        pushNotiLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(loginNameLabel.snp.bottom).offset(47)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(17)
        }
        pushSwitch.snp.remakeConstraints { (make) in
            make.top.equalTo(loginNameLabel.snp.bottom).offset(44)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.width.equalTo(40)
        }
        pushDateLabel.snp.remakeConstraints { (make) in
            make.top.equalTo(loginNameLabel.snp.bottom).offset(46)
            make.right.equalTo(pushSwitch.snp.left).offset(-14)
            make.height.equalTo(20)
        }
        revokeButton.snp.remakeConstraints { (make) in
            make.top.equalTo(pushNotiLabel.snp.bottom).offset(47)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(17)
        }
    }
    
    func popViewControllerTwice() {
        NotificationCenter.default.post(name: Notification.Login.checkLogin, object: self)
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    @objc private func changeName() {
        let viewcontroller = ChangeNameViewController()
        navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @objc private func pressLogout() {
        if AccountManager.shared.isLogged {
            ToastManager.showToast(message: "로그아웃 됩니다")
            AccountManager.shared.logout()
            popViewControllerTwice()
        }
    }
    @objc private func revokeAccount() {
        let alertTitle = "탈퇴하시면 이용내역이 삭제되고,\n적립하신 포인트도 소멸된답니다.\n\n 그래도 탈퇴하시겠어요?"
        PopupManager.shared.showPopup(mainStr: alertTitle,
                                      positiveButtonOption: ButtonOption(title: "네 탈퇴할게요", handler: {
                                        NetworkManager.deleteMyInfo { [weak self] (result) in
                                            switch result {
                                            case .success(let data):
                                                print(data)
                                                ToastManager.showToast(message: "요청하신 탈퇴가 처리되었어요 다시만나길 바랄게요")
                                                AccountManager.shared.logout()
                                                self?.popViewControllerTwice()
                                            case .failure(let error):
                                                print(error)
                                                PopupManager.shared.showPopup(
                                                    mainStr: "회원탈퇴 처리중 오류가 발생하였습니다.",
                                                    positiveButtonOption: ButtonOption(title: "확인") {}
                                                )
                                            }
                                        }
                                      }), negativeButtonOption: ButtonOption(title: "안할게요.", handler: {
                                        
                                      }), enableBackgroundTouchOut: true)
    }
    
    @objc func onClickSwitch(sender: UISwitch) {
        if PermissionManager.isFirstAlertSet() {
            PermissionManager.alertPermissionPopup { [weak self] in
                self?.checkPermissionChange()
            }
        } else {
            // 이미 권한 선택을 했었을 경우,
            // 디바이스와 상태같게
            checkPermissionChange()
            // 설정창 이동 팝업띄우기
            PopupManager.shared.showPopup(
                mainStr: "안내",
                subStr: "알람 권한은 기기 설정창에서 변경해주세요.",
                positiveButtonOption: ButtonOption(title: "설정창으로 가기") {
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                },
                negativeButtonOption: ButtonOption(title: "취소") {}
            )
        }
    }
    @objc private func showLogin() {
        let loginVC = LoginViewController()
        if #available(iOS 13.0, *) {
            loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
            present(loginVC, animated: true)
        } else {
            present(loginVC, animated: true)
        }
    }
}
