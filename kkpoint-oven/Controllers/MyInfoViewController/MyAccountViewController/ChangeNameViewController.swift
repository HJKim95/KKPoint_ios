//
//  ChangeNameViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/26.
//

import UIKit
import SnapKit

class ChangeNameViewController: UIViewController, UITextFieldDelegate {
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "내 정보 수정"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        navBar.sendButton.alpha = 1
        navBar.sendButton.setTitle("완료", for: .normal)
        navBar.sendButton.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.5)
        navBar.sendButton.titleLabel?.textAlignment = .right
        navBar.sendButton.addTarget(self, action: #selector(changeName), for: .touchUpInside)
        return navBar
    }()
    
    private lazy var nameTextField: UITextField = {
        let textfield = UITextField()
        textfield.text = AccountManager.shared.user.name
        textfield.placeholder = AccountManager.shared.user.name
        textfield.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        textfield.textColor = UIColor(named: "primary02")
        let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 64))
        textfield.leftView = leftPaddingView
        textfield.leftViewMode = .always
        textfield.backgroundColor = UIColor(named: "elavated")
        textfield.becomeFirstResponder()
        textfield.delegate = self
        textfield.addTarget(self, action: #selector(textFieldDidChange(_:)), for: .editingChanged)
        textfield.autocorrectionType = .no
        textfield.autocapitalizationType = .none
        // 커서 색 설정
        UITextField.appearance().tintColor = Resource.Color.orange06
        return textfield
    }()
    
    private lazy var eraseImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "iconClose24")
        imageview.contentMode = .scaleAspectFit
        imageview.alpha = 1
        imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(eraseText)))
        imageview.isUserInteractionEnabled = true
        return imageview
    }()
    
    private let adviceLabel: UILabel = {
        let label = UILabel()
        label.textColor = Resource.Color.orange06
        label.textAlignment = .left
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupLayouts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        view.addSubview(customNavigationBar)
        view.addSubview(nameTextField)
        view.addSubview(eraseImageView)
        view.addSubview(adviceLabel)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        nameTextField.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(72)
        }
        
        eraseImageView.snp.makeConstraints { (make) in
            make.centerY.equalTo(nameTextField.snp.centerY)
            make.right.equalToSuperview().offset(-16)
            make.width.height.equalTo(24)
        }
        
        adviceLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameTextField.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(18.5)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(16)
        }
    }

    @objc private func textFieldDidChange(_ textField: UITextField) {
        guard let count = textField.text?.count else { return }
        if count > 15 {
            textField.deleteBackward()
            adviceLabel.text = "이름은 최대 15자까지 가능합니다"
            customNavigationBar.sendButton.isEnabled = true
            return
        }
        customNavigationBar.sendButton.isEnabled = true
        if textField.text == "" || count < 2 {
            customNavigationBar.sendButton.isEnabled = false
            eraseImageView.alpha = 0
            adviceLabel.text = "이름은 최소 2자 이상 적어주세요"
        } else {
            // 닉네임은 최소2자 이상 최대 15자까지.
            if textField.text == AccountManager.shared.user.name || count > 15 {
                customNavigationBar.sendButton.isEnabled = false
                if count > 15 {
                    adviceLabel.text = "이름은 최대 15자까지 가능합니다"
                    customNavigationBar.sendButton.isEnabled = true
                }
            } else {
                adviceLabel.text = ""
            }
            eraseImageView.alpha = 1
        }
        
        adviceLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
    }
    
    private func checkNamePolicy(text: String) -> Bool {
        // String -> Array
        let arr = Array(text)
        // 정규식 pattern. 한글, 영어, 숫자, 밑줄(_)만 있어야함
        let pattern = "^[가-힣ㄱ-ㅎㅏ-ㅣa-zA-Z0-9_]$"
        if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
            var index = 0
            while index < arr.count { // string 내 각 문자 하나하나 마다 정규식 체크 후 충족하지 못한것은 제거.
                let results = regex.matches(in: String(arr[index]), options: [], range: NSRange(location: 0, length: 1))
                if results.count == 0 {
                    return false
                } else {
                    index += 1
                }
            }
        }
        return true
    }
    
    @objc private func eraseText() {
        
        nameTextField.text = ""
        eraseImageView.alpha = 0
        customNavigationBar.sendButton.isEnabled = false
    }
    
    @objc private func changeName() {
        guard let text = nameTextField.text else {return}
        if !checkNamePolicy(text: text) {
            PopupManager.shared.showPopup(mainStr: "이름에는 '한글,영어,숫자,_'만 허용됩니다.",
                                          positiveButtonOption: ButtonOption(title: "확인", handler: {
                
            }), enableBackgroundTouchOut: true)
            return
        }
        var isAlarm = true
        PermissionManager.getDevicePermission {
            isAlarm = true
        } isOffHandler: {
            isAlarm = false
        }

        let accountModel = AccountModel(socialType: AccountManager.shared.user.socialType.rawValue,
                                        name: self.nameTextField.text,
                                        email: AccountManager.shared.user.email,
                                        enableAlarm: isAlarm,
                                        enableAlarmDate: PermissionManager.getUserDefaultsDate())
        
        NetworkManager.updateMyInfo(parameters: accountModel.dictionary) { [weak self] (result) in
            switch result {
            case .success(let data):
                print(data)
                AccountManager.shared.user.name = self?.nameTextField.text
                self?.view.endEditing(true)
                self?.navigationController?.popViewController(animated: true)
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "이름을 변경하는 과정에서 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
    }
}
