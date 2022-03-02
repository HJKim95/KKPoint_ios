//
//  RegisterViewController.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/19.
//

import UIKit
import NaverThirdPartyLogin // 네이버 로그인

class RegisterViewController: UIViewController {
    // MARK: - Params
    var request: SignUpRequest!
    
    var loginInstance: NaverThirdPartyLoginConnection?
    
    // MARK: - Views
    private let xButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "iconCloseB24"), for: .normal)
        $0.addTarget(self, action: #selector(tabXbutton), for: .touchUpInside)
    }
    private let titleLabel = UILabel().then {
        $0.text = "회원가입"
        $0.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary01")
    }
    
    // KK포인트 약관
    private let pointCheckButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btnCheckN"), for: .normal)
        $0.setImage(UIImage(named: "btnCheckS"), for: .selected)
        $0.setImage(UIImage(named: "btnCheckS"), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
    }
    private let pointTerms = UILabel().then {
        $0.text = "[필수] KK포인트 약관"
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    private let pointMoreSee: UIButton = UIButton(type: .system).then {
        $0.setTitle("보기", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        $0.setTitleColor(UIColor(named: "secondary01"), for: .normal)
        $0.addTarget(self, action: #selector(moreSee(_:)), for: .touchUpInside)
        $0.tag = 0
    }
    // 개인정보처리방침
    private let privacyCheckButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btnCheckN"), for: .normal)
        $0.setImage(UIImage(named: "btnCheckS"), for: .selected)
        $0.setImage(UIImage(named: "btnCheckS"), for: .highlighted)
        $0.adjustsImageWhenHighlighted = false
        $0.addTarget(self, action: #selector(check(_:)), for: .touchUpInside)
    }
    private let privacyTerms = UILabel().then {
        $0.text = "[필수] 개인정보처리방침"
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    private let privacyMoreSee: UIButton = UIButton(type: .system).then {
        $0.setTitle("보기", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        $0.setTitleColor(UIColor(named: "secondary01"), for: .normal)
        $0.addTarget(self, action: #selector(moreSee(_:)), for: .touchUpInside)
        $0.tag = 1
    }
    // 가입하기
    private let signup = UIButton(type: .system).then {
        $0.setTitle("가입하기", for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 16, letterSpacing: -1)
        $0.backgroundColor = Resource.Color.orange02
        $0.setTitleColor(Resource.Color.orange06, for: .normal)
        $0.addTarget(self, action: #selector(tabSignUp), for: .touchUpInside)
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
        $0.isEnabled = false
    }
    
    // MARK: - Methods
    /// 닫기버튼 클릭
    @objc func tabXbutton() {
        dismiss(animated: true) {
            let loginVC = LoginViewController()
            Utilities.topViewController()?.present(loginVC, animated: true)
        }
    }
    /// 체크버튼 클릭
    @objc func check(_ sender: UIButton) {
        sender.isSelected.toggle()
        checkDoneButtonState()
    }
    /// 보기버튼 클릭
    @objc func moreSee(_ sender: UIButton) {
        // KK포인트 약관뷰가 없음. 일단 둘다 개인정보방침 띄우기로 해놨음.
        let nextVC = PrivacyViewController()
        nextVC.modalPresentationStyle = .fullScreen
        nextVC.firstIndex = sender.tag
        nextVC.customNavigationBar.backButton.alpha = 0
        nextVC.customNavigationBar.xButton.alpha = 1
        present(nextVC, animated: true)
    }
    /// 다음버튼 활성화 여부 체크 ( 필수항목이 다 선택되었는가 )
    private func checkDoneButtonState() {
        if pointCheckButton.isSelected && privacyCheckButton.isSelected {
            signup.isEnabled = true
            signup.backgroundColor = Resource.Color.orange06
            signup.setTitleColor(Resource.Color.white00, for: .normal)
        } else {
            signup.isEnabled = false
            signup.backgroundColor = Resource.Color.orange02
            signup.setTitleColor(Resource.Color.orange06, for: .normal)
        }
    }
    /// 가입하기 버튼 클릭
    @objc func tabSignUp() {
        dismiss(animated: true) {
            NetworkManager.singUp(request: self.request) { result in
                switch result {
                case .failure(let error):
                    print(error)
                case .success(let response):
                    guard let data = response.data else { return }
                    // 계정 정보 저장
                    AccountManager.shared.setSignInOrSignUpData(socialType: self.request.socialType, data: data)
                    PermissionManager.alertToast()
                }
                // 네이버 토큰 삭제
                self.loginInstance?.requestDeleteToken()
            }
            Utilities.toHome()
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
        changeLabelSubStringColor(label: pointTerms, subStr: "[필수]")
        changeLabelSubStringColor(label: privacyTerms, subStr: "[필수]")
    }
    func setupLayout() {
        let sideMargin = 16
        view.backgroundColor = UIColor(named: "elavated")
        
        view.addSubview(xButton)
        xButton.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(sideMargin)
            $0.leading.equalToSuperview().offset(sideMargin)
            $0.width.height.equalTo(24)
        }
        view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide).offset(sideMargin + 1)
            $0.centerX.equalToSuperview()
        }
        // KK 포인트 약관
        view.addSubview(pointCheckButton)
        pointCheckButton.snp.makeConstraints {
            $0.top.equalTo(xButton.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(sideMargin)
            $0.width.height.equalTo(24)
        }
        view.addSubview(pointTerms)
        pointTerms.snp.makeConstraints {
            $0.centerY.equalTo(pointCheckButton)
            $0.leading.equalTo(pointCheckButton.snp.trailing).offset(12)
            $0.height.equalTo(20)
        }
        view.addSubview(pointMoreSee)
        pointMoreSee.snp.makeConstraints {
            $0.centerY.equalTo(pointCheckButton)
            $0.trailing.equalToSuperview().offset(-sideMargin)
            $0.height.equalTo(16)
        }
        // 개인정보처리방침
        view.addSubview(privacyCheckButton)
        privacyCheckButton.snp.makeConstraints {
            $0.top.equalTo(pointCheckButton.snp.bottom).offset(32)
            $0.leading.equalToSuperview().offset(sideMargin)
            $0.width.height.equalTo(24)
        }
        view.addSubview(privacyTerms)
        privacyTerms.snp.makeConstraints {
            $0.centerY.equalTo(privacyCheckButton)
            $0.leading.equalTo(privacyCheckButton.snp.trailing).offset(12)
            $0.height.equalTo(20)
        }
        view.addSubview(privacyMoreSee)
        privacyMoreSee.snp.makeConstraints {
            $0.centerY.equalTo(privacyCheckButton)
            $0.trailing.equalToSuperview().offset(-sideMargin)
            $0.height.equalTo(16)
        }
        // 가입하기
        view.addSubview(signup)
        signup.snp.makeConstraints {
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.height.equalTo(50)
        }
    }
}
