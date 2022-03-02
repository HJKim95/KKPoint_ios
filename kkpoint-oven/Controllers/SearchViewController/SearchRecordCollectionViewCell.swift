//
//  SearchPastKeywordCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class SearchRecordCollectionViewCell: UICollectionViewCell {

    private let timeImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "iconHistoryB24")
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()

    let searchLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.textColor = UIColor(named: "primary02")
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
        backgroundColor = UIColor(named: "elavated")

        contentView.addSubview(timeImageView)
        contentView.addSubview(searchLabel)

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(UIScreen.main.bounds.width)
        }
        
        timeImageView.snp.makeConstraints {
            $0.top.left.equalToSuperview().offset(16)
            $0.bottom.equalToSuperview().offset(-16)
            $0.width.height.equalTo(24)
        }

        searchLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(18)
            $0.left.equalTo(timeImageView.snp.right).offset(8)
            $0.right.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-18)
        }
    }
}
