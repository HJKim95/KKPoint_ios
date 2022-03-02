//
//  MyShopViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

protocol MyCouponCollectionViewCellToMyShopViewController: class {
    func gotoLink(index: Int)
    func copyCoupon(index: Int)
}

class MyCouponViewController: UIViewController, MoreButtonFooterToInfoSubViewControllers,
                            MyCouponCollectionViewCellToMyShopViewController {

    private let myShopCellID = String(describing: MyCouponCollectionViewCell.self)
    private let myCouponContentCellID = String(describing: MyCouponContentCell.self)
    private let footerID = String(describing: MoreButtonFooterCell.self)

    private var footerSizeHeight: CGFloat = 0
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "쿠폰 보관함"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        return navBar
    }()

    private lazy var myCouponCollectionView: UICollectionView = {
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
    
    private let noCouponLabel: UILabel = UILabel().then {
        $0.text = "보유하신 쿠폰이 없습니다."
        $0.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary01")
        $0.textAlignment = .center
    }
    private let noCouponImage: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "imgSearchNone")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        showMoreDatas()
        
        let cells = [MyCouponCollectionViewCell.self, MyCouponContentCell.self]
        cells.forEach { (cell) in
            myCouponCollectionView.register(cell.self, forCellWithReuseIdentifier: String(describing: cell.self))
        }
        myCouponCollectionView.register(MoreButtonFooterCell.self,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                       withReuseIdentifier: footerID)
        
        AccountManager.shared.setNewCouponState(bool: false)
    }

    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "elavated")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil

        view.addSubview(customNavigationBar)
        view.addSubview(myCouponCollectionView)
        view.addSubview(noCouponLabel)
        view.addSubview(noCouponImage)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }

        myCouponCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.bottom.equalToSuperview()
        }
        
        noCouponLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(123)
        }
        noCouponImage.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(noCouponLabel.snp.bottom).offset(24)
            $0.width.equalTo(170)
            $0.height.equalTo(190)
        }
    }
    
    var checkExpanded = [Bool]()
    private var myCouponList: [UserCoupon] = []

    private var pageNum: Int = -1
    
    internal func showMoreDatas() {
        NetworkManager.getUserCoupons(page: pageNum+1) { [weak self] result in
            switch result {
            case .success(let response):
                guard let data = response.data,
                      let totalPages = response.pagination?.totalPages,
                      let currentPage = response.pagination?.currentPage
                else {return}

                if self?.pageNum == -1 { // 처음 데이터 받아올 때
                    self?.myCouponList = data
                } else { // 추가적으로 페이징 할 때
                    self?.myCouponList.append(contentsOf: data)
                }
                let defaultTestArray = Array(repeating: false, count: data.count)
                self?.checkExpanded.append(contentsOf: defaultTestArray)
                
                DispatchQueue.main.async {
                    self?.pageNum += 1
                    if totalPages == currentPage+1 || totalPages == 0 { // 페이지의 끝일 때
                        self?.footerSizeHeight = 0
                    } else {
                        self?.footerSizeHeight = 50
                    }
                    self?.myCouponCollectionView.reloadData()
                }
            case .failure(let error):
                print("getUserCoupons Error : \(error)")
            }
        }
    }
    
    func gotoLink(index: Int) {
        
        guard let homepage = myCouponList[index].homepageUrl,
              let url = URL(string: homepage)
        else {return}
        UIApplication.shared.open(url)
    }
    
    func copyCoupon(index: Int) {
        UIPasteboard.general.string = myCouponList[index].couponId
        ToastManager.showToast(message: "\(myCouponList[index].couponId)가 복사되었습니다.")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }

}

extension MyCouponViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if myCouponList.count == 0 {
            noCouponLabel.alpha = 1
            noCouponImage.alpha = 1
            myCouponCollectionView.alpha = 0
            view.backgroundColor = UIColor(named: "base")
        } else {
            noCouponLabel.alpha = 0
            noCouponImage.alpha = 0
            myCouponCollectionView.alpha = 1
            view.backgroundColor = UIColor(named: "elavated")
        }
        return myCouponList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if !checkExpanded[indexPath.item] {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myShopCellID,
                                                             for: indexPath) as? MyCouponCollectionViewCell {
                
                cell.adminNameLabel.text = myCouponList[indexPath.row].admin
                cell.adminNameLabel.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
                
                cell.couponNameLabel.text = myCouponList[indexPath.row].couponName
                cell.couponNameLabel.customFont(fontName: .NanumSquareRoundB, size: 13, letterSpacing: -0.5)
                
                cell.couponDueDateLabel.text = myCouponList[indexPath.row].createdAt.split(separator: "T")[0].description
                cell.couponDueDateLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)

                if checkExpanded.count >= indexPath.item+2 && checkExpanded[indexPath.item+1] {
                    cell.arrowImageView.image = UIImage(named: "btnArrowUp24White")
                } else {
                    cell.arrowImageView.image = UIImage(named: "btnArrowDown24White")
                }

                return cell
            }
            return UICollectionViewCell()
        } else {
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myCouponContentCellID,
                                                             for: indexPath) as? MyCouponContentCell {
                cell.tag = indexPath.row
                cell.delegate = self
                cell.couponDetailLabel.text = myCouponList[indexPath.row].couponId
                cell.couponDetailLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
                
                cell.dateDetailLabel.text = myCouponList[indexPath.row].validDate
                cell.dateDetailLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
                
                cell.storeDetailLabel.text = myCouponList[indexPath.row].homepage
                cell.storeDetailLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
                return cell
            }
            return UICollectionViewCell()
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: footerID,
                                                                        for: indexPath) as? MoreButtonFooterCell {
            footer.delegate = self
            
            return footer
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if checkExpanded[indexPath.item] { // content cell
            return CGSize(width: collectionView.frame.width, height: 202)
        } else { // 기본 cell
            return CGSize(width: collectionView.frame.width, height: 82)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: footerSizeHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newIndex = indexPath.item+1
        let newIndexPath = IndexPath(item: newIndex, section: 0)
        
        if checkExpanded.count >= newIndex+1 && checkExpanded[newIndex] { // 넓힌걸 줄이기
            self.checkExpanded.remove(at: newIndex)
            self.myCouponList.remove(at: newIndex)
            self.myCouponCollectionView.deleteItems(at: [newIndexPath])
        } else { // 줄여진걸 넗히기
            if !checkExpanded[indexPath.item] {
                let testData = myCouponList[indexPath.item] // 자기와 같은 놈을 복제해서 content만 가져오기
                self.checkExpanded.insert(true, at: newIndex)
                self.myCouponList.insert(testData, at: newIndex)
                self.myCouponCollectionView.insertItems(at: [newIndexPath])
            }
        }
        if let cell = self.myCouponCollectionView.cellForItem(at: indexPath) as? MyCouponCollectionViewCell {
            cell.arrowImageView.image = nil
        }
        self.myCouponCollectionView.reloadItems(at: [indexPath])
    }
}
