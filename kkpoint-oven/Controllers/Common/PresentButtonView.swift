//
//  PresentButtonView.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/17.
//

import UIKit
import SnapKit

class PresentButtonView: UIView {

    let presentLabel: UILabel = {
        let label = UILabel()
        label.text = "출석체크"
        label.customFont(fontName: .NanumSquareRoundB, size: 13, letterSpacing: -0.5)
        label.textColor = Resource.Color.white00
        label.textAlignment = .right
        label.sizeToFit()
        return label
    }()

    let presentImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "imgDailyCheck")
        imageview.backgroundColor = .clear
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
        setupProperty()
        backgroundColor = Resource.Color.orange06
        addSubview(presentImageView)
        addSubview(presentLabel)
        
        presentImageView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-12)
            make.size.equalTo(20)
        }
        
        presentLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(12)
            make.right.equalTo(presentImageView.snp.left).offset(-7)
        }

    }

    private func setupProperty() {
        self.layer.masksToBounds = true
        self.backgroundColor = Resource.Color.orange06
        self.layer.cornerRadius = 18
        self.isUserInteractionEnabled = true
    }
}
