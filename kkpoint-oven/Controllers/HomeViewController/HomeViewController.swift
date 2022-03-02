//
//  HomeController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit
import Alamofire
import GoogleMobileAds
import Lottie

class HomeViewController: UIViewController {
    // backImage
    private let dismissBackImageOffsetY: CGFloat = 100 // 스크롤시 backImage 없어지기 시작하는 offet
    private let backImageRatio: CGFloat = 6/19 // width 1 기준
    private let backImageShowRatio: CGFloat = 0.4 // backImage 보여지는 부분 40%
    
    // admob
    private let adShowTerm = Resource.AdMob.adShowTerm
    
    // 메인 뷰 관련
    private let personalContainerHeight: CGFloat = 72 // 반가워요 ~ 부터 포인트있는 윗부분 높이
    private let mainCollectionViewLineSpacing: CGFloat = 14
    
    private let homeCellID = String(describing: MainYoutubeVideoCell.self)
    private let headerCellID = String(describing: HomeBlankHeaderCell.self)
    
    var didAnimatePointDate: Date = Date().addingTimeInterval(-10)

    var myPointData: KKPointModel<AccountPointDataModel>? {
        didSet {
            guard let totalPoints = myPointData?.data?.totalPoints,
                  let formattedPoint = Formatter.Number.numberFormatter.string(from: NSNumber(value: totalPoints))
            else { return }
//            if didAnimatePointDate.timeIntervalSince(Date()) < -3 {
//                mainWelcomView.scrollCountView.countingNum = totalPoints
//                didAnimatePointDate = Date()
//            }
            
            mainWelcomView.pointLabel.text = "\(formattedPoint)"
            mainWelcomView.pointLabel.customFont(fontName: .NanumSquareRoundEB, size: 18, letterSpacing: -1)
        }
    }
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    lazy var totalTopViewHeight = personalContainerHeight + totalCustomNavBarHeight
    
    private let customNavigationBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar()
        navBar.mainTitleButton.addTarget(self, action: #selector(goTop), for: .touchUpInside)
        return navBar
    }()

    private lazy var mainWelcomView: MainTopWelcomeView = {
        let view = MainTopWelcomeView()
        view.presentButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                           action: #selector(clickPresent)))
        return view
    }()
    
    private let backImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "mainBgEffect01")
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    var videoList: [Video] = []
    
    private var refreshControl = UIRefreshControl()
    
    lazy var homeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = mainCollectionViewLineSpacing
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = .clear
        collectionview.showsVerticalScrollIndicator = false
        collectionview.prefetchDataSource = self
        return collectionview
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.delegate = self
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayouts()
        getVideoData()
        self.title = "홈"
        
        let cells = [MainYoutubeVideoCell.self, AdmobCell.self]
        cells.forEach { (cell) in
            homeCollectionView.register(cell.self, forCellWithReuseIdentifier: String(describing: cell.self))
        }
        
        homeCollectionView.register(HomeBlankHeaderCell.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: headerCellID)

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
    }
    
    var didInitAdiscope = false
    
    // 뷰위에 present하는 특성상, viewDidLoad가 아닌 viewDidAppear에서 해야함.
    private var isFirstAppear = true
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isFirstAppear {
            // 인트로 할것들 시작
            popUpIntroes()
            isFirstAppear = false
        }
        checkDidLoggedIn()
        if !didInitAdiscope {
            // 애디스콥 매니저
            AdiscopeManager.shared.adiscopeInit() // 처음에 기본 한번 initialize
            self.didInitAdiscope = true
        }
        AccountManager.shared.getPoint() // 광고 관련 포인트 delay 고려.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")
        view.addSubview(mainWelcomView)
        view.addSubview(backImageView)
        view.addSubview(homeCollectionView)
        view.addSubview(customNavigationBar)

        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        mainWelcomView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(totalCustomNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(personalContainerHeight)
        }
        
        backImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(totalTopViewHeight)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)

            make.height.equalTo(backImageView.snp.width).multipliedBy(backImageRatio)
        }
        homeCollectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(totalTopViewHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
        homeCollectionView.refreshControl = refreshControl
    }

    private var page: Int = 0
    private var isLastPage: Bool = false
    private func getVideoData() {
        NetworkManager.getAllVideos(page: page) { [weak self] result in
            switch result {
            case .success(let response):
                guard let self = self else { return }
                self.page += 1
                response.data.forEach { self.calculateTextSize(text: $0.title ?? "") }
                if self.videoList.count == 0 {
                    self.videoList = response.data
                    DispatchQueue.main.async {
                        self.homeCollectionView.reloadData()
                    }
                } else {
                    self.videoList.append(contentsOf: response.data)
                    DispatchQueue.main.async {
                        self.homeCollectionView.reloadData()
                    }
                }
                if response.pagination.totalPages == response.pagination.currentPage+1 ||
                    response.pagination.totalPages == 0 { // 페이지의 끝일 때
                    self.isLastPage = true
                }
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "비디오를 가져오는데 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
    }

    var cellSizeArray = [CGFloat]()
    
    private func calculateTextSize(text: String) {
        // width -  (38 + 12 ... + 16) - 16*2
        let desiredWith = view.frame.width - 66 - 32
        let cellWidth = view.frame.width - 32
        // MainYoutubeVideoCell 특성 반영
        let dummyLabel = UILabel()
        dummyLabel.text = text + "  "  // 이모티콘 등을 대비한 한칸 여유
        dummyLabel.numberOfLines = 2

        guard let font = UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 15) else {return}
        let boundingRect = dummyLabel.text?.boundingRect(with: .zero, options: [.usesFontLeading],
                                                         attributes: [.font: font, .kern: -0.3], context: nil)
        let line = Int(ceil((boundingRect!.width / desiredWith)))
        let youtubeHeight = cellWidth * 0.561
        var totalSize: CGFloat = youtubeHeight + 15
        if line == 1 {
            totalSize += 20 // text Size
            totalSize += 2 + 20 + 15
        } else {
            totalSize += 40 // text Size
            totalSize += 5 + 20 + 10
        }

        cellSizeArray.append(totalSize)
    }

    @objc func checkDidLoggedIn() {
        if AccountManager.shared.isLogged {
            // 로그인 했을 때
            mainWelcomView.helloLabel.alpha = 1
            mainWelcomView.helloLabel.text = "반가워요, \(AccountManager.shared.user.name ?? "헤이지니")님"
            mainWelcomView.helloLabel.customFont(fontName: .NanumSquareRoundR, size: 17, letterSpacing: -1)
            mainWelcomView.pImageView.alpha = 1
            mainWelcomView.pointLabel.alpha = 1
//            mainWelcomView.scrollCountView.alpha = 1
            mainWelcomView.recommendLabel.alpha = 0
        } else {
            // 로그아웃 했거나, 로그인을 아예 하지 않았을 때
            mainWelcomView.recommendLabel.alpha = 1
            mainWelcomView.helloLabel.alpha = 0
            mainWelcomView.pImageView.alpha = 0
            mainWelcomView.pointLabel.alpha = 0
//            mainWelcomView.scrollCountView.alpha = 0
            mainWelcomView.presentButtonView.backgroundColor = Resource.Color.orange06
        }
    }
    
    @objc func setPoint() {
        myPointData = AccountManager.shared.pointData
    }
    
    @objc func setAttendance() {
        myAttendanceDates = AccountManager.shared.attendanceData
    }
    
    private func popUpIntroes() {
        // 권한 체크
        if !UserDefaults.standard.bool(forKey: UserDefault.permission) {
            let permissionVC = PermissionViewController()
            permissionVC.modalPresentationStyle = .fullScreen
            present(permissionVC, animated: true)
            return
        }
        // 로그인
        if !AccountManager.shared.isLogged {
            let loginVC = LoginViewController()
            if #available(iOS 13.0, *) {
                loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
            }
            present(loginVC, animated: true)
            return
        }
    }
    
    @objc private func clickPresent() {
        // 로그인한 경우에만 넘겨주기
        if AccountManager.shared.isLogged {
            presentAttendanceController()
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
    
    var myAttendanceDates: [[String]]? {
        didSet {
            if let dates = myAttendanceDates {
                let wholeDateFormatter = Formatter.Date.dateFormatterGetWholeDate
                let todayDate = wholeDateFormatter.string(from: Date())
                if dates[0].contains(todayDate) { // 오늘 출석을 한경우
                    mainWelcomView.presentButtonView.backgroundColor = Resource.Color.grey03
                } else { // 오늘 출석을 아직 안한 경우
                    mainWelcomView.presentButtonView.backgroundColor = Resource.Color.orange06
                }
            }
        }
    }

    private func presentAttendanceController() {
        let viewcontroller = MyPresentController()
        viewcontroller.attendanceData = self.myAttendanceDates ?? [[""]]
        self.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @objc private func goTop() {
        homeCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                        at: .centeredVertically, animated: true)
    }
    
    func navBarUp() {
        customNavigationBar.alpha = 1
        customNavigationBar.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(-totalCustomNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            self.customNavigationBar.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.didShowNavBar = false
        }
    }
    
    func navBarDown() {
        customNavigationBar.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            self.customNavigationBar.alpha = 1
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.didShowNavBar = true
        }
    }
    
    var lastContentOffset: CGFloat = 0
    var didShowNavBar = true

}

extension HomeViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let adItems = videoList.count / adShowTerm
        return videoList.count + adItems
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        var item = indexPath.item + 1
        let width = collectionView.frame.width
        if item % (adShowTerm+1) == 0 {
            return CGSize(width: width, height: width * 0.3125)
        } else {
            item -= item/(adShowTerm+1)
            item -= 1 // indexPath 는 0부터 시작하니까 다시 index 맞춰주기
            let height = cellSizeArray[item]
            return CGSize(width: width-32, height: height)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // 애드몹 셀 넣는 작업을 위한 인덱스 변수
        if videoList.count == 0 { return UICollectionViewCell() }
        
        var item = indexPath.item + 1
        if item % (adShowTerm+1) == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Resource.AdMob.admobID,
                                                             for: indexPath) as? AdmobCell {
                cell.mappingData(rootVC: self)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: homeCellID,
                                                             for: indexPath) as? MainYoutubeVideoCell {
                item -= item/(adShowTerm+1)
                item -= 1 // indexPath 는 0부터 시작하니까 다시 index 맞춰주기
                cell.mappingData(data: videoList[item])
                
                return cell
            }
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: headerCellID,
                                                                        for: indexPath) as? HomeBlankHeaderCell {
            return header
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let backImageHeight = collectionView.frame.width * backImageRatio
        return CGSize(width: collectionView.frame.width, height: backImageHeight*backImageShowRatio)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var item = indexPath.item + 1
        if item % (adShowTerm+1) != 0 {
            item -= item/(adShowTerm+1)
            item -= 1 // indexPath 는 0부터 시작하니까 다시 index 맞춰주기
            let nextVC = DetailYoutubeViewController()
            nextVC.video = videoList[item]
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
    
    // for smooth scroll with rounded cell & shadow
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let backImageHeight = view.frame.width * backImageRatio
        let backHeight = backImageHeight*backImageShowRatio
        var offsetY = scrollView.contentOffset.y
        let delta = lastContentOffset - offsetY
        let newOffset = max(offsetY-backHeight, 0)
        if delta > 0 && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height {
        // move up
            if !didShowNavBar && delta > 5 {
                self.navBarDown()
            }
            mainWelcomView.alpha = 1
            if offsetY < 0 { offsetY = 0 } // 탭 눌러서 올라갈때를 대응
            
            if offsetY > -10 {
                mainWelcomView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(totalCustomNavBarHeight-min(newOffset, totalTopViewHeight))
                    make.left.right.equalToSuperview()
                    make.height.equalTo(personalContainerHeight)
                }
                
                homeCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(max(totalTopViewHeight-min(newOffset, totalTopViewHeight),
                                                           statusBarHeight))
                    make.left.right.bottom.equalToSuperview()
                }
            }

        } else if delta < 0 && offsetY > backHeight && scrollView.contentSize.height > scrollView.frame.height {
        // move down
            if offsetY > totalTopViewHeight && didShowNavBar && delta < -8 {
                self.navBarUp()
            } else {
                if offsetY < totalTopViewHeight {
                    let navBarAlpha = max(1 - (newOffset*1.3/totalTopViewHeight), 0)
                    customNavigationBar.alpha = navBarAlpha
                    customNavigationBar.snp.remakeConstraints { (make) in
                        make.top.equalToSuperview().offset(-min(newOffset, totalTopViewHeight))
                        make.left.right.equalToSuperview()
                        make.height.equalTo(totalCustomNavBarHeight)
                    }
                    didShowNavBar = false
                }
                
                var headerAlpha: CGFloat = 1
                if offsetY > totalCustomNavBarHeight {
                    headerAlpha = max(1 - ((newOffset-totalCustomNavBarHeight)/personalContainerHeight), 0)
                }

                mainWelcomView.alpha = headerAlpha
                mainWelcomView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(totalCustomNavBarHeight-min(newOffset, totalTopViewHeight))
                    make.left.right.equalToSuperview()
                    make.height.equalTo(personalContainerHeight)
                }

                homeCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(max(totalTopViewHeight-min(newOffset, totalTopViewHeight),
                                                           statusBarHeight))
                    make.left.right.bottom.equalToSuperview()
                }
            }
        }
        
        // update the new position acquired
        lastContentOffset = offsetY
        if offsetY > dismissBackImageOffsetY {
            backImageView.alpha = 0
        } else {
            backImageView.alpha = 1
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
            UIView.animate(withDuration: 0.4) {
                self.homeCollectionView.alpha = 0.3
            } completion: { [weak self] (_) in
                self?.videoList.removeAll()
                self?.page = 0
                self?.getVideoData()
                AccountManager.shared.getPoint()
                UIView.animate(withDuration: 0.4) {
                    self?.homeCollectionView.alpha = 1
                }
            }
        }
    }
}

extension HomeViewController: UICollectionViewDataSourcePrefetching {
    // for pagination
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var index = 0
        while index < indexPaths.count {
            let indexPath = indexPaths[index]
            let adItems = videoList.count / adShowTerm
            if videoList.count + adItems == indexPath.item+1 {
                self.getVideoData()
            }
            index += 1
        }
    }
}

extension HomeViewController: UINavigationControllerDelegate {
    /// 해당 네비게이션 하위 뷰컨들은 모두 세로모드
    /// 화면 회전 처리를 위한 작업 ( 썸네일과 처음 로딩시는 세로모드만 적용 후, 전체화면 가로모드를 위해 네비게이션, 뷰컨 별로 세분화 )
    func navigationControllerSupportedInterfaceOrientations(_ navigationController: UINavigationController) -> UIInterfaceOrientationMask {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return .portrait }
        appDelegate.supportedInterfaceOrientation = .allButUpsideDown
        return .portrait
    }
}
