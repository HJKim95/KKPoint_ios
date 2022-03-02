//
//  RelatedProductCell.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/21.
//

import UIKit

class ProductCell: UICollectionViewCell {
    private let imageView = UIImageView().then {
        $0.layer.borderWidth = 0.3
        $0.layer.cornerRadius = 7
        $0.layer.borderColor = Resource.Color.grey03.cgColor
        $0.layer.masksToBounds = true
        $0.contentMode = .scaleAspectFill
    }
    private let name = UILabel().then {
        $0.textColor = UIColor(named: "primary02")
        $0.numberOfLines = 2
    }
    private let price = UILabel().then {
        $0.textColor = Resource.Color.orange06
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    func mappingData(product: RelatedVideoItem) {
        guard let url = URL(string: product.vitemImageUrl) else { return }
        imageView.kf.setImage(with: url)
        name.text = product.vitemName
        name.lineBreakMode = .byTruncatingTail
        name.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3, lineSpacing: 3)
        price.text = decimalWon(product.vitemPrice)
        price.customFont(fontName: .NanumSquareRoundB, size: 13, letterSpacing: -0.3)
    }
    
    private func decimalWon(_ value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = numberFormatter.string(from: NSNumber(value: value))! + "원"
        
        return result
    }
    
    private func setupLayout() {
        addSubview(imageView)
        imageView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(imageView.snp.width).multipliedBy(1.02)
        }
        
        addSubview(name)
        name.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(imageView.snp.bottom).offset(10)
        }
        
        addSubview(price)
        price.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(name.snp.bottom).offset(2)
        }
    }
}
