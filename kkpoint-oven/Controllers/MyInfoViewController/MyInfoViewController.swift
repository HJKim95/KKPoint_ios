//
//  MyInfoViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit

protocol MyInfoVersionCellToMyInfoViewController: class {
    func showLoginVC()
    func goUpdate()
}

#if DEV
let devLabel = "-dev"
#else
let devLabel = ""
#endif

class MyInfoViewController: UIViewController, MyInfoVersionCellToMyInfoViewController {
    
    private let personalContainerHeight: CGFloat = 72 // 반가워요 ~ 부터 포인트있는 윗부분 높이
    private let infoCategoryHeight: CGFloat = 56
    private let updateLabelHeight: CGFloat = 58
    
    private var totalVersionCellHeight: CGFloat = 114
    
    var categoryList = ["공지/이벤트", "문의하기", "개인정보처리방침", "서비스약관"]

    private let myInfoCategories = ["포인트 충전/소진내역", "쿠폰 보관함", "출석부", "무료충전소",
                                        "공지/이벤트", "문의하기", "내 정보", "약관/개인정보처리방침"]

    private let forUndefinedUserCategories = ["공지/이벤트", "문의하기", "내 정보", "약관/개인정보처리방침"]

    private let myInfoCategoryImageDict = ["포인트 충전/소진내역": "icnMyPoint", "쿠폰 보관함": "icnMyCharginglist",
                                           "출석부": "icnMyDailycheck", "무료충전소": "icnMyFreecharge",
                                           "공지/이벤트": "icnMyMarketing", "문의하기": "icnMyArs",
                                           "내 정보": "icnMyAccount", "약관/개인정보처리방침": "icnMyPrivacy"]

    private let myInfoCellID = String(describing: MyInfoCollectionViewCell.self)
    private let myInfoVersionCellID = String(describing: MyInfoVersionCell.self)
    
    var lastVersion = AccountManager.shared.lastVersion

    var myPointData: KKPointModel<AccountPointDataModel>? {
        didSet {
            guard let totalPoints = myPointData?.data?.totalPoints,
                  let formattedPoint = Formatter.Number.numberFormatter.string(from: NSNumber(value: totalPoints))
            else { return }
            mainWelcomView.pointLabel.text = "\(formattedPoint)"
            mainWelcomView.pointLabel.customFont(fontName: .NanumSquareRoundEB, size: 18, letterSpacing: -1)
        }
    }
    
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

    private lazy var mainWelcomView: MainTopWelcomeView = {
        let view = MainTopWelcomeView()
        view.presentButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                           action: #selector(clickPresent)))
        return view
    }()
    
    private lazy var myInfoCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "elavated")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.alwaysBounceVertical = true
        return collectionview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Custom Navigation Bar Enable Swipe Back
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        setupLayouts()

        myInfoCollectionView.register(MyInfoCollectionViewCell.self, forCellWithReuseIdentifier: myInfoCellID)
        myInfoCollectionView.register(MyInfoVersionCell.self,
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                      withReuseIdentifier: myInfoVersionCellID)
        
        // 로그인 관련 UI작업 노티피케이션 설정
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkDidLoggedIn),
                                               name: Notification.Login.checkLogin,
                                               object: nil)
        
        // 포인트 관련 UI작업 노티피케이션 설정
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setPoint),
                                               name: Notification.Point.getPoint,
                                               object: nil)
        
        // 출석체크 관련 UI작업 노티피케이션 설정
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setAttendance),
                                               name: Notification.Attendance.getAttendance,
                                               object: nil)
        
        // Notification Observer가 나중에 add되기 때문에 데이터를 한번은 받아온다.
        
        myPointData = AccountManager.shared.pointData
        myAttendanceDates = AccountManager.shared.attendanceData
        setUpVersionLayout()
        
    }
    
    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "elavated")

        view.addSubview(customNavigationBar)
        view.addSubview(mainWelcomView)
        view.addSubview(myInfoCollectionView)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }

        mainWelcomView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(personalContainerHeight)
        }

        myInfoCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(mainWelcomView.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func setUpVersionLayout() {
        guard let noNeedUpdate = AccountManager.shared.isRecentVersion else {return}
        if noNeedUpdate { // 최신 버전
            if AccountManager.shared.isLogged {
                self.totalVersionCellHeight = self.infoCategoryHeight
            } else {
                self.totalVersionCellHeight = self.infoCategoryHeight + 60
            }
        } else { // 구 버전
            if AccountManager.shared.isLogged {
                self.totalVersionCellHeight = self.infoCategoryHeight + 58
            } else {
                self.totalVersionCellHeight = self.infoCategoryHeight + 58 + 60
            }
            
        }
        DispatchQueue.main.async {
            self.myInfoCollectionView.reloadData()
        }
    }
    
    @objc func setPoint() {
        myPointData = AccountManager.shared.pointData
    }
    
    @objc func setAttendance() {
        myAttendanceDates = AccountManager.shared.attendanceData
    }
    
    var loginHeight: CGFloat = 0 // 로그인을 하지 않았으면 버전 밑에 로그인 하세요 띄우기 위함.
    
    @objc func checkDidLoggedIn() {
        if AccountManager.shared.isLogged {
            // 처음 로그인한 순간 & 로그인하고 포인트가 아직 없을 때,
            mainWelcomView.helloLabel.alpha = 1
            mainWelcomView.helloLabel.text = "반가워요, \(AccountManager.shared.user.name ?? "헤이지니")님"
            mainWelcomView.helloLabel.customFont(fontName: .NanumSquareRoundR, size: 17, letterSpacing: -1)
            mainWelcomView.pImageView.alpha = 1
            mainWelcomView.pointLabel.alpha = 1
            mainWelcomView.recommendLabel.alpha = 0
            categoryList = myInfoCategories
            myPointData = AccountManager.shared.pointData
            DispatchQueue.main.async {
                self.myInfoCollectionView.reloadData()
            }
        } else {
            // 로그아웃 했거나, 로그인을 아예 하지 않았을 때,
            mainWelcomView.recommendLabel.alpha = 1
            mainWelcomView.helloLabel.alpha = 0
            mainWelcomView.pImageView.alpha = 0
            mainWelcomView.pointLabel.alpha = 0
            mainWelcomView.presentButtonView.backgroundColor = Resource.Color.orange06
            categoryList = forUndefinedUserCategories
            DispatchQueue.main.async {
                self.myInfoCollectionView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        checkDidLoggedIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    @objc private func clickPresent() {
        // 로그인한 경우에만 넘겨주기
        if AccountManager.shared.isLogged {
            presentAttendanceController()
        } else {
            showLoginVC()
        }
    }
    
    func showLoginVC() {
        let loginVC = LoginViewController()
        if #available(iOS 13.0, *) {
            loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
            present(loginVC, animated: true)
        } else {
            present(loginVC, animated: true)
        }
    }
    
    func goUpdate() {
        let version = lastVersion
        var url = ""
        if isDev {
//            let downloadUrl = "itms-services://?action=download-manifest&url="
//            let target = "https://kkpoint-ios.s3.ap-northeast-2.amazonaws.com/\(version)/manifest.plist"
//            url = "\(downloadUrl)\(target)"
        } else {
            
        }

        let title = "업데이트 하시곘습니까?"
        AlertManager.showAlert(title: title, message: nil, oKTItle: "네", cancelTitle: "아니요") {
            if let url = URL(string: url) {
                UIApplication.shared.open(url)
            }
        }
    }
    
    var myAttendanceDates: [[String]]? {
        didSet {
            if let dates = myAttendanceDates {
                let wholeDateFormatter = Formatter.Date.dateFormatterGetWholeDate
                let todayDate = wholeDateFormatter.string(from: Date())
                
                if dates.count > 0 && dates[0].contains(todayDate) { // 오늘 출석을 한경우
                    mainWelcomView.presentButtonView.backgroundColor = Resource.Color.grey03
                } else { // 오늘 출석을 아직 안한 경우
                    mainWelcomView.presentButtonView.backgroundColor = Resource.Color.orange06
                }
            }
        }
    }

    private func presentAttendanceController() {
        let viewcontroller = MyPresentController()
        viewcontroller.attendanceData = myAttendanceDates ?? [[""]]
        viewcontroller.pushFromMyInfo = true
        navigationController?.pushViewController(viewcontroller, animated: true)
    }

    private func showCSViewController() {
        if AccountManager.shared.isLogged {
            let controller = CSViewController()
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let loginVC = LoginViewController()
            if #available(iOS 13.0, *) {
                loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
                present(loginVC, animated: true)
            } else {
                present(loginVC, animated: true)
            }
        }
    }
}

extension MyInfoViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return categoryList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myInfoCellID,
                                                         for: indexPath) as? MyInfoCollectionViewCell {
            
            let category = categoryList[indexPath.item]
            if let imageName = myInfoCategoryImageDict[category] {
                cell.myInfoCategoryImageView.image = UIImage(named: imageName)
                if category == "쿠폰 보관함" {
                    if AccountManager.shared.getNewCouponState() {
                        cell.myInfoCategoryImageView.image = UIImage(named: "icnMyCharginglistAlaram")
                    }
                }
            }
            cell.myInfoCategoryLabel.text = category
            cell.myInfoCategoryLabel.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: myInfoVersionCellID,
                                                                        for: indexPath) as? MyInfoVersionCell {
            footer.isRecentVersion = AccountManager.shared.isRecentVersion
            footer.layoutIfNeeded()
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                if let noNeedUpdate = AccountManager.shared.isRecentVersion {
                    if noNeedUpdate {
                        footer.myInfoVersionLabel.text = "최신버전 \(version)\(devLabel)"
                    } else {
                        footer.myInfoVersionLabel.text = "\(version)\(devLabel)"
                    }
                }
            }
            footer.myInfoVersionLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
            footer.myInfoVersionLabel.textAlignment = .right
            footer.delegate = self
            return footer
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: infoCategoryHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: totalVersionCellHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        let category = categoryList[index]
        switch category {
        case "포인트 충전/소진내역":
            let controller = MyPointViewController()
            controller.myPointData = myPointData
            controller.myAttendanceDates = myAttendanceDates
            navigationController?.pushViewController(controller, animated: true)
        case "쿠폰 보관함":
            let controller = MyCouponViewController()
            navigationController?.pushViewController(controller, animated: true)
        case "출석부":
            clickPresent()
        case "무료충전소":
            AdiscopeManager.shared.goChargeStation()
        case "공지/이벤트":
            let controller = MyEventViewController()
            navigationController?.pushViewController(controller, animated: true)
        case "문의하기":
            self.showCSViewController()
        case "내 정보":
            PopupManager.shared.showCheckParents(isAdvertise: false) {
                let controller = MyAccountViewController()
                self.navigationController?.pushViewController(controller, animated: true)
            }
        case "약관/개인정보처리방침":
            let controller = PrivacyViewController()
            navigationController?.pushViewController(controller, animated: true)
        default:
            print("DID NOT MADE CONTROLLER")
        }
    }
}
