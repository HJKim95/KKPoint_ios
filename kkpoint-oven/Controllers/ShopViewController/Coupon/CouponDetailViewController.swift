//
//  CouponDetailViewController.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/20.
//

import UIKit

class CouponDetailViewController: UIViewController {
    // MARK: - Params
    private let sideMargin: CGFloat = 16.0
    private let titleContentDist: CGFloat = 2.0
    private let cellDist: CGFloat = 22.0
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        return navBar
    }()
    
    private let scrollView: UIScrollView = UIScrollView()
    private let scrollContentView: UIView = UIView()
    
    private let whiteContainer: UIView = UIView().then {
        $0.backgroundColor = UIColor(named: "elavated")
    }
    private let imgView: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "imgCoupon1000")
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 54
        $0.layer.masksToBounds = true
        $0.backgroundColor = UIColor(named: "base")
    }
    private let shopName: UILabel = UILabel().then {
        $0.text = "잼팩토리"
        $0.textColor = UIColor(named: "secondary01")
    }
    
    private let couponTitle: UILabel = UILabel().then {
        $0.text = "5% 할인쿠폰"
        $0.textColor = Resource.Color.orange06
        $0.customFont(fontName: .NanumSquareRoundEB, size: 20, letterSpacing: -1)
        $0.numberOfLines = 0
    }
    private let validDate: UILabel = UILabel().then {
        $0.text = "2021.12.31 까지 사용 가능"
        $0.textColor = UIColor(named: "disable")
        $0.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
    }
    
    private let basicContainer: UIView = UIView().then {
        $0.backgroundColor = UIColor(named: "base")
    }
    
    private let useSpaceTitle: UILabel = UILabel().then {
        $0.text = "사용처"
        $0.textColor = UIColor(named: "disable")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    private let useSpaceContent: UILabel = UILabel().then {
        $0.text = "잼토이즈"
        $0.textColor = UIColor(named: "primary02")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.numberOfLines = 0
    }
    private let useSpaceLink: UIButton = UIButton(type: .system).then {
        $0.setTitle("링크로 확인", for: .normal)
        $0.setTitleColor(Resource.Color.blue02, for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    
    private let useDateTitle: UILabel = UILabel().then {
        $0.text = "사용기간"
        $0.textColor = UIColor(named: "disable")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    private let useDateContent: UILabel = UILabel().then {
        $0.text = "2021-12-31까지 사용가능"
        $0.textColor = UIColor(named: "primary02")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.numberOfLines = 0
    }
    
    private let descTitle: UILabel = UILabel().then {
        $0.text = "상품설명"
        $0.textColor = UIColor(named: "disable")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    private let descContent: UILabel = UILabel().then {
        $0.text = "5% 할인쿠폰"
        $0.textColor = UIColor(named: "primary02")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.numberOfLines = 0
    }
    
    private let questionTitle: UILabel = UILabel().then {
        $0.text = "상품문의"
        $0.textColor = UIColor(named: "disable")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    private let questionContent: UILabel = UILabel().then {
        $0.text = "gemtoys@gemtoys.co.kr"
        $0.textColor = UIColor(named: "primary02")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.numberOfLines = 0
    }
    
    private let shipTitle: UILabel = UILabel().then {
        $0.text = "배송"
        $0.textColor = UIColor(named: "disable")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    private let shipContent: UILabel = UILabel().then {
        $0.text = "쿠폰보관함을 확인하세요."
        $0.textColor = UIColor(named: "primary02")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.numberOfLines = 0
    }
    
    private let refundTitle: UILabel = UILabel().then {
        $0.text = "환불문의"
        $0.textColor = UIColor(named: "disable")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
    }
    
    private let refundContent: UILabel = UILabel().then {
        $0.text = "kk_help@neowiz.com 으로 문의바랍니다."
        $0.textColor = UIColor(named: "primary02")
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.numberOfLines = 0
    }
    
    private let floatingButton: UIButton = UIButton(type: .system).then {
        $0.setTitle("구매하기", for: .normal)
        $0.setTitleColor(Resource.Color.white00, for: .normal)
        $0.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 16, letterSpacing: -1)
        $0.backgroundColor = Resource.Color.orange06
        $0.layer.cornerRadius = 25
        $0.layer.masksToBounds = true
    }
    
    private var couponPointAmount: Int = 0
    private var couponPointStr: String = "0"
    
    // MARK: - Method
    func mappingData(data: CouponList) {
        
        customNavigationBar.titleLabel.text = data.couponName
        customNavigationBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        customNavigationBar.titleLabel.textAlignment = .center
        
//        imgView.image = UIImage(named: "imgCoupon\(data)")
        shopName.text = data.admin
        shopName.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        
        couponTitle.text = data.couponName
        couponTitle.customFont(fontName: .NanumSquareRoundEB, size: 20, letterSpacing: -1)
        
        validDate.text = data.dueDate
        validDate.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        
        useSpaceContent.text = data.homepage
        useSpaceContent.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        
        // homepageUrl
        useDateContent.text = data.validDate
        useDateContent.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        
        descContent.text = data.itemDescription
        descContent.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        
        questionContent.text = data.itemCsDescription
        questionContent.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        
        shipContent.text = data.deliverDescription
        shipContent.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        
        refundContent.text = data.refundDescription
        refundContent.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        
        couponPointAmount = data.price
        couponPointStr = Formatter.Number.getFormattedNum(num: data.price)
        urlString = data.homepageUrl
        
        couponListId = data.idx
    }
    
    private var urlString: String = ""
    private var couponListId: Int = 0
    
    @objc func clickFloatingButton() {
        if !AccountManager.shared.isLogged {
//            ToastManager.showToast(message: "로그인 후 구매할 수 있어요.", isTopWindow: true)
            return
        }
        
        PopupManager.shared.showCheckParents(isAdvertise: false) { [weak self] in
            guard let self = self else { return }
            PopupManager.shared.showPopup(
                mainStr: "쿠폰을 구매하시겠습니까?\nP \(self.couponPointStr) 가 소진됩니다.",
                positiveButtonOption: ButtonOption(title: "네, 구매할게요.") { [weak self] in
                    guard let self = self else { return }
                    if self.couponPointAmount > AccountManager.shared.pointData?.data?.totalPoints ?? 0 {
                        PopupManager.shared.showPopup(
                            mainStr: "보유하신 포인트가 부족합니다.",
                            positiveButtonOption: ButtonOption(title: "무료 충전소가기") {
                                Utilities.toFreeChargeStation()
                            },
                            negativeButtonOption: ButtonOption(title: "확인") { }
                        )
                    } else {
                        NetworkManager.postUserCoupon(couponListId: self.couponListId) { result in
                            switch result {
                            case .success(let data):
                                print(data)
                                guard let couponNumber = data.data?.couponId else {return}
                                PopupManager.shared.showPopup(
                                    mainStr: "쿠폰이 구매되었습니다.",
                                    subStr: "쿠폰번호 \(couponNumber)\n쿠폰번호는 내정보>쿠폰보관함에서\n언제든지 확인할 수 있습니다.",
                                    positiveButtonOption: ButtonOption(title: "쿠폰 보관함 가기") {
                                        Utilities.toCouponChest()
                                    },
                                    negativeButtonOption: ButtonOption(title: "쿠폰목록가기") {
                                        Utilities.toCouponList()
                                    }
                                )
                            case .failure(let error):
                                print(error)
                                if error == .noCouponAvailable {
                                    PopupManager.shared.showPopup(
                                        mainStr: "쿠폰이 모두 소진 되었습니다.",
                                        subStr: "다음에 다시 이용해주세요.",
                                        positiveButtonOption: ButtonOption(title: "확인") { }
                                    )
                                } else if error == .couponBuyConflict {
                                    PopupManager.shared.showPopup(
                                        mainStr: "쿠폰 구매에 오류가 발생하였습니다.",
                                        subStr: "다음에 다시 이용해주세요.",
                                        positiveButtonOption: ButtonOption(title: "확인") { }
                                    )
                                }
                            }
                        }
                        
                        // 쿠폰 보관함에 새 쿠폰 표시를 위한 세팅
                        AccountManager.shared.setNewCouponState(bool: true)
                    }
                  },
                negativeButtonOption: ButtonOption(title: "아니요. 구매안할게요.") { }
            )
        }
    }
    
    @objc func clickLink() {
        guard let url = URL(string: urlString) else {return}
        UIApplication.shared.open(url)
    }
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayout()
        configure()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    private func configure() {
        floatingButton.addTarget(self, action: #selector(clickFloatingButton), for: .touchUpInside)
        useSpaceLink.addTarget(self, action: #selector(clickLink), for: .touchUpInside)
        
        // 링크 밑줄 처리
        let attrs: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 13)!,
            .foregroundColor: Resource.Color.blue02,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        
        let attribStr = NSAttributedString(string: "링크로 확인", attributes: attrs)
        useSpaceLink.setAttributedTitle(attribStr, for: .normal)
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor(named: "base")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        view.addSubview(scrollView)
        scrollView.addSubview(scrollContentView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(scrollView.frameLayoutGuide.snp.width)
        }
        
        scrollContentView.addSubview(whiteContainer)
        whiteContainer.addSubview(imgView)
        whiteContainer.addSubview(shopName)
        whiteContainer.addSubview(couponTitle)
        whiteContainer.addSubview(validDate)
        
        scrollContentView.addSubview(basicContainer)
        basicContainer.addSubview(useSpaceTitle)
        basicContainer.addSubview(useSpaceContent)
        basicContainer.addSubview(useSpaceLink)
        basicContainer.addSubview(useDateTitle)
        basicContainer.addSubview(useDateContent)
        basicContainer.addSubview(descTitle)
        basicContainer.addSubview(descContent)
        basicContainer.addSubview(questionTitle)
        basicContainer.addSubview(questionContent)
        basicContainer.addSubview(shipTitle)
        basicContainer.addSubview(shipContent)
        basicContainer.addSubview(refundTitle)
        basicContainer.addSubview(refundContent)
        
        whiteContainer.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        imgView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(108)
            $0.top.equalToSuperview().offset(6)
        }
        shopName.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.top.equalTo(imgView.snp.bottom).offset(4)
        }
        couponTitle.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.top.equalTo(shopName.snp.bottom).offset(5)
        }
        validDate.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.top.equalTo(couponTitle.snp.bottom).offset(7)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        basicContainer.snp.makeConstraints {
            $0.top.equalTo(whiteContainer.snp.bottom)
            $0.bottom.trailing.leading.equalToSuperview()
        }
        useSpaceTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(sideMargin)
        }
        useSpaceContent.snp.makeConstraints {
            $0.top.equalTo(useSpaceTitle.snp.bottom).offset(titleContentDist)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
        }
        useSpaceLink.snp.makeConstraints {
            $0.centerY.equalTo(useSpaceContent)
            $0.trailing.equalToSuperview().offset(-sideMargin)
        }
        
        useDateTitle.snp.makeConstraints {
            $0.top.equalTo(useSpaceContent.snp.bottom).offset(cellDist)
            $0.leading.equalToSuperview().offset(sideMargin)
        }
        useDateContent.snp.makeConstraints {
            $0.top.equalTo(useDateTitle.snp.bottom).offset(titleContentDist)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
        }
        
        descTitle.snp.makeConstraints {
            $0.top.equalTo(useDateContent.snp.bottom).offset(cellDist)
            $0.leading.equalToSuperview().offset(sideMargin)
        }
        descContent.snp.makeConstraints {
            $0.top.equalTo(descTitle.snp.bottom).offset(titleContentDist)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
        }
        
        questionTitle.snp.makeConstraints {
            $0.top.equalTo(descContent.snp.bottom).offset(cellDist)
            $0.leading.equalToSuperview().offset(sideMargin)
        }
        questionContent.snp.makeConstraints {
            $0.top.equalTo(questionTitle.snp.bottom).offset(titleContentDist)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
        }
        
        shipTitle.snp.makeConstraints {
            $0.top.equalTo(questionContent.snp.bottom).offset(cellDist)
            $0.leading.equalToSuperview().offset(sideMargin)
        }
        shipContent.snp.makeConstraints {
            $0.top.equalTo(shipTitle.snp.bottom).offset(titleContentDist)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
        }
        
        refundTitle.snp.makeConstraints {
            $0.top.equalTo(shipContent.snp.bottom).offset(cellDist)
            $0.leading.equalToSuperview().offset(sideMargin)
        }
        refundContent.snp.makeConstraints {
            $0.top.equalTo(refundTitle.snp.bottom).offset(titleContentDist)
            $0.leading.trailing.equalToSuperview().inset(sideMargin)
            $0.bottom.equalToSuperview().offset(-cellDist)
        }
        
        view.addSubview(floatingButton)
        floatingButton.snp.makeConstraints {
            $0.trailing.leading.equalToSuperview().inset(sideMargin)
            $0.bottom.equalTo(view.safeAreaLayoutGuide).offset(-10)
            $0.height.equalTo(50)
        }
    }
}
