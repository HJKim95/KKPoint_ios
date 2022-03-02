//
//  TotalChannelCollectionView.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/25.
//

import UIKit
import SnapKit

class TotalChannelCollectionViewCell: UICollectionViewCell {
    
    var channelList = [Channel]()
    var subscribeList = [Bool]()
    
    var isChannelHome: Bool = false
    
    lazy var channelCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "elavated")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.isScrollEnabled = false
        return collectionview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
        
        channelCollectionView.register(ChannelCollectionViewCell.self,
                                       forCellWithReuseIdentifier: ChannelCollectionViewCell.description())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        backgroundColor = UIColor(named: "elavated")
        
        addSubview(channelCollectionView)
        channelCollectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc func clickSubscribe(_ sender: UIButton) {
        if !AccountManager.shared.isLogged { // 로그인 안했을 시 로그인창으로
            let loginVC = LoginViewController()
            if #available(iOS 13.0, *) {
                loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
            } else {
                loginVC.modalPresentationStyle = .fullScreen
            }
            Utilities.topViewController()?.present(loginVC, animated: true)
            return
        }
        guard let cell = sender.superview?.superview as? ChannelCollectionViewCell else { return }
        guard let indexPath = channelCollectionView.indexPath(for: cell) else { return }
        let index = indexPath.row
        if subscribeList[index] {
            SubscribeManager.cancel(cid: channelList[index].cid) { [weak self] in
                cell.cancelSubecribeUItask()
                self?.subscribeList[index] = false
            }
        } else {
            SubscribeManager.apply(cid: channelList[index].cid) { [weak self] in
                cell.addSubscribeUItask()
                self?.subscribeList[index] = true
            }
        }
    }
}

extension TotalChannelCollectionViewCell: UICollectionViewDelegate,
                                          UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        channelList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ChannelCollectionViewCell.description(),
                for: indexPath) as? ChannelCollectionViewCell else {return UICollectionViewCell()}
        cell.mappingData(channel: channelList[indexPath.row], subscribed: subscribeList[indexPath.row])
        cell.subscribeButton.addTarget(self, action: #selector(clickSubscribe(_:)), for: .touchUpInside)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 72)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isChannelHome { return }
        let nextVC = SearchViewController()
        nextVC.isChannelHome = true
        nextVC.cid = channelList[indexPath.row].cid
        Utilities.topViewController()?.navigationController?.pushViewController(nextVC, animated: true)
    }
}
