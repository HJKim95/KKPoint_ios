//
//  TotalYoutubeCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/25.
//

import UIKit
import SnapKit

class TotalYoutubeCollectionViewCell: UICollectionViewCell {
    
    var videoList: [Video] = []
    var cellSizeArray = [CGFloat]()
    let cellid = "cellid"

    lazy var youtubeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "base")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.contentInset = UIEdgeInsets(top: 16, left: 0, bottom: 0, right: 0)
        return collectionview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
        
        youtubeCollectionView.register(MainYoutubeVideoCell.self,
                                       forCellWithReuseIdentifier: MainYoutubeVideoCell.description())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        backgroundColor = UIColor(named: "base")
        
        addSubview(youtubeCollectionView)
        youtubeCollectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}

extension TotalYoutubeCollectionViewCell: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = cellSizeArray[indexPath.item]
        return CGSize(width: collectionView.frame.width-32, height: height)
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: MainYoutubeVideoCell.description(), for: indexPath) as? MainYoutubeVideoCell
        else {return UICollectionViewCell()}
        cell.mappingData(data: videoList[indexPath.item])
        return cell
        
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let nextVC = DetailYoutubeViewController()
        nextVC.video = videoList[indexPath.item]
        Utilities.topViewController()?.navigationController?.pushViewController(nextVC, animated: true)
    }

    // for smooth scroll with rounded cell & shadow
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
    
}
