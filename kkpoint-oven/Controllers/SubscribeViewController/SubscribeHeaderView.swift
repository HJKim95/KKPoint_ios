//
//  SubscribeHeaderCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/24.
//

import UIKit
import SnapKit

class SubscribeHeaderView: UIView {
    private let subscribeHorizontalCellID = String(describing: SubscribeHorizontalCollectionViewCell.self)

    var mySubscribeChannels: [Channel] = []
    
    weak var delegate: SubscribeHeaderCellToSubscribeViewController?
    
    private lazy var subscribeHorizontalCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 14
        layout.scrollDirection = .horizontal
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "elavated")
        collectionview.showsHorizontalScrollIndicator = false
        collectionview.alwaysBounceHorizontal = true
        collectionview.contentInset = UIEdgeInsets(top: 0, left: 17, bottom: 0, right: 0)
        return collectionview
    }()
    
    private lazy var showSubscribeListLabel: UILabel = {
        let label = UILabel()
        label.text = "전체"
        label.customFont(fontName: .NanumSquareRoundB, size: 13, letterSpacing: -0.5)
        label.textAlignment = .center
        label.textColor = Resource.Color.orange06
        label.backgroundColor = UIColor(named: "elavated")
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showSubscribeList)))
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
        getSubscribeData()
        subscribeHorizontalCollectionView.register(SubscribeHorizontalCollectionViewCell.self,
                                                   forCellWithReuseIdentifier: subscribeHorizontalCellID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        backgroundColor = UIColor(named: "elavated")
        
        addSubview(subscribeHorizontalCollectionView)
        addSubview(showSubscribeListLabel)
        
        showSubscribeListLabel.snp.makeConstraints { (make) in
            make.top.right.equalToSuperview()
            make.height.equalTo(90)
            make.width.equalTo(70)
        }
        
        subscribeHorizontalCollectionView.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview()
            make.height.equalTo(90)
            make.right.equalTo(showSubscribeListLabel.snp.left)
        }
    }
    
    func getSubscribeData() {
        NetworkManager.getMyChannels(page: 0) { [weak self] result in
            switch result {
            case .success(let response):
                self?.mySubscribeChannels = response.data
                self?.subscribeHorizontalCollectionView.reloadData()
            case .failure(let error):
                print("getSubscribeData ERROR : \(error)")
            }
        }
    }
    
    func clearSubscribeData() {
        mySubscribeChannels.removeAll()
        subscribeHorizontalCollectionView.reloadData()
    }
    
    @objc private func showSubscribeList() {
        delegate?.showSubscribeList()
    }
}
extension SubscribeHeaderView: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mySubscribeChannels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: subscribeHorizontalCellID,
                                                         for: indexPath) as? SubscribeHorizontalCollectionViewCell {
            cell.mappingData(data: mySubscribeChannels[indexPath.row])
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 50, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = SearchViewController()
        nextVC.isChannelHome = true
        nextVC.cid = mySubscribeChannels[indexPath.row].cid
        guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        navi.pushViewController(nextVC, animated: true)
    }
}
