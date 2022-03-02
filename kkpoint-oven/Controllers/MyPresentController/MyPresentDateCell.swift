//
//  MyPresentDateCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/18.
//

import UIKit
import SnapKit

class MyPresentDateCell: UICollectionViewCell {
    
    let presentImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "imgDailycheckNormal")
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    let presentDateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "secondary01")
        label.textAlignment = .center
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
        backgroundColor = .clear
        
        addSubview(presentImageView)
        addSubview(presentDateLabel)
        
        presentImageView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(presentImageView.snp.width)
        }
        
        presentDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(presentImageView.snp.bottom).offset(2)
            make.bottom.equalToSuperview().offset(-4)
            make.centerX.equalToSuperview()
        }
    }
}
