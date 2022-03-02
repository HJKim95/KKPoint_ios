//
//  MyCouponContentCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/10.
//

import UIKit
import SnapKit

class MyCouponContentCell: UICollectionViewCell {
    
    weak var delegate: MyCouponCollectionViewCellToMyShopViewController?
    
    let detailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "base")
        return view
    }()
    
    let couponTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "disable")
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        label.text = "쿠폰번호"
        return label
    }()
    
    let couponDetailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "secondary01")
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        return label
    }()
    
    let dateTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "disable")
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        label.text = "사용기간"
        return label
    }()
    
    let dateDetailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "secondary01")
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        return label
    }()
    
    let storeTitleLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "disable")
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        label.text = "사용처"
        return label
    }()
    
    let storeDetailLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "secondary01")
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        label.text = "CJ더마켓"
        return label
    }()
    
    lazy var copyLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .right
        label.sizeToFit()
        label.textColor = Resource.Color.blue02
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        let text = "복사하기"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue,
                                      range: (text as NSString).range(of: text))
        attributedString.addAttribute(.underlineColor, value: Resource.Color.blue02,
                                      range: (text as NSString).range(of: text))
        label.attributedText = attributedString
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(copyCoupon)))
        return label
    }()
    
    lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .right
        label.sizeToFit()
        label.textColor = Resource.Color.blue02
        label.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        let text = "링크연결하기"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue,
                                      range: (text as NSString).range(of: text))
        attributedString.addAttribute(.underlineColor, value: Resource.Color.blue02,
                                      range: (text as NSString).range(of: text))
        label.attributedText = attributedString
        label.isUserInteractionEnabled = true
        label.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(gotoLink)))
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
        backgroundColor = UIColor(named: "base")
        
        addSubview(detailContainerView)
        detailContainerView.addSubview(couponTitleLabel)
        detailContainerView.addSubview(copyLabel)
        detailContainerView.addSubview(couponDetailLabel)
        detailContainerView.addSubview(dateTitleLabel)
        detailContainerView.addSubview(dateDetailLabel)
        detailContainerView.addSubview(storeTitleLabel)
        detailContainerView.addSubview(linkLabel)
        detailContainerView.addSubview(storeDetailLabel)

        detailContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        couponTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        
        copyLabel.snp.makeConstraints { (make) in
            make.top.equalTo(couponTitleLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)

        }

        couponDetailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(couponTitleLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(copyLabel.snp.right)
            make.height.equalTo(20)
        }

        dateTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(couponDetailLabel.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }

        dateDetailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateTitleLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }

        storeTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(dateDetailLabel.snp.bottom).offset(22)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
        
        linkLabel.snp.makeConstraints { (make) in
            make.top.equalTo(storeTitleLabel.snp.bottom).offset(2)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }

        storeDetailLabel.snp.makeConstraints { (make) in
            make.top.equalTo(storeTitleLabel.snp.bottom).offset(2)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(linkLabel.snp.left)
            make.height.equalTo(20)
        }
    }
    
    @objc private func copyCoupon() {
        delegate?.copyCoupon(index: self.tag)
    }
    
    @objc private func gotoLink() {
        delegate?.gotoLink(index: self.tag)
    }
}
