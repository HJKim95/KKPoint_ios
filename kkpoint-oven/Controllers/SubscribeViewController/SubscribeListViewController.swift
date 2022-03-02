//
//  SubscribeListViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

protocol SubscribeListCollectionViewCellToSubscribeListViewController: class {
    func cancelSubscribe(index: Int)
}

class SubscribeListViewController: UIViewController, SubscribeListCollectionViewCellToSubscribeListViewController {
    
    private var subscribeList: [Channel] = []
    
    private let subscribeListCellID = String(describing: SubscribeListCollectionViewCell.self)
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "구독채널"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        return navBar
    }()

    private lazy var subscribeListCollectionView: UICollectionView = {
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
    
    private let noSubscribedLabel: UILabel = UILabel().then {
        $0.text = "구독한 채널이 없습니다."
        $0.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "primary01")
        $0.textAlignment = .center
    }
    private let noSubscribedImage: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "imgSearchNone2")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        subscribeListCollectionView.register(SubscribeListCollectionViewCell.self,
                                             forCellWithReuseIdentifier: subscribeListCellID)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkChangeSubscribe),
                                               name: Notification.Subscribe.checkSubscribe,
                                               object: nil)
    }
    
    @objc func checkChangeSubscribe() {
        NetworkManager.getMyChannels(page: 0) { [weak self] result in
            switch result {
            case .success(let response):
                self?.subscribeList = response.data
                self?.subscribeListCollectionView.reloadData()
            case .failure(let error):
                print("getSubscribeData ERROR : \(error)")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")
        view.addSubview(customNavigationBar)
        view.addSubview(subscribeListCollectionView)
        view.addSubview(noSubscribedLabel)
        view.addSubview(noSubscribedImage)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        subscribeListCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
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
    }
    // 구독 테이블 데이터 매핑
    func mappingData(data: [Channel]) {
        subscribeList = data
    }
    
    // 구독 취소하기
    func cancelSubscribe(index: Int) {
        // 취소 시도
        SubscribeManager.cancel(cid: subscribeList[index].cid) { [weak self] in
            // 토스트 띄우기
            let message: String = self?.subscribeList[index].cname ?? "채널"
            ToastManager.showToast(message: "\(message)의 구독이 해지되었습니다.")
            // 테이블 셀 지우기
            self?.subscribeList.remove(at: index)
            DispatchQueue.main.async {
                self?.subscribeListCollectionView.reloadData()
            }
        }
    }
}

extension SubscribeListViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if subscribeList.count == 0 {
            noSubscribedLabel.alpha = 1
            noSubscribedImage.alpha = 1
            subscribeListCollectionView.alpha = 0
        } else {
            noSubscribedLabel.alpha = 0
            noSubscribedImage.alpha = 0
            subscribeListCollectionView.alpha = 1
        }
        
        return subscribeList.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: subscribeListCellID,
                                                         for: indexPath) as? SubscribeListCollectionViewCell {

            cell.delegate = self
            cell.subscribeNameLabel.text = subscribeList[indexPath.item].cname
            cell.tag = indexPath.item
            guard let url = URL(string: subscribeList[indexPath.item].profileUrl ?? "") else { return cell }
            cell.subscribeProfileImageView.kf.setImage(with: url)
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 56)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = SearchViewController()
        nextVC.isChannelHome = true
        nextVC.cid = subscribeList[indexPath.row].cid
        guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        navi.pushViewController(nextVC, animated: true)
    }
}
