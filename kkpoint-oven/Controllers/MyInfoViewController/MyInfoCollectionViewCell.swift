//
//  MyInfoCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class MyInfoCollectionViewCell: UICollectionViewCell {
    
    let myInfoCategoryImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.backgroundColor = .clear
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    let myInfoGoImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.backgroundColor = .clear
        imageview.contentMode = .scaleAspectFit
        imageview.image = UIImage(named: "btnArrowRight24White")
        return imageview
    }()

    let myInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
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
        addSubview(myInfoCategoryImageView)
        addSubview(myInfoGoImageView)
        addSubview(myInfoCategoryLabel)
        
        myInfoCategoryImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(myInfoCategoryImageView.snp.height)
            
        }
        
        myInfoGoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-16)
            make.width.equalTo(myInfoCategoryImageView.snp.height)
        }

        myInfoCategoryLabel.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(myInfoCategoryImageView.snp.right).offset(10)
            make.right.equalTo(myInfoGoImageView.snp.left).offset(-10)
        }
    }
}
