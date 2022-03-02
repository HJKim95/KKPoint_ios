//
//  CouponHeaderCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/08.
//

import UIKit
import SnapKit

class CouponHeaderCell: UICollectionViewCell {
    
    var myPointData: KKPointModel<AccountPointDataModel>? {
        didSet {
            guard let totalPoints = myPointData?.data?.totalPoints,
                  let formattedPoint = Formatter.Number.numberFormatter.string(from: NSNumber(value: totalPoints))
            else { return }
            pointAmountLabel.text = "\(formattedPoint)"
            pointAmountLabel.customFont(fontName: .NanumSquareRoundEB, size: 18, letterSpacing: -1)
        }
    }
    
    lazy var logoutPointLabel: UILabel = UILabel().then {
        $0.text = "출석체크 하고\n포인트 받으세요!"
        $0.customFont(fontName: .NanumSquareRoundR, size: 18, letterSpacing: -1)
        $0.numberOfLines = 0
        $0.textAlignment = .left
        $0.textColor = UIColor(named: "primary02")
    }
    
    lazy var loginContainer: UIView = UIView()
    private let myPointLabel: UILabel = UILabel().then {
        $0.text = "내 포인트"
        $0.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "secondary01")
    }
    private let pImage: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "icPoint02")
        $0.contentMode = .scaleAspectFit
    }
    private let pointAmountLabel: UILabel = UILabel().then {
        $0.customFont(fontName: .NanumSquareRoundEB, size: 18, letterSpacing: -1)
        $0.text = "0"
        $0.textColor = UIColor(named: "primary02")
    }
    
    private let logoImage: UIImageView = UIImageView().then {
        $0.image = UIImage(named: "imgMypagePoint")
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setPoint),
                                               name: Notification.Point.getPoint,
                                               object: nil)
        checkLogin()
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        addSubview(loginContainer)
        loginContainer.addSubview(logoutPointLabel)
        logoutPointLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(10)
            $0.leading.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-10)
        }
        loginContainer.addSubview(myPointLabel)
        loginContainer.addSubview(pImage)
        loginContainer.addSubview(pointAmountLabel)
        loginContainer.addSubview(logoImage)
        loginContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(72)
        }
        myPointLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(13)
            $0.leading.equalToSuperview().offset(20)
            $0.height.equalTo(20)
        }
        pImage.snp.makeConstraints {
            $0.width.height.equalTo(22)
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalTo(myPointLabel.snp.bottom).offset(5)
        }
        pointAmountLabel.snp.makeConstraints {
            $0.leading.equalTo(pImage.snp.trailing).offset(4)
            $0.top.equalTo(myPointLabel.snp.bottom).offset(6)
            $0.height.equalTo(22)
        }
        logoImage.snp.makeConstraints {
            $0.trailing.bottom.equalToSuperview()
            $0.width.equalTo(132)
            $0.height.equalTo(64)
        }
    }
    
    @objc func setPoint() {
        myPointData = AccountManager.shared.pointData
    }
    
    func checkLogin() {
        let loginViews: [UIView] = [myPointLabel, pImage, pointAmountLabel]
        if AccountManager.shared.isLogged {
            myPointData = AccountManager.shared.pointData
            loginViews.forEach { $0.alpha = 1 }
            logoutPointLabel.alpha = 0
        } else {
            myPointData = AccountManager.shared.pointData
            loginViews.forEach { $0.alpha = 0 }
            logoutPointLabel.alpha = 1
        }
    }
}
