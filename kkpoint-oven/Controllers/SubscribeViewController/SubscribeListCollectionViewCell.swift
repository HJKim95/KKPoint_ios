//
//  subscribeListTableViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/28.
//

import UIKit
import SnapKit

class SubscribeListCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: SubscribeListCollectionViewCellToSubscribeListViewController?

    let subscribeProfileImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.backgroundColor = UIColor(named: "elavated")
        imageview.layer.cornerRadius = 19
        imageview.layer.masksToBounds = true
        imageview.layer.borderWidth = 0.3
        imageview.layer.borderColor = Resource.Color.grey03.cgColor
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    private lazy var removeSubscribeImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "iconClose32")
        imageview.contentMode = .scaleAspectFit
        imageview.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(clickRemoveImage)))
        imageview.isUserInteractionEnabled = true
        return imageview
    }()

    let subscribeNameLabel: UILabel = {
        let label = UILabel()
        label.text = "헤이지니"
        label.customFont(fontName: .NanumSquareRoundB, size: 13, letterSpacing: -0.5)
        label.textColor = UIColor(named: "primary02")
        label.textAlignment = .left
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        layoutSubviews()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = UIColor(named: "elavated")
        addSubview(subscribeProfileImageView)
        addSubview(removeSubscribeImageView)
        addSubview(subscribeNameLabel)
        
        subscribeProfileImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(9)
            make.bottom.equalToSuperview().offset(-9)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(subscribeProfileImageView.snp.height)
        }

        removeSubscribeImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.right.bottom.equalToSuperview().offset(-12)
            make.width.equalTo(removeSubscribeImageView.snp.height)
        }

        subscribeNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(19)
            make.bottom.equalToSuperview().offset(-19)
            make.left.equalTo(subscribeProfileImageView.snp.right).offset(12)
            make.right.equalTo(removeSubscribeImageView.snp.left)
        }
    }

    @objc private func clickRemoveImage() {
        let popupColor = UIColor(named: "elavated")!
        let unableColor = UIColor.black.withAlphaComponent(0.7)
        let cname: String = subscribeNameLabel.text ?? "채널"
        let mainStr = "\(cname)의 구독을 해지할까요?"
        PopupManager.shared.showPopup(mainStr: mainStr,
                                      subStr: nil,
                                      imageName: "imgPopupKksad",
                                      positiveButtonOption: ButtonOption(title: "구독 해지하기", handler: {
                                        self.delegate?.cancelSubscribe(index: self.tag)
                                      }),
                                      negativeButtonOption: ButtonOption(title: "유지하기", handler: {
                                        //
                                      }),
                                      backgroundColor: BackgroundColorOption(
                                        popupViewColor: popupColor, unableViewColor: unableColor),
                                      enableBackgroundTouchOut: true)
    }

}
