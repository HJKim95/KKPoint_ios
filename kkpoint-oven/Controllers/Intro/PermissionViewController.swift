//
//  IntroViewController.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/18.
//

import UIKit

class PermissionViewController: UIViewController {
    // MARK: - Views
    private let titleLabel = UILabel().then {
        $0.text = "접근 권한 안내"
        $0.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary01")
    }
    private let desc = UILabel().then {
        $0.text = "KK포인트의 정상적인 서비스 이용을 위해\n반드시 필요한 권한입니다."
        $0.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3, lineSpacing: 3)
        $0.numberOfLines = 0
        $0.textColor = UIColor(named: "primary01")
        $0.textAlignment = .center
        $0.backgroundColor = UIColor(named: "permissionBgColor")
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    // 파일저장소
    private let fileCheckButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btnCheckN"), for: .normal)
        $0.setImage(UIImage(named: "btnCheckS"), for: .selected)
        $0.setImage(UIImage(named: "btnCheckS"), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
    }
    private let fileRepo = UILabel().then {
        $0.text = "[필수] 파일저장소"
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary02")
    }
    private let fileRepoDesc = UILabel().then {
        $0.text = "광고제공, 영상의 재생등을 위함"
        $0.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        $0.textColor = UIColor(named: "secondary01")
    }
    // 단말기 식별정보
    private let deviceInfoCheckButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btnCheckN"), for: .normal)
        $0.setImage(UIImage(named: "btnCheckS"), for: .selected)
        $0.setImage(UIImage(named: "btnCheckS"), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
    }
    private let deviceInfo = UILabel().then {
        $0.text = "[필수] 단말기 식별정보"
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary02")
    }
    private let deviceInfoDesc = UILabel().then {
        $0.text = "광고제공 및 CS처리"
        $0.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        $0.textColor = UIColor(named: "secondary01")
    }
    // 구분선
    private let separator: UIView = UIView().then {
        $0.backgroundColor = Resource.Color.grey01
    }
    // 앱 푸시 수신 동의
    private let agreeNotiCheckButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btnCheckN"), for: .normal)
        $0.setImage(UIImage(named: "btnCheckS"), for: .selected)
        $0.setImage(UIImage(named: "btnCheckS"), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
    }
    private let agreeNoti = UILabel().then {
        $0.text = "[선택] 앱 푸시 수신 동의"
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary02")
    }
    private let agreeNotiDesc = UILabel().then {
        $0.text = "광고제공 및 CS처리"
        $0.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        $0.textColor = UIColor(named: "secondary01")
    }
    private let agreeNotiDesc2 = UILabel().then {
        $0.text = "· 내 정보 > 내 정보 관리에서 언제든지 변경할 수 있습니다."
        $0.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        $0.numberOfLines = 0
        $0.textColor = UIColor(named: "disable")
    }
    // 확인
    private let done = UIButton(type: .system).then {
        $0.setTitle("확인 후 다음단계로", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 16, letterSpacing: -1)
        $0.backgroundColor = Resource.Color.orange02
        $0.setTitleColor(Resource.Color.orange06, for: .normal)
        $0.addTarget(self, action: #selector(dismissToLogin), for: .touchUpInside)
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
        $0.isEnabled = false
    }
    
    // MARK: - Methods
    /// 확인 후 다음단계로
    @objc func dismissToLogin() {
        dismiss(animated: true) { [weak self] in
            // 권한체크 다시 안보기
            UserDefaults.standard.setValue(true, forKey: UserDefault.permission)
            
            // 알람 수신 동의라면, 디바이스 권한 팝업 띄우기
            guard let isAgreeNoti = self?.agreeNotiCheckButton.isSelected else { return }
            if isAgreeNoti {
                PermissionManager.alertPermissionPopup {}
            }
            
            // 로그인 안되있는 상태면 로그인 띄우기
            if !AccountManager.shared.isLogged {
                let loginVC = LoginViewController()
                if #available(iOS 13.0, *) {
                    loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
                }
                Utilities.topViewController()?.present(loginVC, animated: true)
            }
        }
    }
    /// 체크버튼 클릭
    @objc func check(_ sender: UIButton) {
        sender.isSelected.toggle()
        checkDoneButtonState()
    }
    /// 다음버튼 활성화 여부 체크 ( 필수항목이 다 선택되었는가 )
    private func checkDoneButtonState() {
        if fileCheckButton.isSelected && deviceInfoCheckButton.isSelected {
            done.isEnabled = true
            done.backgroundColor = Resource.Color.orange06
            done.setTitleColor(Resource.Color.white00, for: .normal)
        } else {
            done.isEnabled = false
            done.backgroundColor = Resource.Color.orange02
            done.setTitleColor(Resource.Color.orange06, for: .normal)
        }
    }
    /// 글자 색깔 넣기
    private func changeLabelSubStringColor(label: UILabel, subStr: String, color: UIColor = Resource.Color.orange06) {
        guard let oriStr = label.text else { return }
        let attStr = NSMutableAttributedString(string: oriStr)
        attStr.addAttribute(.foregroundColor,
                            value: color,
                            range: (oriStr as NSString).range(of: subStr) )
        label.attributedText = attStr
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        changeLabelSubStringColor(label: fileRepo, subStr: "[필수]")
        changeLabelSubStringColor(label: deviceInfo, subStr: "[필수]")
        changeLabelSubStringColor(label: agreeNoti, subStr: "[선택]")
        
        // 알람 수신 권한 날짜 기본값 세팅 
        PermissionManager.setUserDefaultsDateUseDate(date: Date())
    }
    
    private func setupLayout() {
        let sideMargin: Int = 16
        view.backgroundColor = UIColor(named: "elavated")
        
        [titleLabel, desc,
         fileCheckButton, fileRepo, fileRepoDesc,
         deviceInfoCheckButton, deviceInfo, deviceInfoDesc, separator,
         agreeNotiCheckButton, agreeNoti, agreeNotiDesc, agreeNotiDesc2,
         done].forEach {
            view.addSubview($0)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(17)
            $0.centerX.equalToSuperview()
        }
        desc.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.height.equalTo(82)
        }
        // 파일 저장소
        fileCheckButton.snp.makeConstraints {
            $0.top.equalTo(desc.snp.bottom).offset(42)
            $0.leading.equalToSuperview().offset(sideMargin)
            $0.width.height.equalTo(24)
        }
        fileRepo.snp.makeConstraints {
            $0.top.equalTo(desc.snp.bottom).offset(34)
            $0.leading.equalTo(fileCheckButton.snp.trailing).offset(19)
            $0.height.equalTo(20)
        }
        fileRepoDesc.snp.makeConstraints {
            $0.top.equalTo(fileRepo.snp.bottom).offset(4)
            $0.leading.equalTo(fileRepo)
            $0.height.equalTo(16)
        }
        // 단말기 식별정보
        deviceInfoCheckButton.snp.makeConstraints {
            $0.top.equalTo(fileCheckButton.snp.bottom).offset(48)
            $0.leading.equalToSuperview().offset(sideMargin)
            $0.width.height.equalTo(24)
        }
        deviceInfo.snp.makeConstraints {
            $0.top.equalTo(fileRepoDesc.snp.bottom).offset(32)
            $0.leading.equalTo(deviceInfoCheckButton.snp.trailing).offset(19)
            $0.height.equalTo(20)
        }
        deviceInfoDesc.snp.makeConstraints {
            $0.top.equalTo(deviceInfo.snp.bottom).offset(4)
            $0.leading.equalTo(deviceInfo)
            $0.height.equalTo(16)
        }
        // 구분선
        separator.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.top.equalTo(deviceInfoDesc.snp.bottom).offset(20)
        }
        // 앱 푸시 수신 동의
        agreeNotiCheckButton.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(27)
            $0.leading.equalToSuperview().offset(sideMargin)
            $0.width.height.equalTo(24)
        }
        agreeNoti.snp.makeConstraints {
            $0.top.equalTo(separator.snp.bottom).offset(19)
            $0.leading.equalTo(agreeNotiCheckButton.snp.trailing).offset(19)
            $0.height.equalTo(20)
        }
        agreeNotiDesc.snp.makeConstraints {
            $0.top.equalTo(agreeNoti.snp.bottom).offset(4)
            $0.leading.equalTo(agreeNoti)
            $0.height.equalTo(16)
        }
        agreeNotiDesc2.snp.makeConstraints {
            $0.top.equalTo(agreeNotiDesc.snp.bottom).offset(2)
            $0.leading.equalTo(agreeNotiDesc)
            $0.trailing.equalToSuperview()
            if view.frame.width < 340 {
                $0.height.equalTo(32)
            } else {
                $0.height.equalTo(16)
            }
        }
        // 확인 후 다음단계로
        done.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(50)
        }
    }
}
