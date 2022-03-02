//
//  MyEventCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class MyEventCollectionViewCell: UICollectionViewCell {
    
    let eventDateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "secondary01")
        return label
    }()
    
    let eventNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
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
        addSubview(eventNameLabel)
        addSubview(eventDateLabel)
        addSubview(arrowImageView)

        arrowImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(17)
            make.right.equalToSuperview().offset(-16)
            make.height.width.equalTo(24)
        }
        
        eventDateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(arrowImageView.snp.left).offset(-16)
            make.height.equalTo(16)
        }

        eventNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventDateLabel.snp.bottom)
            make.left.equalToSuperview().offset(16)
            make.right.equalTo(arrowImageView.snp.left).offset(-16)
            make.height.equalTo(22)
        }
    }
}
