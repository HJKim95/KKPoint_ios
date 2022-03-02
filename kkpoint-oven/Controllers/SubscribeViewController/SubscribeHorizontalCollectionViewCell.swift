//
//  SubscribeHorizontalCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class SubscribeHorizontalCollectionViewCell: UICollectionViewCell {
    
    private let subscribeProfileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.backgroundColor = UIColor(named: "base")
        imageview.layer.cornerRadius = 24
        imageview.layer.masksToBounds = true
        imageview.layer.borderWidth = 0.3
        imageview.layer.borderColor = Resource.Color.grey03.cgColor
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    private let subscribeNameLabel: UILabel = {
        let label = UILabel()
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
    
    func mappingData(data: Channel) {
        subscribeNameLabel.text = data.cname
        subscribeNameLabel.customFont(fontName: .NanumSquareRoundR, size: 11, letterSpacing: -0.3)
        subscribeNameLabel.textAlignment = .center
        subscribeNameLabel.numberOfLines = 1
        subscribeNameLabel.lineBreakMode = .byTruncatingTail
        
        guard let url = URL(string: data.profileUrl ?? "") else { return }
        subscribeProfileImageView.kf.setImage(with: url)
    }
    
    private func setupLayouts() {

        addSubview(subscribeProfileImageView)
        addSubview(subscribeNameLabel)

        subscribeProfileImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.left.right.equalToSuperview().inset(1)
            make.height.equalTo(subscribeProfileImageView.snp.width)
        }

        subscribeNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(subscribeProfileImageView.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-12)
        }
    }
}
