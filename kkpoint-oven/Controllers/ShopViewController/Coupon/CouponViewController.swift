//
//  CouponViewController.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/02/25.
//

import UIKit
import SnapKit

class CouponViewController: UIViewController {
    // 쿠폰 셀 사이즈
    private let couponCellSize: CGSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 116)
    // 쿠폰 리스트
    private var couponList: [CouponList] = []
    
    let customNavigationBar = CustomNavigationBar()

    lazy var couponCollectionView: UICollectionView =
        UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout().then {
        $0.minimumLineSpacing = 10
        $0.scrollDirection = .vertical
    }).then {
        $0.backgroundColor = UIColor(named: "base")
        $0.showsVerticalScrollIndicator = false
        $0.alwaysBounceVertical = true
        $0.bounces = true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.title = "쿠폰"
        setupLayouts()
        configure()
        getCouponData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if !AccountManager.shared.isLogged { // 로그인 안했을 시 로그인창으로
            let loginVC = LoginViewController()
            if #available(iOS 13.0, *) {
                loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
            } else {
                loginVC.modalPresentationStyle = .fullScreen
            }
            present(loginVC, animated: true)
        }
        
        let kind = UICollectionView.elementKindSectionHeader
        let indexPath = IndexPath(item: 0, section: 0)
        guard let header = couponCollectionView.supplementaryView(forElementKind: kind,
                                                            at: indexPath) as? CouponHeaderCell else { return }
        header.checkLogin()
    }

    private func configure() {
        couponCollectionView.delegate = self
        couponCollectionView.dataSource = self
        couponCollectionView.register(CouponCell.self, forCellWithReuseIdentifier: CouponCell.description())
        couponCollectionView.register(CouponHeaderCell.self,
                                      forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                      withReuseIdentifier: CouponHeaderCell.description())
        
    }
    
    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")

        view.addSubview(customNavigationBar)
        view.addSubview(couponCollectionView)
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56+statusBarHeight)
        }
        
        couponCollectionView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
        }
    }
    
    private func getCouponData() {
        NetworkManager.getCouponListData { [weak self] result in
            switch result {
            case .success(let response):
                guard let couponListData = response.data else {return}
                self?.couponList = couponListData
                self?.couponCollectionView.reloadData()
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "쿠폰 데이터를 가져오는데 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
    }
}

extension CouponViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return couponList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CouponCell.description(),
                                                         for: indexPath) as? CouponCell {
            cell.mappingData(data: couponList[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return couponCellSize
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = CouponDetailViewController()
        nextVC.mappingData(data: couponList[indexPath.row])
        navigationController?.pushViewController(nextVC, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: CouponHeaderCell.description(),
            for: indexPath) as? CouponHeaderCell {
            return header
        } else {
            return UICollectionViewCell()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 72)
    }

}
