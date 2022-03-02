//
//  MyEventContentCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/10.
//

import UIKit
import SnapKit

class MyEventContentCell: UICollectionViewCell {
    
    weak var delegate: MyEventCollectionViewCellToMyEventController?
    
    let detailContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "base")
        return view
    }()
    
    let eventDetailLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor(named: "secondary01")
        label.sizeToFit()
        return label
    }()
    
    lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = Resource.Color.blue02
        let text = "링크연결하기"
        let attributedString = NSMutableAttributedString(string: text)
        attributedString.addAttribute(.underlineStyle, value: NSUnderlineStyle.thick.rawValue,
                                      range: (text as NSString).range(of: text))
        attributedString.addAttribute(.underlineColor, value: Resource.Color.blue02,
                                      range: (text as NSString).range(of: text))
        if let font = UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 13) {
            attributedString.addAttributes([NSAttributedString.Key.kern: -0.3,
                                           NSAttributedString.Key.font: font],
                                           range: (text as NSString).range(of: text))
            label.attributedText = attributedString
        }
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
        detailContainerView.addSubview(eventDetailLabel)
        detailContainerView.addSubview(linkLabel)

        detailContainerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview()
        }

        eventDetailLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            // 자동 사이징 적용
        }
        
        linkLabel.snp.makeConstraints { (make) in
            make.top.equalTo(eventDetailLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(20)
        }
    }
    
    @objc private func gotoLink() {
        delegate?.gotoLink()
    }
}
