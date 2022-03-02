//
//  CSViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/08.
//

import UIKit
import SnapKit

class CSViewController: UIViewController, UITextViewDelegate {
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "문의하기"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        navBar.sendButton.alpha = 1
        navBar.sendButton.addTarget(self, action: #selector(sendEmail), for: .touchUpInside)
        navBar.backButton.removeTarget(nil, action: nil, for: .allEvents) // 기존 pop 삭제
        navBar.backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return navBar
    }()
    
    let userContentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "elavated")
        return view
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = AccountManager.shared.user.name
        label.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        label.textColor = UIColor(named: "secondary01")
        label.textAlignment = .left
        return label
    }()
    
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = AccountManager.shared.user.email
        label.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
        label.textColor = UIColor(named: "primary02")
        label.textAlignment = .left
        return label
    }()
    
    lazy var csTextView: UITextView = {
        let textview = UITextView()
        textview.backgroundColor = UIColor(named: "base")
        // 커서 색 설정
        UITextView.appearance().tintColor = Resource.Color.orange06
        textview.isScrollEnabled = true
        textview.delegate = self
        textview.contentInset = UIEdgeInsets(top: 10, left: -5, bottom: 0, right: 0)
        textview.customFont(fontName: .NanumSquareRoundR, size: 18, letterSpacing: -0.3, lineSpacing: 4)
        textview.autocorrectionType = .no
        textview.autocapitalizationType = .none
        return textview
    }()
    
    lazy var placeHolderLabel: UILabel = {
        let label = UILabel()
        label.text = "문의할 내용을 적어주세요."
        label.textColor = UIColor(named: "disable")
        label.customFont(fontName: .NanumSquareRoundR, size: 18, letterSpacing: -0.3)
        label.sizeToFit()
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(touchPlaceHolder)))
        label.isUserInteractionEnabled = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        setupLayouts()
    }

    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        view.addSubview(userContentView)
        userContentView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(56)
        }
        userContentView.addSubview(nameLabel)
        userContentView.addSubview(emailLabel)
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(16)
        }
        
        emailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(nameLabel.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.height.equalTo(22)
        }
        
        view.addSubview(csTextView)
        csTextView.snp.makeConstraints { (make) in
            make.top.equalTo(userContentView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
        
        view.addSubview(placeHolderLabel)
        placeHolderLabel.snp.makeConstraints { (make) in
            make.top.equalTo(csTextView.snp.top)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc private func touchPlaceHolder() {
        if placeHolderLabel.alpha == 1 && csTextView.text.isEmpty {
            placeHolderLabel.alpha = 0
            csTextView.becomeFirstResponder()
        }
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyBoardHeight = keyboardRectangle.height
            csTextView.snp.remakeConstraints { (make) in
                make.top.equalTo(userContentView.snp.bottom)
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-keyBoardHeight)
            }
        }
    }
    
    @objc private func goBack() {
        view.endEditing(true)
        let popupColor = UIColor(named: "elavated")!
        let unableColor = UIColor.black.withAlphaComponent(0.7)
        if csTextView.text.isEmpty {
            self.navigationController?.popViewController(animated: true)
        } else {
            let mainStr = "작성하시던 내용이 삭제됩니다"
            let subStr = "문의하기 페이지에서 나가시겠습니까?"
            PopupManager.shared.showPopup(mainStr: mainStr, subStr: subStr,
                                          positiveButtonOption: ButtonOption(title: "네", handler: {
                                            self.navigationController?.popViewController(animated: true)
                                          }),
                                          negativeButtonOption: ButtonOption(title: "아니오", handler: {
                                            
                                          }),
                                          backgroundColor: BackgroundColorOption(popupViewColor: popupColor,
                                                                                 unableViewColor: unableColor),
                                          enableBackgroundTouchOut: true)
        }
    }
    
    func popViewControllerTwice() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    @objc private func sendEmail() {
        view.endEditing(true)
        let popupColor = UIColor(named: "elavated")!
        let unableColor = UIColor.black.withAlphaComponent(0.7)
        LottieManager.shared.startReload()
        NetworkManager.postCSData(content: csTextView.text) { (result) in
            switch result {
            case .success(let data):
                print(data)
                LottieManager.shared.stopReload()
                let mainStr = "문의가 등록되었습니다."
                let subStr = "최대한 빠른시일 내\n답변드릴게요"
                PopupManager.shared.showPopup(mainStr: mainStr, subStr: subStr,
                                              positiveButtonOption: ButtonOption(title: "홈으로 가기", handler: {
                                                self.popViewControllerTwice()
                                              }),
                                              backgroundColor: BackgroundColorOption(popupViewColor: popupColor,
                                                                                     unableViewColor: unableColor),
                                              enableBackgroundTouchOut: false)
            case .failure(let error):
                print(error)
                LottieManager.shared.stopReload()
                PopupManager.shared.showPopup(mainStr: "문의사항을 보내는데 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
    }

    func textViewDidBeginEditing(_ textView: UITextView) {
        if placeHolderLabel.alpha == 1 && csTextView.text.isEmpty {
            placeHolderLabel.alpha = 0
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        if !textView.text.isEmpty {
            csTextView.textColor = UIColor(named: "secondary02")
            
            let font = Resource.Font.NanumSquareRoundR.rawValue
            let letterSpace = -0.3
            let style = NSMutableParagraphStyle()
            style.lineSpacing = 4
            csTextView.typingAttributes = [NSAttributedString.Key.kern: letterSpace,
                                           NSAttributedString.Key.font: UIFont(name: font, size: 18)!,
                                           NSAttributedString.Key.paragraphStyle: style]
            
            self.customNavigationBar.sendButton.isEnabled = true
        } else {
            self.customNavigationBar.sendButton.isEnabled = false
        }
    }

}
