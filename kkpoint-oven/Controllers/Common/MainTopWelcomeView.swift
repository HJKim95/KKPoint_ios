//
//  MainTopWelcomeView.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/10.
//

import UIKit
import SnapKit

class MainTopWelcomeView: UIView {
    
    private let presentButtonWidth: CGFloat = 96 // 출석체크 버튼 width
    
    let helloLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        label.alpha = 0
        return label
    }()
    
    let pImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "icPoint02")
        imageview.backgroundColor = .clear
        imageview.alpha = 0
        return imageview
    }()
    
    let pointLabel: UILabel = {
        let label = UILabel()
        label.text = "0"
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        label.alpha = 0
        return label
    }()
    
//    lazy var scrollCountView: ScrollCountingView = {
//        let view = ScrollCountingView()
////        view.countingNum = 147852369
//        view.alpha = 0
//        return view
//    }()
    
    let recommendLabel: UILabel = {
        let label = UILabel()
        label.text = "출석체크 하고\n포인트 받으세요!"
        label.customFont(fontName: .NanumSquareRoundR, size: 17, letterSpacing: -1, lineSpacing: 5)
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
        return label
    }()

    lazy var presentButtonView: PresentButtonView = {
        let view = PresentButtonView()
        view.backgroundColor = Resource.Color.grey03
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
        backgroundColor = UIColor(named: "base")
        addSubview(helloLabel)
        addSubview(pImageView)
        addSubview(pointLabel)
//        addSubview(scrollCountView)
        addSubview(recommendLabel)
        addSubview(presentButtonView)

        presentButtonView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.height.equalTo(36)
            make.right.equalToSuperview().offset(-20)
        }

        helloLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(13)
            make.height.equalTo(20)
        }
        
        pImageView.snp.makeConstraints { (make) in
            make.top.equalTo(helloLabel.snp.bottom).offset(5)
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(22)
        }
        
        pointLabel.snp.makeConstraints { (make) in
            make.top.equalTo(helloLabel.snp.bottom).offset(6)
            make.left.equalTo(pImageView.snp.right).offset(4)
            make.height.equalTo(22)
        }
        
//        scrollCountView.snp.makeConstraints { (make) in
//            make.top.left.right.bottom.equalTo(pointLabel)
//        }
        
        recommendLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-10)
        }
    }
}
