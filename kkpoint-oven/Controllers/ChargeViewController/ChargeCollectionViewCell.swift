//
//  ChargeCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/24.
//

import UIKit
import SnapKit

class ChargeCollectionViewCell: UICollectionViewCell {

    var presentButtonViewWidth: CGFloat = 89 {
        didSet {
            presentButtonView.snp.makeConstraints { (make) in
                make.top.equalTo(chargeLabel.snp.bottom).offset(8)
                make.left.equalTo(chargeLabel.snp.left)
                make.width.equalTo(presentButtonViewWidth)
                make.height.equalTo(36)
            }
        }
    }
    
    let chargeLabel: UILabel = {
        let label = UILabel()
        label.customFont(fontName: .NanumSquareRoundB, size: 15, letterSpacing: -0.28)
        label.textColor = UIColor(named: "primary02")
        label.textAlignment = .left
        return label
    }()
    
    let presentButtonView: PresentButtonView = {
        let view = PresentButtonView()
        return view
    }()
    
    let backgroundImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        // setting cell cornerRadius & shadow
        backgroundColor = .clear
        layer.masksToBounds = false
        layer.applySketchShadow(color: Resource.Color.black03,
                                alpha: 1, widthX: 0, widthY: 0, blur: 12, spread: 0)
        contentView.backgroundColor = UIColor(named: "elavated")
        contentView.layer.cornerRadius = 12
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        backgroundColor = UIColor(named: "elavated")
        
        contentView.addSubview(backgroundImageView)
        contentView.addSubview(chargeLabel)
        contentView.addSubview(presentButtonView)
        
        backgroundImageView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
        
        chargeLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(18)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(16)
            make.height.equalTo(18)
        }
    }
}
