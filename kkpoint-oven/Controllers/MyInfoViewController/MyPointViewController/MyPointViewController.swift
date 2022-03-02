//
//  MyPointViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class MyPointViewController: UIViewController, FooterForPointCellToMyPointViewControllers {

    private let myPointCellID = String(describing: MyPointCollectionViewCell.self)
    private let footerID = String(describing: FooterForPointCell.self)
    
    private let personalContainerHeight: CGFloat = 72 // 반가워요 ~ 부터 포인트있는 윗부분 높이
    private var footerSizeHeight: CGFloat = 89
    
    var myPointData: KKPointModel<AccountPointDataModel>? {
        didSet {
            guard let totalPoints = myPointData?.data?.totalPoints,
                  let formattedPoint = Formatter.Number.numberFormatter.string(from: NSNumber(value: totalPoints)),
                  let totalPages = myPointData?.pagination?.totalPages
            else { return }
            mainWelcomView.pointLabel.text = "\(formattedPoint)"
            mainWelcomView.pointLabel.customFont(fontName: .NanumSquareRoundEB, size: 18, letterSpacing: -1)
            
            if totalPages <= 1 { // 포인트 내역이 한페이지가 끝일 때(4개 이하)
                footerSizeHeight = 89
            } else {
                footerSizeHeight = 10+44+20+69
            }
            
            DispatchQueue.main.async {
                self.myPointCollectionView.reloadData()
            }
        }
    }
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "포인트 충전/소진내역"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        return navBar
    }()

    private lazy var mainWelcomView: MainTopWelcomeView = {
        let view = MainTopWelcomeView()
        view.presentButtonView.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                           action: #selector(clickPresent)))
        // 이미 로그인 해야만 들어올 수 있는 페이지이므로..
        view.helloLabel.alpha = 1
        view.helloLabel.text = "반가워요, \(AccountManager.shared.user.name ?? "헤이지니")님"
        view.helloLabel.customFont(fontName: .NanumSquareRoundR, size: 17, letterSpacing: -1)
        view.pImageView.alpha = 1
        view.pointLabel.alpha = 1
        view.recommendLabel.alpha = 0
        return view
    }()
    
    private var refreshControl = UIRefreshControl()

    private lazy var myPointCollectionView: UICollectionView = {
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
        setupLayouts()

        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        myPointCollectionView.register(MyPointCollectionViewCell.self, forCellWithReuseIdentifier: myPointCellID)
        myPointCollectionView.register(FooterForPointCell.self,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                       withReuseIdentifier: footerID)
        
    }

    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "elavated")

        view.addSubview(customNavigationBar)
        view.addSubview(mainWelcomView)
        view.addSubview(myPointCollectionView)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }

        mainWelcomView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(personalContainerHeight)
        }

        myPointCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(mainWelcomView.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.bottom.equalToSuperview().offset(-16)
        }
        
        myPointCollectionView.refreshControl = refreshControl
    }

    var pageNum: Int = 0

    func showMoreDatas() {
        // 현재 4개씩 보여주기로 했음!
        NetworkManager.getMyPointData(page: pageNum+1) { [weak self] (result) in
            switch result {
            case .success(let data):
                guard let addedData = data.data?.pointApiResponseList,
                      let totalPages = data.pagination?.totalPages,
                      let currentPage = data.pagination?.currentPage
                else {return}

                self?.myPointData?.data?.pointApiResponseList.append(contentsOf: addedData)
                DispatchQueue.main.async {
                    self?.pageNum += 1
                    if totalPages == currentPage+1 { // 페이지의 끝일 때
                        self?.footerSizeHeight = 89
                    } else {
                        self?.footerSizeHeight = 10+44+20+69
                    }

                    self?.myPointCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "내 포인트 정보를 가져오는데 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    @objc internal func showRV() {
        AdiscopeManager.shared.showRV()
    }
}

extension MyPointViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return myPointData?.data?.pointApiResponseList.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myPointCellID,
                                                         for: indexPath) as? MyPointCollectionViewCell {
            var date = myPointData?.data?.pointApiResponseList[indexPath.item].createdAt
            let name = myPointData?.data?.pointApiResponseList[indexPath.item].content
            let cost = myPointData?.data?.pointApiResponseList[indexPath.item].amount ?? 0
//            let formattedCost = Resource.Number.numberFormatter.string(from: NSNumber(value: cost))
            date = date?.replacingOccurrences(of: "-", with: ".") // 날짜 형식 변경
            date = date?.replacingOccurrences(of: "T", with: " ") // 날짜 형식 변경
            
            cell.pointDateLabel.text = date
            cell.pointDateLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
            cell.pointNameLabel.text = name
            cell.pointNameLabel.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
            var costText = ""
            if let formattedPointCost = Formatter.Number.numberFormatter.string(from: NSNumber(value: cost)) {
                if cost > 0 {
                    costText = "\(formattedPointCost)p 충전"
                } else {
                    costText = "\(formattedPointCost)p 소진"
                }
                // 색칠하고 싶은 부분
                let coloredPoint = "\(formattedPointCost)p"
                let attributedString = NSMutableAttributedString(string: costText)
                attributedString.addAttribute(.foregroundColor, value: Resource.Color.orange06,
                                              range: (costText as NSString).range(of: coloredPoint))
                if let font = UIFont(name: Resource.Font.NanumSquareRoundB.rawValue, size: 13) {
                    let totalRange = NSRange(location: 0, length: attributedString.length)
                    attributedString.addAttributes([NSAttributedString.Key.kern: -0.5,
                                                    NSAttributedString.Key.font: font], range: totalRange)
                    cell.pointCostLabel.attributedText = attributedString
                }
            }
            
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: footerID,
                                                                        for: indexPath) as? FooterForPointCell {
            footer.delegate = self
            footer.layoutIfNeeded() // Footer 사이즈 변경시 call
            return footer
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 82)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: footerSizeHeight)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
            UIView.animate(withDuration: 0.4) {
                self.myPointCollectionView.alpha = 0.3
            } completion: { [weak self] (_) in
                self?.pageNum = -1
                self?.myPointData?.data?.pointApiResponseList.removeAll()
                self?.showMoreDatas()
                UIView.animate(withDuration: 0.4) {
                    self?.myPointCollectionView.alpha = 1
                }
            }
        }
    }
}
