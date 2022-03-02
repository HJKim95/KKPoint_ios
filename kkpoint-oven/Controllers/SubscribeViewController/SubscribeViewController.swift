//
//  SubscribeViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

protocol SubscribeHeaderCellToSubscribeViewController: class {
    func showSubscribeList()
}

class SubscribeViewController: UIViewController, SubscribeHeaderCellToSubscribeViewController {

    private var mySubscribeVideos: [Video] = []
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    let subscribeHeaderHeight: CGFloat = 90
    lazy var totalHeight = totalCustomNavBarHeight + subscribeHeaderHeight
    
    private let customNavigationBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar()
        navBar.mainTitleButton.addTarget(self, action: #selector(goTop), for: .touchUpInside)
        return navBar
    }()
    
    lazy var subscribeHeaderView: SubscribeHeaderView = {
        let headerView = SubscribeHeaderView()
        headerView.delegate = self
        subscribeHeaderCellConect = headerView
        return headerView
    }()
    
    private var refreshControl = UIRefreshControl()
    
    lazy var subscribeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "base")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        collectionview.prefetchDataSource = self
        return collectionview
    }()
    
    private let noSubscribedLabel: UILabel = UILabel().then {
        $0.text = "구독한 채널이 없습니다."
        $0.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary01")
        $0.textAlignment = .center
        $0.alpha = 0
    }
    private let noSubscribedImage: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "imgSearchNone2")
        $0.alpha = 0
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "구독"
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayouts()
        getMyChannelVideos()
        subscribeCollectionView.register(MainYoutubeVideoCell.self,
                                         forCellWithReuseIdentifier: MainYoutubeVideoCell.description())
        
        // 구독 정보 변경 관련 노티피케이션 설정
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkChangeSubscribe),
                                               name: Notification.Subscribe.checkSubscribe,
                                               object: nil)
    }
    
    // 다른 곳에서 구독 정보가 변경되었을 경우 반영하기 위한 작업.
    private var subscribeHeaderCellConect: SubscribeHeaderView?
    @objc func checkChangeSubscribe() {
        guard let subscribeHeaderCellConect = subscribeHeaderCellConect else { return } // 아직 구독 화면 그리기 전 -> 패스
        subscribeHeaderCellConect.clearSubscribeData() // 구독 채널 목록 지우기
        clearChannelVideos() // 비디오 지우기
        if AccountManager.shared.isLogged {
            subscribeHeaderCellConect.getSubscribeData() // 구독 채널 목록 리로드
            getMyChannelVideos() // 비디오 리로드
        }
    }

    private var isPresented = false
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if !AccountManager.shared.isLogged { // 로그인 안하고 구독뷰 올시, 로그인 프레젠트
            let loginVC = LoginViewController()
            if #available(iOS 13.0, *) {
                loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
                isPresented = true
                present(loginVC, animated: true)
            } else {
                if !isPresented {
                    present(loginVC, animated: true)
                }
                isPresented.toggle()
            }
        }
    }
    
    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")
        view.addSubview(subscribeHeaderView)
        view.addSubview(subscribeCollectionView)
        view.addSubview(noSubscribedLabel)
        view.addSubview(noSubscribedImage)
        view.addSubview(customNavigationBar)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        subscribeHeaderView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(totalCustomNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(subscribeHeaderHeight)
        }
        
        subscribeCollectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(totalCustomNavBarHeight+subscribeHeaderHeight)
            make.left.right.bottom.equalToSuperview()
        }
        noSubscribedLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(123)
        }
        noSubscribedImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(noSubscribedLabel.snp.bottom).offset(24)
            $0.width.equalTo(170)
            $0.height.equalTo(190)
        }
        
        subscribeCollectionView.refreshControl = refreshControl
        
    }
    
    private var page: Int = 0
    private var isLastPage: Bool = false
    private func getMyChannelVideos() {
        NetworkManager.getMyChannelsVideos(page: page) { [weak self] result in
            switch result {
            case .success(let response):
                guard let self = self else { return }
                self.page += 1
                response.data.forEach { self.calculateTextSize(text: $0.title!) }
                if self.mySubscribeVideos.count == 0 {
                    self.mySubscribeVideos = response.data
                    DispatchQueue.main.async {
                        self.subscribeCollectionView.reloadData()
                    }
                } else {
                    self.mySubscribeVideos.append(contentsOf: response.data)
                    
                    DispatchQueue.main.async {
                        self.subscribeCollectionView.reloadData()
                    }
                }
                if response.pagination.totalPages == response.pagination.currentPage+1 ||
                    response.pagination.totalPages == 0 { // 페이지의 끝일 때
                    self.isLastPage = true
                }
            case .failure(let error):
                print("getMyChannelsVideos ERROR : \(error)")
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
    
    private func clearChannelVideos() {
        page = 0
        isLastPage = false
        mySubscribeVideos.removeAll()
        subscribeCollectionView.reloadData()
    }

    @objc internal func showSubscribeList() {
        guard let subscribeHeaderCellConect = subscribeHeaderCellConect else { return }
        let nextVC = SubscribeListViewController()
        nextVC.mappingData(data: subscribeHeaderCellConect.mySubscribeChannels) 
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    @objc private func goTop() {
        subscribeCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
                                        at: .centeredVertically, animated: true)
    }
    
    func navBarUp() {
        self.customNavigationBar.alpha = 1
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

extension SubscribeViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if mySubscribeVideos.count == 0 {
            noSubscribedLabel.alpha = 1
            noSubscribedImage.alpha = 1
            subscribeHeaderView.alpha = 0
            subscribeCollectionView.alpha = 0
        } else {
            noSubscribedLabel.alpha = 0
            noSubscribedImage.alpha = 0
            subscribeHeaderView.alpha = 1
            subscribeCollectionView.alpha = 1
        }
        
        return mySubscribeVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = cellSizeArray[indexPath.item]
        return CGSize(width: collectionView.frame.width-32, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainYoutubeVideoCell.description(),
                                                         for: indexPath) as? MainYoutubeVideoCell {
            cell.mappingData(data: mySubscribeVideos[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = DetailYoutubeViewController()
        nextVC.video = mySubscribeVideos[indexPath.row]
        self.navigationController?.pushViewController(nextVC, animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = scrollView.contentOffset.y
        let delta = lastContentOffset - offsetY

        if delta > 0 && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height {
                // move up
            if !didShowNavBar && delta > 5 {
                self.navBarDown()
            }
            
            subscribeHeaderView.alpha = 1
            if offsetY < 0 { offsetY = 0 } // 탭 눌러서 올라갈때를 대응
            
            if offsetY > -16 {
                subscribeHeaderView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(totalCustomNavBarHeight-min(offsetY, totalHeight))
                    make.left.right.equalToSuperview()
                    make.height.equalTo(subscribeHeaderHeight)
                }
                
                subscribeCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(max(totalHeight-min(offsetY, totalHeight), statusBarHeight))
                    make.left.right.bottom.equalToSuperview()
                }
            }

        } else if delta < 0 && offsetY > 0 && scrollView.contentSize.height > scrollView.frame.height {
            // move down
            if offsetY > totalHeight && didShowNavBar && delta < -8 {
                self.navBarUp()
            } else {
                if offsetY < totalHeight {
                    let navBarAlpha = max(1 - (offsetY*1.3/totalHeight), 0)
                    customNavigationBar.alpha = navBarAlpha
                    customNavigationBar.snp.remakeConstraints { (make) in
                        make.top.equalToSuperview().offset(-min(offsetY, totalHeight))
                        make.left.right.equalToSuperview()
                        make.height.equalTo(totalCustomNavBarHeight)
                    }
                    didShowNavBar = false
                }
                
                var headerAlpha: CGFloat = 1
                if offsetY > totalCustomNavBarHeight {
                    headerAlpha = max(1 - ((offsetY-totalCustomNavBarHeight)/subscribeHeaderHeight), 0)
                }

                subscribeHeaderView.alpha = headerAlpha
                subscribeHeaderView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(totalCustomNavBarHeight-min(offsetY, totalHeight))
                    make.left.right.equalToSuperview()
                    make.height.equalTo(subscribeHeaderHeight)
                }
                
                subscribeCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(max(totalHeight-min(offsetY, totalHeight), statusBarHeight))
                    make.left.right.bottom.equalToSuperview()
                }
            }
        }

        // update the new position acquired
        lastContentOffset = offsetY
    }

    // for smooth scroll with rounded cell & shadow
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if collectionView == subscribeCollectionView {
            cell.contentView.layer.masksToBounds = true
            let radius = cell.contentView.layer.cornerRadius
            cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
            UIView.animate(withDuration: 0.4) {
                self.subscribeCollectionView.alpha = 0.3
            } completion: { [weak self] (_) in
                self?.mySubscribeVideos.removeAll()
                self?.page = 0
                self?.getMyChannelVideos()
                UIView.animate(withDuration: 0.4) {
                    self?.subscribeCollectionView.alpha = 1
                }
            }
        }
    }
}

extension SubscribeViewController: UICollectionViewDataSourcePrefetching {
    // for pagination
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        var index = 0
        while index < indexPaths.count {
            let indexPath = indexPaths[index]
            if mySubscribeVideos.count == indexPath.item+1 {
                self.getMyChannelVideos()
            }
            index += 1
        }
    }
}
