//
//  DetailYoutubeHeader.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/24.
//

import UIKit
import SnapKit

class DetailYoutubeHeader: UICollectionViewCell {
    
    let videoTitle = UILabel().then {
        $0.textColor = UIColor(named: "primary02")
    }
    
    let viewersAndDate = UILabel().then { $0.textColor = UIColor(named: "secondary01")
    }
    
    let videoInfoContainer = UIView().then { $0.backgroundColor = UIColor(named: "elavated") }
    
    private let profileContainer = UIView().then { $0.backgroundColor = UIColor(named: "elavated") }
    
    let personerImage = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 19
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = Resource.Color.grey03.cgColor
        $0.isUserInteractionEnabled = true
        $0.backgroundColor = .gray
    }
    let nameLabel = UILabel().then {
        $0.textColor = UIColor(named: "primary02")
        $0.isUserInteractionEnabled = true
        $0.textAlignment = .left
    }
    
    let subscribeLabel = UILabel().then {
        $0.text = "구독 하기"
        $0.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.3)
        $0.textColor = UIColor(named: "secondary01")
        $0.textAlignment = .right
    }
    
    private lazy var subscribeButton = UIButton(type: .custom).then {
        $0.addTarget(self, action: #selector(tapSubscribe), for: .touchUpInside)
        $0.setImage(UIImage(named: "iconSubscribeN32"), for: .normal)
    }

    private let separator = UIView().then {
        $0.backgroundColor = UIColor(named: "dividerColor")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        addSubview(videoInfoContainer)
        videoInfoContainer.addSubview(viewersAndDate)
        videoInfoContainer.addSubview(videoTitle)
        addSubview(profileContainer)
        profileContainer.addSubview(personerImage)
        profileContainer.addSubview(nameLabel)
        profileContainer.addSubview(subscribeLabel)
        profileContainer.addSubview(subscribeButton)
        addSubview(separator)

        videoInfoContainer.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(72)
        }
        
        videoTitle.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
        }
        viewersAndDate.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(videoTitle.snp.bottom).offset(5)
            $0.bottom.equalToSuperview().offset(-12)
        }
        
        profileContainer.snp.makeConstraints {
            $0.top.equalTo(videoInfoContainer.snp.bottom)
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-12)
            $0.height.equalTo(56)
        }
        personerImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview()
            $0.size.equalTo(38)
        }
        
        subscribeButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().offset(-12)
            $0.size.equalTo(32)
        }
        
        subscribeLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview().offset(1)
            $0.trailing.equalTo(subscribeButton.snp.leading).offset(-6)
            $0.height.equalTo(16)
            $0.width.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(personerImage.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(20)
            $0.trailing.equalTo(subscribeLabel.snp.leading)
        }

        separator.snp.makeConstraints {
            $0.top.equalTo(profileContainer.snp.bottom).offset(4)
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(1)
        }
    }
    
    var isSubscribed: Bool = false {
        didSet {
            if isSubscribed {
                self.subscribeLabel.text = "구독 중"
                self.subscribeLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.3)
                self.subscribeLabel.textAlignment = .right
                self.subscribeButton.setImage(UIImage(named: "iconSubscribeS32"), for: .normal)
            } else {
                self.subscribeLabel.text = "구독 하기"
                self.subscribeLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.3)
                self.subscribeLabel.textAlignment = .right
                self.subscribeButton.setImage(UIImage(named: "iconSubscribeN32"), for: .normal)
            }
        }
    }
    
    var cid: String = ""
    
    @objc func tapSubscribe() {
        if !AccountManager.shared.isLogged {
            let loginVC = LoginViewController()
            if #available(iOS 13.0, *) {
                loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
                Utilities.topViewController()?.present(loginVC, animated: true)
            } else {
                Utilities.topViewController()?.present(loginVC, animated: true)
            }
            return
        }
        
        if isSubscribed {
            SubscribeManager.cancel(cid: cid) { [weak self] in
                self?.subscribeLabel.text = "구독 하기"
                self?.subscribeLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.3)
                self?.subscribeLabel.textAlignment = .right
                self?.subscribeButton.setImage(UIImage(named: "iconSubscribeN32"), for: .normal)
                self?.isSubscribed = false
            }
        } else {
            SubscribeManager.apply(cid: cid) { [weak self] in
                self?.subscribeLabel.text = "구독 중"
                self?.subscribeLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.3)
                self?.subscribeLabel.textAlignment = .right
                self?.subscribeButton.setImage(UIImage(named: "iconSubscribeS32"), for: .normal)
                self?.isSubscribed = true
            }
        }
    }
}
