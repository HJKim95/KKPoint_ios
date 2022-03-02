//
//  DetailRelatedProductCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/24.
//

import UIKit
import SnapKit

class DetailRelatedProductCell: UICollectionViewCell {
    
    var relatedItems: [RelatedVideoItem]? {
        didSet {
            DispatchQueue.main.async {
                self.relatedProductCollectionView.reloadData()
            }
        }
    }
    
    private let relatedProductLabel = UILabel().then {
        $0.text = "영상에서 나온 상품이에요"
        $0.textColor = UIColor(named: "primary02")
        $0.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
    }
    
    private lazy var relatedProductCollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumLineSpacing = 20
            $0.minimumInteritemSpacing = 12
            $0.scrollDirection = .vertical
        }
    ).then {
        $0.register(ProductCell.self, forCellWithReuseIdentifier: ProductCell.description())
        $0.backgroundColor = UIColor(named: "elavated")
        $0.delegate = self
        $0.dataSource = self
        $0.backgroundColor = .clear
        $0.showsVerticalScrollIndicator = false
        $0.isScrollEnabled = false
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        
        addSubview(relatedProductLabel)
        relatedProductLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(14)
            make.left.equalToSuperview()
            make.height.equalTo(18)
            make.right.equalToSuperview()
        }
        
        addSubview(relatedProductCollectionView)
        relatedProductCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(relatedProductLabel.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
    }
}

extension DetailRelatedProductCell: UICollectionViewDelegate, UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return relatedItems?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (frame.width-12)/2
        let height = width * 1.02 + 10 + 36 + 2 + 18 // 32 = 제목 height
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ProductCell.description(), for: indexPath) as? ProductCell
        else {return UICollectionViewCell()}
        if let item = relatedItems?[indexPath.row] {
            cell.mappingData(product: item)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let urlString = relatedItems?[indexPath.item].vitemLinkUrl,
              let url = URL(string: urlString)
        else { return }
        UIApplication.shared.open(url)
    }
}
