//
//  MyInfoVersionCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class MyInfoVersionCell: UICollectionViewCell {
    
    weak var delegate: MyInfoVersionCellToMyInfoViewController?

    private let myInfoCategoryImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.backgroundColor = .clear
        imageview.contentMode = .scaleAspectFit
        imageview.image = UIImage(named: "icnMyVersion")
        return imageview
    }()

    private let myInfoCategoryLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        label.text = "버전정보"
        label.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        return label
    }()

    let myInfoVersionLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "primary02")
        return label
    }()
    
    private lazy var needUpdateVersionButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("최신버전 업데이트하기", for: .normal)
        button.setTitleColor(Resource.Color.orange06, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = Resource.Color.orange06.cgColor
        button.addTarget(self, action: #selector(goUpdate), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("로그인 하세요.", for: .normal)
        button.setTitleColor(Resource.Color.white00, for: .normal)
        button.backgroundColor = Resource.Color.orange06
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = Resource.Color.orange06.cgColor
        button.addTarget(self, action: #selector(showLogin), for: .touchUpInside)
        return button
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
        addSubview(myInfoCategoryLabel)
        addSubview(myInfoVersionLabel)
        
        myInfoCategoryImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.left.equalToSuperview()
            make.height.equalTo(24)
            make.width.equalTo(myInfoCategoryImageView.snp.height)
        }

        myInfoCategoryLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(23)
            make.left.equalTo(myInfoCategoryImageView.snp.right).offset(10)
            make.height.equalTo(17)
            make.width.equalTo(80)
        }
        
        myInfoVersionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(23)
            make.right.equalToSuperview()
            make.left.equalTo(myInfoCategoryLabel.snp.right)
            make.height.equalTo(20)
        }
    }
    
    var isRecentVersion: Bool?
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        guard let noNeedUpdate = isRecentVersion else { return }
        if !AccountManager.shared.isLogged {
            if noNeedUpdate { // 최신버전 & 비로그인
                addSubview(loginButton)
                loginButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(myInfoCategoryLabel.snp.bottom).offset(24)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(50)
                }
                needUpdateVersionButton.removeFromSuperview()
            } else { // 구버전 & 비로그인
                addSubview(needUpdateVersionButton)
                needUpdateVersionButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(myInfoCategoryLabel.snp.bottom).offset(24)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(50)
                }
                addSubview(loginButton)
                loginButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(needUpdateVersionButton.snp.bottom).offset(10)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(50)
                }
            }
        } else {
            if noNeedUpdate { // 최신버전 & 로그인
                // 둘다 생성하지 않기.
                loginButton.removeFromSuperview()
                needUpdateVersionButton.removeFromSuperview()
            } else { // 구버전 & 로그인
                addSubview(needUpdateVersionButton)
                needUpdateVersionButton.snp.remakeConstraints { (make) in
                    make.top.equalTo(myInfoCategoryLabel.snp.bottom).offset(24)
                    make.left.right.equalToSuperview()
                    make.height.equalTo(50)
                }
                loginButton.removeFromSuperview()
            }
        }
    }
    
    @objc private func goUpdate() {
        delegate?.goUpdate()
    }
    
    @objc private func showLogin() {
        delegate?.showLoginVC()
    }
}
