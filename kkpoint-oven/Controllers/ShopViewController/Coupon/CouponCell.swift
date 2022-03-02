//
//  CouponCell.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/02/25.
//

import UIKit
import SnapKit
import Kingfisher

final class CouponCell: UICollectionViewCell {
    private let couponImageView: UIImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.cornerRadius = 42
        $0.layer.masksToBounds = true
        $0.backgroundColor = UIColor(named: "base")
    }

    private let couponTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor(named: "secondary01")
        return label
    }()

    private let couponPriceLabel: UILabel = {
        let label = UILabel()
        
        label.textAlignment = .left
        label.textColor = Resource.Color.orange06
        return label
    }()

    private let couponDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "disable")
        return label
    }()
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }

    /// ㄹㅇ용
    func mappingData(data: CouponList) {
//        couponImageView.image = UIImage(named: "imgCoupon\(data)")
        couponImageView.image = UIImage(named: "imgCoupon\(1000)") // 이미지에 관련한 거 나오기전까지 이거 쓰자..
        couponTitleLabel.text = data.admin
        couponTitleLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        
        couponPriceLabel.text = data.couponName
        couponPriceLabel.customFont(fontName: .NanumSquareRoundEB, size: 16, letterSpacing: -0.3)
        
        couponDateLabel.text = data.dueDate
        couponDateLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        
    }

    private func setupLayouts() {
        backgroundColor = .clear
        layer.applySketchShadow(color: Resource.Color.black03,
                                alpha: 1, widthX: 0, widthY: 0, blur: 12, spread: 0)
        
        contentView.backgroundColor = UIColor(named: "elavated")
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true

        addSubview(couponImageView)
        addSubview(couponTitleLabel)
        addSubview(couponPriceLabel)
        addSubview(couponDateLabel)

        couponImageView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(16)
            $0.leading.equalToSuperview().offset(12)
            $0.width.equalTo(84)
        }

        couponPriceLabel.snp.makeConstraints {
            $0.leading.equalTo(couponImageView.snp.trailing).offset(10)
            $0.centerY.equalToSuperview().offset(1)
        }
        couponTitleLabel.snp.makeConstraints {
            $0.leading.equalTo(couponPriceLabel)
            $0.bottom.equalTo(couponPriceLabel.snp.top).offset(-6)
        }
        couponDateLabel.snp.makeConstraints {
            $0.leading.equalTo(couponPriceLabel)
            $0.top.equalTo(couponPriceLabel.snp.bottom).offset(6)
        }
    }
}
