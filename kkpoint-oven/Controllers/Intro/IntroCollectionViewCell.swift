//
//  IntroCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/09/08.
//

import UIKit

class IntroCollectionViewCell: UICollectionViewCell {
    
    let introImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.layer.masksToBounds = true
        return imageview
    }()
    
    let introTitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = Resource.Color.grey07
        label.textAlignment = .center
        return label
    }()
    
    let introDescLabel: UILabel = {
        let label = UILabel()
        label.textColor = Resource.Color.grey07
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
        backgroundColor = Resource.Color.bgYellow02
        
        addSubview(introImageView)
        addSubview(introDescLabel)
        addSubview(introTitleLabel)
        
        let width = frame.width
        
        if frame.height < 650 { // iphone X 보다 크기가 작은 경우 (7+ 모델들도 포함)
            introTitleLabel.customFont(fontName: .NanumSquareRoundEB, size: 24)
            
            introImageView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(width * 4/3)
            }
            
            introDescLabel.snp.makeConstraints { make in
                make.bottom.equalTo(introImageView.snp.top).offset(-6)
                make.left.equalToSuperview().offset(38)
                make.right.equalToSuperview().offset(-38)
                make.height.equalTo(44)
            }
            
            introTitleLabel.snp.makeConstraints { make in
                make.bottom.equalTo(introDescLabel.snp.top)
                make.left.equalToSuperview().offset(38)
                make.right.equalToSuperview().offset(-38)
                make.height.equalTo(41)
            }
        } else {
            
            introTitleLabel.customFont(fontName: .NanumSquareRoundEB, size: 28)
            introImageView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(width * 4/3)
            }
            
            introDescLabel.snp.makeConstraints { make in
                make.bottom.equalTo(introImageView.snp.top).offset(-38)
                make.left.equalToSuperview().offset(38)
                make.right.equalToSuperview().offset(-38)
                make.height.equalTo(58)
            }
            
            introTitleLabel.snp.makeConstraints { make in
                make.bottom.equalTo(introDescLabel.snp.top).offset(-10)
                make.left.equalToSuperview().offset(38)
                make.right.equalToSuperview().offset(-38)
                make.height.equalTo(41)
            }
        }
    }
}
