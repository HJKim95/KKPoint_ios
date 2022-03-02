//
//  PrivacyViewController.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/08.
//

import UIKit
class PrivacyViewController: UIViewController, CustomTabbarDelegate {
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "약관/개인정보처리방침"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        return navBar
    }()
    
    private lazy var customTabbar: CustomTabbar = {
        let customTabbar = CustomTabbar()
        customTabbar.delegate = self
        return customTabbar
    }()
    
    var firstIndex: Int = -1
    
    private lazy var webViewCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 0
            $0.scrollDirection = .horizontal
        }
    ).then {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = UIColor(named: "base")
        $0.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        $0.showsHorizontalScrollIndicator = false
        $0.isPagingEnabled = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        webViewCollectionView.register(WebViewCell.self,
                                      forCellWithReuseIdentifier: WebViewCell.description())
    }

    private func setupLayouts() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        view.backgroundColor = UIColor(named: "elavated")
        
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }

        view.addSubview(customTabbar)
        customTabbar.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.trailing.leading.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        view.addSubview(webViewCollectionView)
        webViewCollectionView.snp.makeConstraints {
            $0.top.equalTo(customTabbar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if firstIndex != -1 {
            scrollToTabIndex(index: firstIndex, animated: false)
            customTabbar.tabbarCollectionView.selectItem(at: IndexPath(item: firstIndex, section: 0), animated: false,
                                                         scrollPosition: .centeredHorizontally)
        }
    }
    
    func scrollToTabIndex(index: Int, animated: Bool) {
        let width = view.frame.width
        let offsetY = webViewCollectionView.contentOffset.y
        webViewCollectionView.setContentOffset(CGPoint(x: width * CGFloat(index), y: offsetY), animated: animated)

    }
}

extension PrivacyViewController: UICollectionViewDataSource, UICollectionViewDelegate,
                                 UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: WebViewCell.description(),
                                                         for: indexPath) as? WebViewCell {
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        let index = Int(targetContentOffset.pointee.x / view.frame.width)
        let indexPath = IndexPath(item: index, section: 0)
        customTabbar.tabbarCollectionView.selectItem(at: indexPath, animated: true,
                                                     scrollPosition: .centeredHorizontally)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offset = scrollView.contentOffset.x / 2
        let halfWidth = view.frame.width / 2
        let alpha = offset / halfWidth + 1
        let divider = 8 / alpha
        customTabbar.horizontalBarView.snp.remakeConstraints { (make) in
            make.bottom.equalToSuperview()
            // 1/8 -> 1/4
            make.width.equalToSuperview().dividedBy(divider)
            make.height.equalTo(2)
            make.centerX.equalToSuperview().dividedBy(2).offset(offset)
        }
    }
}
