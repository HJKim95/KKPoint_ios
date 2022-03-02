//
//  Popup.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/20.
//
import UIKit
import SnapKit

class PopupManager {
    public static let shared = PopupManager()
    private var firstNum: Int = 0
    private var secondNum: Int = 0
    private var oper: Operator = arc4random() % 2 == 1 ? .add : .mul
    private var answerNum: Int = 0
    
    private var unableView = UIView()
    private var view = UIView().then {
        $0.layer.cornerRadius = 12
        $0.layer.masksToBounds = true
    }
    private var imageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
    }
    private var mainTitle = UILabel().then {
        $0.customFont(fontName: .NanumSquareRoundB, size: 17, letterSpacing: -1)
        $0.textColor = UIColor(named: "primary01")
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    private var subTitle = UILabel().then {
        $0.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "secondary02")
        $0.numberOfLines = 0
        $0.textAlignment = .center
    }
    private var positiveButton = UIButton(type: .system).then {
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        $0.layer.cornerRadius = 23
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Resource.Color.orange06.cgColor
        $0.backgroundColor = Resource.Color.orange06
        $0.setTitleColor(Resource.Color.white00, for: .normal)
        $0.tag = 11
    }
    private var negativeButton = UIButton(type: .system).then {
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        $0.layer.cornerRadius = 23
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 1
        $0.layer.borderColor = Resource.Color.orange06.cgColor
        $0.backgroundColor = UIColor(named: "elavated")
        $0.setTitleColor(Resource.Color.orange06, for: .normal)
        $0.tag = 12
    }
    private let questionContainer: UIView = UIView().then {
        $0.layer.cornerRadius = 28
        $0.layer.masksToBounds = true
        $0.backgroundColor = Resource.Color.orange06
    }
    private let firstLabel: UILabel = UILabel().then {
        $0.text = "5"
        $0.textColor = Resource.Color.white00
        $0.customFont(fontName: .NanumSquareRoundEB, size: 32, letterSpacing: -1)
    }
    private let operLabel: UILabel = UILabel().then {
        $0.text = "X"
        $0.textColor = Resource.Color.white00
        $0.customFont(fontName: .NanumSquareRoundEB, size: 32, letterSpacing: -1)
    }
    private let secondLabel: UILabel = UILabel().then {
        $0.text = "7"
        $0.textColor = Resource.Color.white00
        $0.customFont(fontName: .NanumSquareRoundEB, size: 32, letterSpacing: -1)
    }
    private let equelLabel: UILabel = UILabel().then {
        $0.text = "="
        $0.textColor = Resource.Color.white00
        $0.customFont(fontName: .NanumSquareRoundEB, size: 32, letterSpacing: -1)
    }
    private let answerLabel: UILabel = UILabel().then {
        $0.text = "?"
        $0.customFont(fontName: .NanumSquareRoundEB, size: 32, letterSpacing: -1)
        $0.textColor = Resource.Color.white00
        $0.textAlignment = .center
    }
    private let eraseButton: UIButton = UIButton().then {
        $0.setImage(UIImage(named: "btnNumberDelete32D"), for: .normal)
    }
    private let buttonsContainer: UIView = UIView()
    private let buttons: [UIButton] = [UIButton(type: .system), UIButton(type: .system), UIButton(type: .system),
                               UIButton(type: .system), UIButton(type: .system),
                               UIButton(type: .system), UIButton(type: .system), UIButton(type: .system),
                               UIButton(type: .system), UIButton(type: .system)]
    private var positiveHandler: () -> Void = {}
    private var negativeHandler: () -> Void = {}
    private var answerHandler: () -> Void = {}
    
    @objc private func exitPopup(sender: UIButton) {
        answerLabel.text = "?"
        eraseButton.setImage(UIImage(named: "btnNumberDelete32D"), for: .normal)
        [unableView, view, imageView, mainTitle, subTitle, positiveButton, negativeButton, questionContainer,
         firstLabel, operLabel, secondLabel, equelLabel, answerLabel, eraseButton, buttonsContainer].forEach {
            $0.removeFromSuperview()
         }
        buttons.forEach { $0.removeFromSuperview() }
        
        switch sender.tag {
        case 11:
            positiveHandler()
        case 12:
            negativeHandler()
        default:
            break
        }
    }
    func showPopup (mainStr: String? = nil, subStr: String? = nil, imageName: String? = nil,
                    positiveButtonOption: ButtonOption? = nil, negativeButtonOption: ButtonOption? = nil,
                    backgroundColor: BackgroundColorOption? = nil, enableBackgroundTouchOut: Bool = true) {
        // MARK: - 옵션 추출 및 레이아웃
        let sideMargin: CGFloat = 20.0
        let screenWidth = UIScreen.main.bounds.width
        guard let window = UIApplication.shared.keyWindow else { return }
        var topContraintItem: ConstraintItem = view.snp.top
        
        if let imageName = imageName {
            imageView.image = UIImage(named: imageName)
            view.addSubview(imageView)
            imageView.snp.remakeConstraints {
                $0.top.equalTo(topContraintItem)
                $0.width.equalTo(150)
                $0.height.equalTo(158)
                $0.centerX.equalToSuperview()
            }
            topContraintItem = imageView.snp.bottom
        }
        
        if let mainStr = mainStr {
            mainTitle.text = mainStr
            view.addSubview(mainTitle)
            mainTitle.snp.remakeConstraints {
                $0.top.equalTo(topContraintItem).offset(24)
                $0.leading.trailing.equalToSuperview().inset(sideMargin)
            }
            topContraintItem = mainTitle.snp.bottom
        }
        
        if let subStr = subStr {
            subTitle.text = subStr
            view.addSubview(subTitle)
            subTitle.snp.remakeConstraints {
                $0.top.equalTo(topContraintItem).offset(10)
                $0.leading.trailing.equalToSuperview().inset(sideMargin)
            }
            topContraintItem = subTitle.snp.bottom
        }
        
        if let positiveButtonOption = positiveButtonOption {
            UIView.setAnimationsEnabled(false)
            positiveButton.setTitle(positiveButtonOption.title, for: .normal)
            positiveButton.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            positiveHandler = positiveButtonOption.handler
            positiveButton.addTarget(self, action: #selector(exitPopup), for: .touchUpInside)
            view.addSubview(positiveButton)
            positiveButton.snp.remakeConstraints {
                $0.top.equalTo(topContraintItem).offset(22)
                $0.leading.trailing.equalToSuperview().inset(sideMargin)
                $0.height.equalTo(46)
            }
            topContraintItem = positiveButton.snp.bottom
        }
        
        if let negativeButtonOption = negativeButtonOption {
            UIView.setAnimationsEnabled(false)
            negativeButton.setTitle(negativeButtonOption.title, for: .normal)
            negativeButton.layoutIfNeeded()
            UIView.setAnimationsEnabled(true)
            negativeHandler = negativeButtonOption.handler
            negativeButton.addTarget(self, action: #selector(exitPopup), for: .touchUpInside)
            view.addSubview(negativeButton)
            negativeButton.snp.remakeConstraints {
                $0.top.equalTo(topContraintItem).offset(10)
                $0.leading.trailing.equalToSuperview().inset(sideMargin)
                $0.bottom.equalToSuperview().offset(-sideMargin)
                $0.height.equalTo(46)
            }
            topContraintItem = negativeButton.snp.bottom
        }
        unableView.addSubview(view)
        view.snp.remakeConstraints {
            $0.bottom.equalTo(topContraintItem).offset(sideMargin)
            $0.center.equalToSuperview()
            $0.width.equalTo(screenWidth - (sideMargin + 15) * 2)
        }
        window.addSubview(unableView)
        unableView.snp.remakeConstraints {
            $0.edges.equalToSuperview() // 화면 덮음
        }
        
        if enableBackgroundTouchOut {
            let closeButton = UIButton(type: .system).then {
                $0.tag = 0
                $0.addTarget(self, action: #selector(exitPopup), for: .touchUpInside)
            }
            unableView.addSubview(closeButton)
            closeButton.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
            unableView.sendSubviewToBack(closeButton)
        }

        if let bgC = backgroundColor {
            view.backgroundColor = bgC.popupViewColor
            unableView.backgroundColor = bgC.unableViewColor
        } else { // 기본값 : 반투명 검은색, 흰색
            view.backgroundColor = UIColor(named: "elavated")
            unableView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        }
    }
}

extension PopupManager {
    /// 보호자 확인 팝업 띄우기
    func showCheckParents(isAdvertise: Bool, answerHandler: @escaping () -> Void) {
        let viewWidth = UIScreen.main.bounds.width
        // MARK: - 문제 만들기
        firstNum = Int(arc4random() % 10)
        secondNum = Int(arc4random() % 10)
        oper = arc4random() % 2 == 1 ? .add : .mul
        switch oper {
        case .add:
            answerNum = firstNum + secondNum
        case .mul:
            answerNum = firstNum * secondNum
        }
        // MARK: - 레이아웃
        if isAdvertise {
            mainTitle.text = "클린한 광고제공을 위해"
            subTitle.text = "만 14세 미만이신가요?"
        } else {
            mainTitle.text = "보호자 확인"
            subTitle.text = "부모님 확인을 위해 정답을 입력해주세요."
        }
        imageView.image = UIImage(named: "imgPopupParents")
        
        let sideMargin: CGFloat = 20.0 * viewWidth / 360.0 // 제플린에서는 360:20 비율
        let buttonWidth: CGFloat = (viewWidth - 38 - (sideMargin * 2) - 32) / 5
        self.answerHandler = answerHandler
        buttons.forEach {
            $0.backgroundColor = UIColor(named: "elavated")
            $0.titleLabel?.customFont(fontName: .NanumSquareRoundEB, size: 18, letterSpacing: -1)
            $0.setTitleColor(UIColor(named: "secondary02"), for: .normal)
            $0.layer.borderWidth = 1
            $0.layer.borderColor = Resource.Color.grey03.cgColor
            $0.layer.cornerRadius = buttonWidth / 2
            $0.layer.masksToBounds = true
        }
        for (idx, button) in buttons.enumerated() {
            button.setTitle("\(idx + 1)", for: .normal)
        }
        buttons[9].setTitle("0", for: .normal)
        
        guard let window = UIApplication.shared.keyWindow else { return }
        window.addSubview(unableView)
        unableView.addSubview(view)
        view.addSubview(mainTitle)
        view.addSubview(subTitle)
        view.addSubview(imageView)
        view.addSubview(questionContainer)
        questionContainer.addSubview(firstLabel)
        questionContainer.addSubview(operLabel)
        questionContainer.addSubview(secondLabel)
        questionContainer.addSubview(equelLabel)
        questionContainer.addSubview(answerLabel)
        questionContainer.addSubview(eraseButton)
        view.addSubview(buttonsContainer)
        buttons.forEach {
            buttonsContainer.addSubview($0)
        }
        
        unableView.snp.makeConstraints {
            $0.top.left.right.bottom.equalToSuperview() // 화면 덮음
        }
        view.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.left.equalToSuperview().offset(sideMargin)
            $0.right.equalToSuperview().offset(-sideMargin)
            if viewWidth < 340 {
                $0.height.equalTo(338 + buttonWidth*2)
            } else {
                $0.height.equalTo(354 + buttonWidth*2)
            }
        }

        mainTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(32)
            if viewWidth < 340 {
                $0.left.equalToSuperview().offset(sideMargin-10)
                $0.right.equalToSuperview().offset(-sideMargin+10)
            } else {
                $0.left.equalToSuperview().offset(sideMargin)
                $0.right.equalToSuperview().offset(-sideMargin)
            }
            $0.height.equalTo(24)
        }

        subTitle.snp.makeConstraints {
            $0.top.equalTo(mainTitle.snp.bottom).offset(5)
            if viewWidth < 340 {
                $0.left.equalToSuperview().offset(sideMargin-10)
                $0.right.equalToSuperview().offset(-sideMargin+10)
            } else {
                $0.left.equalToSuperview().offset(sideMargin)
                $0.right.equalToSuperview().offset(-sideMargin)
            }
            $0.height.equalTo(22)
        }

        imageView.snp.makeConstraints {
            $0.top.equalTo(subTitle.snp.bottom).offset(9)
            if viewWidth < 340 {
                $0.left.equalToSuperview().offset(26)
                $0.right.equalToSuperview().offset(-26)
            } else {
                $0.left.equalToSuperview().offset(46)
                $0.right.equalToSuperview().offset(-46)
            }
            $0.height.equalTo(130)
        }

        questionContainer.snp.makeConstraints {
            $0.top.equalTo(imageView.snp.bottom).offset(12)
            $0.height.equalTo(56)
            if viewWidth < 340 {
                $0.left.equalToSuperview().offset(19)
                $0.right.equalToSuperview().offset(-19)
            } else {
                $0.left.equalToSuperview().offset(29)
                $0.right.equalToSuperview().offset(-29)
            }

        }

        firstLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().offset(-10)
            $0.left.equalToSuperview().offset(24)
            $0.width.equalTo(19)
            $0.height.equalTo(36)
        }

        operLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(firstLabel)
            if viewWidth < 340 {
                $0.left.equalTo(firstLabel.snp.right).offset(12)
            } else {
                $0.left.equalTo(firstLabel.snp.right).offset(16)
            }
            $0.width.equalTo(21)
            $0.height.equalTo(36)
        }

        secondLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(firstLabel)
            if viewWidth < 340 {
                $0.left.equalTo(operLabel.snp.right).offset(12)
            } else {
                $0.left.equalTo(operLabel.snp.right).offset(16)
            }
            $0.width.equalTo(19)
            $0.height.equalTo(36)
        }

        equelLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(firstLabel)
            if viewWidth < 340 {
                $0.left.equalTo(secondLabel.snp.right).offset(12)
            } else {
                $0.left.equalTo(secondLabel.snp.right).offset(16)
            }
            $0.width.equalTo(19)
            $0.height.equalTo(36)
        }

        answerLabel.snp.makeConstraints {
            $0.top.bottom.equalTo(firstLabel)
            if viewWidth < 340 {
                $0.left.equalTo(equelLabel.snp.right).offset(6)
            } else {
                $0.left.equalTo(equelLabel.snp.right).offset(4)
            }
            $0.width.equalTo(56)
            $0.height.equalTo(36)
        }

        eraseButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            if viewWidth < 340 {
                $0.left.equalTo(answerLabel.snp.right)
                $0.right.equalToSuperview().offset(-12)
            } else {
                $0.left.equalTo(answerLabel.snp.right).offset(4)
                $0.right.equalToSuperview().offset(-16)
            }
            $0.height.equalTo(eraseButton.snp.width)
        }

        buttonsContainer.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(19)
            $0.top.equalTo(questionContainer.snp.bottom).offset(24)
            $0.height.equalTo(buttonWidth*2 + 8)
        }

        buttons[0].snp.makeConstraints {
            $0.top.left.equalToSuperview()
            $0.size.equalTo(buttonWidth)
        }
        for idx in 1...3 {
            buttons[idx].snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.left.equalTo(buttons[idx - 1].snp.right).offset(8)
                $0.size.equalTo(buttonWidth)
            }
        }
        buttons[4].snp.makeConstraints {
            $0.top.trailing.equalToSuperview()
            $0.left.equalTo(buttons[3].snp.right).offset(8)
            $0.size.equalTo(buttonWidth)
        }
        buttons[5].snp.makeConstraints {
            $0.top.equalTo(buttons[0].snp.bottom).offset(8)
            $0.left.equalToSuperview()
            $0.size.equalTo(buttonWidth)
        }
        for idx in 6...8 {
            buttons[idx].snp.makeConstraints {
                $0.top.equalTo(buttons[0].snp.bottom).offset(8)
                $0.left.equalTo(buttons[idx - 1].snp.right).offset(8)
                $0.size.equalTo(buttonWidth)
            }
        }
        buttons[9].snp.makeConstraints {
            $0.top.equalTo(buttons[0].snp.bottom).offset(8)
            $0.left.equalTo(buttons[8].snp.right).offset(8)
            $0.right.equalToSuperview()
            $0.size.equalTo(buttonWidth)
        }
        
        // MARK: - 기타 설정
        let closeButton = UIButton(type: .system).then {
            $0.addTarget(self, action: #selector(exitPopup), for: .touchUpInside)
        }
        unableView.addSubview(closeButton)
        closeButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        unableView.sendSubviewToBack(closeButton)
        view.backgroundColor = UIColor(named: "base")
        unableView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        
        buttons.forEach {
            $0.addTarget(self, action: #selector(clickNumber), for: .touchUpInside)
        }
        eraseButton.addTarget(self, action: #selector(clickDelete), for: .touchUpInside)
        
        firstLabel.text = firstNum.description
        operLabel.text = oper == .add ? "+" : "X"
        secondLabel.text = secondNum.description
    }
    /// 숫자 버튼 클릭
    @objc private func clickNumber(_ sender: UIButton) {
        guard let inputNumStr: String = sender.title(for: .normal) else { return }
        // 현재 입력되어 있는 숫자(String) 선언
        let nowNumStr: String = answerLabel.text ?? "0"
        // 정답의 자릿수
        let digit: Int = answerNum / 10 > 0 ? 2 : 1
        
        if nowNumStr == "0" || nowNumStr == "?" {
            answerLabel.text = inputNumStr
            setButtonImage(isEnableButtonImage: true)
            if digit == 1 { checkAnswer() }
        } else if nowNumStr.count == 1 {
            answerLabel.text = nowNumStr + inputNumStr
            if digit == 2 { checkAnswer() }
        }
    }
    /// 지우기 버튼 클릭
    @objc private func clickDelete() {
        let nowNum = answerLabel.text ?? "0"
        if nowNum.count == 1 { // 한자리일때 지우면 ?로
            answerLabel.text = "?"
            setButtonImage(isEnableButtonImage: false)
        } else { // 두자리일때 지우면 한자리로
            answerLabel.text?.removeLast()
        }
    }
    /// 정답 체크
    private func checkAnswer() {
        let nowNum: Int = Int(answerLabel.text ?? "-1") ?? -1
        if nowNum == answerNum {
            // 정답 처리
            answer()
        } else {
            // 오답 처리
            shakePopup()
        }
    }
    private func answer() {
        answerLabel.text = "?"
        eraseButton.setImage(UIImage(named: "btnNumberDelete32D"), for: .normal)
        [unableView, view, imageView, mainTitle, subTitle, positiveButton, negativeButton, questionContainer,
         firstLabel, operLabel, secondLabel, equelLabel, answerLabel, eraseButton, buttonsContainer].forEach {
            $0.removeFromSuperview()
         }
        buttons.forEach { $0.removeFromSuperview() }
        
        answerHandler()
    }
    // 흔드는 애니메이션
    private func shakePopup() {
        CATransaction.begin()

        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.05
        animation.repeatCount = 4
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: view.center.x - 7, y: view.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: view.center.x + 7, y: view.center.y))

        CATransaction.setCompletionBlock {
            self.answerLabel.text = "?"
            self.setButtonImage(isEnableButtonImage: false)
        }
        
        view.layer.add(animation, forKey: "position")
        CATransaction.commit()
    }
    // 버튼 이미지 체크 ( 숫자 있으면 진한 이미지로 변경 )
    private func setButtonImage(isEnableButtonImage: Bool) {
        if isEnableButtonImage {
            eraseButton.setImage(UIImage(named: "btnNumberDelete32A"), for: .normal)
        } else {
            eraseButton.setImage(UIImage(named: "btnNumberDelete32D"), for: .normal)
        }
    }
}
