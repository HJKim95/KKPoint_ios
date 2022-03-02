//
//  MyShopCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/17.
//

import UIKit
import SnapKit

class MyCouponCollectionViewCell: UICollectionViewCell {
    
    let adminNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        return label
    }()

    let couponNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = Resource.Color.orange06
        return label
    }()
    
    let couponDueDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "disable")
        return label
    }()
    
    let arrowImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "btnArrowDown24White")
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayouts() {
        addSubview(adminNameLabel)
        addSubview(couponNameLabel)
        addSubview(couponDueDateLabel)
        addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(29)
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(24)
        }

        adminNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(arrowImageView.snp.left).offset(-16)
            make.height.equalTo(22)
        }
        
        couponNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(adminNameLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(arrowImageView.snp.left).offset(-16)
            make.height.equalTo(18)
        }

        couponDueDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(couponNameLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(arrowImageView.snp.left).offset(-16)
            make.height.equalTo(16)
        }
    }
    
}
