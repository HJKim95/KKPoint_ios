//
//  ChannelCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/04.
//

import UIKit

class ChannelCollectionViewCell: UICollectionViewCell {
    
    private let profile: UIImageView = UIImageView().then {
        $0.layer.cornerRadius = 19
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = Resource.Color.grey03.cgColor
    }
    private let nameLabel: UILabel = UILabel().then {
        $0.textColor = UIColor(named: "primary02")
    }
    private let infoLabel: UILabel = UILabel().then {
        $0.textColor = UIColor(named: "secondary01")
    }
    lazy var subscribeButton: UIButton = UIButton(type: .system)
    
    private let subscribeLabel: UILabel = UILabel().then {
        $0.textColor = UIColor(named: "secondary01")
    }

    func cancelSubecribeUItask() {
        subscribeLabel.text = "구독하기"
        subscribeLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        subscribeLabel.textAlignment = .right
        let image = UIImage(named: "iconSubscribeN32")?.withRenderingMode(.alwaysOriginal)
        subscribeButton.setImage(image, for: .normal)
    }
    func addSubscribeUItask() {
        subscribeLabel.text = "구독 중"
        let image = UIImage(named: "iconSubscribeS32")?.withRenderingMode(.alwaysOriginal)
        subscribeButton.setImage(image, for: .normal)
        subscribeLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.3)
        subscribeLabel.textAlignment = .right
    }
    
    func mappingData(channel: Channel, subscribed: Bool) {
        profile.image = UIImage(named: "borami")
        nameLabel.text = channel.cname
        nameLabel.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
        nameLabel.numberOfLines = 1
        nameLabel.lineBreakMode = .byTruncatingTail
        
        infoLabel.text =
            "구독자 \(Formatter.Number.getFormattedNum(num: channel.subscribeCnt))명 · " +
            "동영상 \(Formatter.Number.getFormattedNum(num: channel.videoCnt))개"
        infoLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        guard let url = URL(string: channel.profileUrl ?? "") else { return }
        profile.kf.setImage(with: url)
        
        if subscribed {
            subscribeLabel.text = "구독 중"
            let image = UIImage(named: "iconSubscribeS32")?.withRenderingMode(.alwaysOriginal)
            subscribeButton.setImage(image, for: .normal)
        } else {
            subscribeLabel.text = "구독하기"
            let image = UIImage(named: "iconSubscribeN32")?.withRenderingMode(.alwaysOriginal)
            subscribeButton.setImage(image, for: .normal)
        }
        subscribeLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        subscribeLabel.textAlignment = .right
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    private func setupLayout() {
        backgroundColor = UIColor(named: "elavated")
        contentView.addSubview(profile)
        contentView.addSubview(nameLabel)
        contentView.addSubview(infoLabel)
        contentView.addSubview(subscribeButton)
        contentView.addSubview(subscribeLabel)

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        profile.snp.makeConstraints {
            $0.width.height.equalTo(38)
            $0.top.equalToSuperview().offset(18)
            $0.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        subscribeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-12)
            $0.size.equalTo(32)
            $0.bottom.equalToSuperview().offset(-24)
        }

        subscribeLabel.snp.makeConstraints {
            $0.centerY.equalTo(subscribeButton)
            $0.height.equalTo(16)
            $0.right.equalTo(subscribeButton.snp.left).offset(-6)
            $0.width.equalTo(60)
        }
        
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(15)
            $0.left.equalTo(profile.snp.right).offset(12)
            $0.right.equalTo(subscribeLabel.snp.left)
            $0.height.equalTo(20)
        }
        
        infoLabel.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(2)
            $0.left.equalTo(profile.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().offset(-15)
        }
    }
}
