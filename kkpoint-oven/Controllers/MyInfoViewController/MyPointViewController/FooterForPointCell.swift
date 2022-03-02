//
//  FooterForPointCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/24.
//

import UIKit
import SnapKit

protocol FooterForPointCellToMyPointViewControllers: class {
    func showMoreDatas()
    func showRV()
}

class FooterForPointCell: UICollectionViewCell {

    weak var delegate: FooterForPointCellToMyPointViewControllers?
    
    private lazy var moreButtonView: UIView = {
        let view = UIView()
        view.layer.borderWidth = 1
        view.layer.borderColor = Resource.Color.grey03.cgColor
        view.layer.cornerRadius = 22
        view.layer.masksToBounds = true
        view.isUserInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickShowMore)))
        view.alpha = 0
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
    
    private let rvBackView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor(named: "yellowBrown")
        return view
    }()
    
    private let rvLabel: UILabel = {
        let label = UILabel()
        label.text = "비디오 시청하면\n킥킥포인트를 드려요!"
        label.customFont(fontName: .NanumSquareRoundB, size: 15, letterSpacing: -0.28)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        return label
    }()
    
    private lazy var presentButtonView: PresentButtonView = {
        let view = PresentButtonView()
        view.presentLabel.text = "RV시청"
        view.presentLabel.customFont(fontName: .NanumSquareRoundB, size: 13, letterSpacing: -0.5)
        view.presentImageView.image = UIImage(named: "imgDailyRv")
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRV)))
        view.layer.cornerRadius = 18
        return view
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupLayouts() {
        addSubview(rvBackView)
        rvBackView.addSubview(rvLabel)
        rvBackView.addSubview(presentButtonView)
        
        if self.frame.height > 70 {
            moreButtonView.alpha = 1
        }
        
        addSubview(moreButtonView)
        moreButtonView.addSubview(moreLabel)
        moreButtonView.addSubview(moreImageView)
        
        rvBackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(69)
        }
        
        presentButtonView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-14)
            make.height.equalTo(36)
        }
        
        rvLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(6)
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-6)
            make.right.equalTo(presentButtonView.snp.left)
        }
        
        moreButtonView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.width.equalTo(98)
            make.height.equalTo(44)
            make.centerX.equalToSuperview()
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
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        // Footer 사이즈 변경시 call
        if self.frame.height > 90 {
            moreButtonView.alpha = 1
        } else {
            moreButtonView.alpha = 0
        }
    }

    @objc private func clickShowMore() {
        delegate?.showMoreDatas()
    }
    
    @objc private func showRV() {
        delegate?.showRV()
    }
}
