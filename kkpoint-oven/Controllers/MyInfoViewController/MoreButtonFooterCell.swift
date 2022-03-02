//
//  MoreButtonFooterCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/02.
//

import UIKit
import SnapKit

protocol MoreButtonFooterToInfoSubViewControllers: class {
    func showMoreDatas()
}

class MoreButtonFooterCell: UICollectionViewCell {

    weak var delegate: MoreButtonFooterToInfoSubViewControllers?
    
    private lazy var moreButtonView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = Resource.Color.grey03.cgColor
        view.layer.cornerRadius = 22
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickShowMore)))
        return view
    }()
    
    private let moreLabel: UILabel = {
        let label = UILabel()
        label.text = "더보기"
        label.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        return label
    }()
    
    private let moreImageView: UIImageView = {
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
        addSubview(moreButtonView)
        moreButtonView.addSubview(moreLabel)
        moreButtonView.addSubview(moreImageView)
        
        moreButtonView.snp.makeConstraints { (make) in
            make.width.equalTo(98)
            make.height.equalTo(44)
            make.center.equalToSuperview()
        }
        
        moreImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.right.equalToSuperview().offset(-16)
            make.width.equalTo(moreImageView.snp.height)
        }

        moreLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(11)
            make.bottom.equalToSuperview().offset(-11)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(moreImageView.snp.left)
        }
    }

    @objc private func clickShowMore() {
        delegate?.showMoreDatas()
    }
}
