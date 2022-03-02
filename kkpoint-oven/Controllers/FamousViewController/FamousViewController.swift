//
//  FamousViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit
import GoogleMobileAds

class FamousViewController: UIViewController {
    
    private let famousCellID = String(describing: MainYoutubeVideoCell.self)

    private let adShowTerm = Resource.AdMob.adShowTerm
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    private let customNavigationBar: CustomNavigationBar = {
        let navBar = CustomNavigationBar()
        navBar.mainTitleButton.addTarget(self, action: #selector(goTop), for: .touchUpInside)
        return navBar
    }()
    
    private var refreshControl = UIRefreshControl()

    lazy var famousCollectionView: UICollectionView = {
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

    var videoList: [Video] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        getVideoData()
        self.title = "인기"
        
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        let cells = [MainYoutubeVideoCell.self, AdmobCell.self]
        cells.forEach { (cell) in
            famousCollectionView.register(cell.self, forCellWithReuseIdentifier: String(describing: cell.self))
        }
    }

    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")
        view.addSubview(famousCollectionView)
        view.addSubview(customNavigationBar)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }

        famousCollectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(totalCustomNavBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
        famousCollectionView.refreshControl = refreshControl
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private var page: Int = 0
    private var isLastPage: Bool = false
    private func getVideoData() {
        NetworkManager.getAllVideos(page: page) { [weak self] result in
            switch result {
            case .success(let response):
                guard let self = self else { return }
                self.page += 1
                response.data.forEach { self.calculateTextSize(text: $0.title!) }
                if self.videoList.count == 0 {
                    self.videoList = response.data
                    DispatchQueue.main.async {
                        self.famousCollectionView.reloadData()
                    }
                } else {
                    self.videoList.append(contentsOf: response.data)
                    DispatchQueue.main.async {
                        self.famousCollectionView.reloadData()
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
    
    @objc private func goTop() {
        famousCollectionView.scrollToItem(at: IndexPath(item: 0, section: 0),
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

extension FamousViewController: UICollectionViewDelegate,
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
            return CGSize(width: collectionView.frame.width-32, height: height)
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var item = indexPath.item + 1
        if item % (adShowTerm+1) == 0 {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Resource.AdMob.admobID,
                                                             for: indexPath) as? AdmobCell {
                cell.mappingData(rootVC: self)
                return cell
            }
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: famousCellID,
                                                             for: indexPath) as? MainYoutubeVideoCell {
                item -= item/(adShowTerm+1)
                item -= 1 // indexPath 는 0부터 시작하니까 다시 index 맞춰주기
                cell.mappingData(data: videoList[item])
                return cell
            }
            return UICollectionViewCell()
        }
        return UICollectionViewCell()
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = scrollView.contentOffset.y
        let delta = lastContentOffset - offsetY
        let collectionViewOffset = max(totalCustomNavBarHeight-min(offsetY, totalCustomNavBarHeight), statusBarHeight)
        if delta > 0 && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height {
                // move up
            if !didShowNavBar && delta > 5 {
                self.navBarDown()
            }
            if offsetY < 0 { offsetY = 0 } // 탭 눌러서 올라갈때를 대응
            
            if offsetY > -16 {
                famousCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(
                        max(totalCustomNavBarHeight - min(offsetY, totalCustomNavBarHeight), statusBarHeight))
                    make.left.right.bottom.equalToSuperview()
                }
            }

        } else if delta < 0 && offsetY > 0 && scrollView.contentSize.height > scrollView.frame.height {
            // move down
            if offsetY > totalCustomNavBarHeight && didShowNavBar && delta < -8 {
                self.navBarUp()
            } else {
                if offsetY <= totalCustomNavBarHeight {
                    let alpha = max((totalCustomNavBarHeight-offsetY*1.3)/totalCustomNavBarHeight, 0)
                    customNavigationBar.alpha = alpha
                    didShowNavBar = false
                    
                    customNavigationBar.snp.remakeConstraints { (make) in
                        make.top.equalToSuperview().offset(-min(offsetY, totalCustomNavBarHeight))
                        make.left.right.equalToSuperview()
                        make.height.equalTo(totalCustomNavBarHeight)
                    }
                }
                famousCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(collectionViewOffset)
                    make.left.right.bottom.equalToSuperview()
                }
            }
            
        }

        // update the new position acquired
        lastContentOffset = offsetY
    }

    // for smooth scroll with rounded cell & shadow
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing {
            self.refreshControl.endRefreshing()
            UIView.animate(withDuration: 0.4) {
                self.famousCollectionView.alpha = 0.3
            } completion: { [weak self] (_) in
                self?.videoList.removeAll()
                self?.page = 0
                self?.getVideoData()
                UIView.animate(withDuration: 0.4) {
                    self?.famousCollectionView.alpha = 1
                }
            }
        }
    }
    
}

extension FamousViewController: UICollectionViewDataSourcePrefetching {
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
