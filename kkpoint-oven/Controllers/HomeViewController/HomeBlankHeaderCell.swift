//
//  HomeBlankHeaderCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/02.
//

import UIKit

class HomeBlankHeaderCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    fileprivate func setupLayouts() {
        backgroundColor = .clear
    }
}
