//
//  MyPointCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class MyPointCollectionViewCell: UICollectionViewCell {

    let pointNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        return label
    }()

    let pointCostLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        return label
    }()
    
    let pointDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "disable")
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayouts() {
        addSubview(pointNameLabel)
        addSubview(pointCostLabel)
        addSubview(pointDateLabel)

        pointNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-56)
            make.height.equalTo(22)
        }
        
        pointCostLabel.snp.makeConstraints { (make) in
            make.top.equalTo(pointNameLabel.snp.bottom).offset(2)
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-56)
            make.height.equalTo(18)
        }

        pointDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(pointCostLabel.snp.bottom).offset(2)
            make.left.equalToSuperview()
            make.right.equalToSuperview().offset(-56)
            make.height.equalTo(16)
        }
    }
}
