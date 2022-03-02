//
//  MyPresentController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/18.
//

import UIKit

class MyPresentController: UIViewController {
    private let presentCellID = String(describing: MyPresentCollectionViewCell.self)
    
    var attendanceData = [[String]]() {
        didSet {
            let data = attendanceData
            let wholeDateFormatter = Formatter.Date.dateFormatterGetWholeDate
            if !data[data.count-1].contains(wholeDateFormatter.string(from: Date())) {
                // 아직 출석하지 않았을 때
                presentButton.backgroundColor = Resource.Color.orange06
                presentButton.setTitleColor(Resource.Color.white00, for: .normal)
                presentButton.isEnabled = true
            }
        }
    }
    
    var pushFromMyInfo = false
    
    var currentIndex: Int = 0
    private var isRewarded = false
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "출석체크"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        return navBar
    }()
    
    private let topDirectionContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    private lazy var leftArrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btnArrowLeft24Grey"), for: .normal)
        button.addTarget(self, action: #selector(clickLeftArrow), for: .touchUpInside)
        return button
    }()
    
    private let yearMonthLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "primary02")
        return label
    }()
    
    private lazy var rightArrowButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "btnArrowRight24Grey"), for: .normal)
        button.addTarget(self, action: #selector(clickRightArrow), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    lazy var horizontalPresentCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "base")
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.isPagingEnabled = true
        collectionview.isScrollEnabled = false
        return collectionview
    }()
    
    private lazy var presentButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(named: "orangeBrown")
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.setTitle("출석하기", for: .normal)
        button.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 16, letterSpacing: -1)
        button.setTitleColor(Resource.Color.orange06, for: .normal)
        button.addTarget(self, action: #selector(clickPresent), for: .touchUpInside)
        button.isEnabled = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(named: "elavated")

        horizontalPresentCollectionView.register(MyPresentCollectionViewCell.self,
                                                 forCellWithReuseIdentifier: presentCellID)

        setupLayouts()
        setupDates()
//        AdiscopeManager.shared.showInterStitial()
    }
    
    private func setupLayouts() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        view.addSubview(customNavigationBar)
        view.addSubview(topDirectionContainerView)
        topDirectionContainerView.addSubview(leftArrowButton)
        topDirectionContainerView.addSubview(rightArrowButton)
        topDirectionContainerView.addSubview(yearMonthLabel)
        view.addSubview(horizontalPresentCollectionView)
        view.addSubview(presentButton)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        topDirectionContainerView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.right.equalToSuperview()
            make.height.equalTo(44)
        }
        
        leftArrowButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(leftArrowButton.snp.height)
        }
        
        rightArrowButton.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(rightArrowButton.snp.height)
        }
        
        yearMonthLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-13)
            make.left.equalTo(leftArrowButton.snp.right)
            make.right.equalTo(rightArrowButton.snp.left)
        }

        horizontalPresentCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(topDirectionContainerView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        presentButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-10)
            make.height.equalTo(50)
        }
    }
    
    private func setupDates() {
        yearMonthLabel.text = getTitleDate(date: Date())
        yearMonthLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        yearMonthLabel.textAlignment = .center
    }
    
    private func getAttendData(dateString: String) {
        NetworkManager.getMyAttendanceData(dateString: dateString) { [weak self] (result) in
            switch result {
            case .success(let data):
                var dateArray = [String]()
                guard let responseList = data.data else {return}
                for date in responseList {
                    dateArray.append(date.createdAt ?? "")
                }
                self?.attendanceData.insert(dateArray, at: 0)
                let indexPath = IndexPath(item: 0, section: 0)
                self?.horizontalPresentCollectionView.insertItems(at: [indexPath])
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "출석정보를 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
    }
    
    @objc private func clickLeftArrow() {
        let value: Int = -attendanceData.count + currentIndex
        let wholeDateFormatter = Formatter.Date.dateFormatterGetWholeDate
        guard let prevMonth = Calendar.current.date(byAdding: .month,
                                                    value: value, to: Date())  else {return}
        yearMonthLabel.text = getTitleDate(date: prevMonth)
        if currentIndex == 0 {
            let indexPath = IndexPath(item: 0, section: 0)
            self.horizontalPresentCollectionView.performBatchUpdates {
                
                // 과거 데이터 한달씩 추출
                let calendar = Formatter.Date.calendar
                let components = calendar.dateComponents([.year, .month], from: prevMonth)
                guard let startOfMonth = calendar.date(from: components) else {return}
                getAttendData(dateString: wholeDateFormatter.string(from: startOfMonth))
            } completion: { (_) in
                DispatchQueue.main.async {
                    self.horizontalPresentCollectionView.scrollToItem(at: indexPath,
                                                                      at: .centeredHorizontally, animated: true)
                }
            }
        } else {
            currentIndex -= 1
            let indexPath = IndexPath(item: currentIndex, section: 0)
            self.horizontalPresentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
        self.rightArrowButton.isEnabled = true
    }

    @objc private func clickRightArrow() {
        let value: Int = -attendanceData.count + currentIndex + 2
        if value < 1 {
            if value == 0 {
                self.rightArrowButton.isEnabled = false
            }
            if let nextMonth = Calendar.current.date(byAdding: .month,
                                                     value: value, to: Date()) {
                yearMonthLabel.text = getTitleDate(date: nextMonth)
            }

            currentIndex += 1
            let indexPath = IndexPath(item: currentIndex, section: 0)
            horizontalPresentCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)

        }
    }

    private func getTitleDate(date: Date) -> String {
        let yearFormatter = Formatter.Date.dateFormatterGetYear
        let monthFormatter = Formatter.Date.dateFormatterGetMonth
        
        let todayYear = yearFormatter.string(from: date)
        let todayMonth = monthFormatter.string(from: date)
        
        let titleDate = "\(todayYear).\(todayMonth)"
        return titleDate
    }

    @objc private func clickPresent() {
        presentButton.backgroundColor = UIColor(named: "orangeBrown")
        presentButton.isEnabled = false
        
        let wholeDateFormatter = Formatter.Date.dateFormatterGetWholeDate
        let monthFormatter = Formatter.Date.dateFormatterGetMonth
        let dateFormatter = Formatter.Date.dateFormatterGetDate
        let month = monthFormatter.string(from: Date())
        let date = dateFormatter.string(from: Date())
        
        // 출석 등록 (post attendance)
        attendanceData[0].append(wholeDateFormatter.string(from: Date()))
        DispatchQueue.main.async {
            self.presentButton.backgroundColor = UIColor(named: "orangeBrown")
            self.presentButton.isEnabled = false
            self.horizontalPresentCollectionView.reloadData()
        }

        // 출석체크 등록 및 자동 point db 자동 추가.
        NetworkManager.postAttendanceData { [weak self] (result) in
            switch result {
            case .success(let data):
                print(data)
                self?.showDidAttend(month: month, date: date)
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "출석체크 관련 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
    }
    
    func popViewControllerTwice() {
        let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
        self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
    }
    
    private func showDidAttend(month: String, date: String) {
        // 변경된 출석과 포인트 가져오기
        AccountManager.shared.getAttendance()
        AccountManager.shared.getPoint()
        let mainString = "\(month)월 \(date)일 출석완료!"
        let subString = "KK포인트 1,000포인트 적립되었습니다."
        PopupManager.shared.showPopup(
            mainStr: mainString, subStr: subString,
            imageName: "imgPopupKKbasic",
            positiveButtonOption: ButtonOption(title: "지금 광고보고 1번 더 적립하기", handler: {
                AdiscopeManager.shared.showRV()
            }),
            negativeButtonOption: ButtonOption(title: "홈으로 가기", handler: {
                if self.pushFromMyInfo {
                    self.popViewControllerTwice()
                } else {
                    self.navigationController?.popViewController(animated: true)
                }
            }),
            backgroundColor: BackgroundColorOption(
                popupViewColor: UIColor(named: "elavated")!, unableViewColor: UIColor.black.withAlphaComponent(0.7)),
            enableBackgroundTouchOut: true
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

extension MyPresentController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return attendanceData.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: presentCellID,
                                                         for: indexPath) as? MyPresentCollectionViewCell {
            let calendar = Formatter.Date.calendar
            let components = calendar.dateComponents([.year, .month], from: Date())
            let value: Int = -attendanceData.count + indexPath.item + 1
            if let startOfMonth = calendar.date(from: components),
               let indexMonth = Calendar.current.date(byAdding: .month,
                                                      value: value, to: startOfMonth) {
                cell.presentMonth = indexMonth
            }

            let presentDates = attendanceData[indexPath.item]
            cell.presentDates = presentDates
            cell.presentDateCollectionView.reloadData()
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
}
