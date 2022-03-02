//
//  TutorialCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/19.
//

import UIKit
import SnapKit

class TutorialCollectionViewCell: UICollectionViewCell {

    let tutorialImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.contentMode = .scaleAspectFill
        imageview.layer.masksToBounds = true
        return imageview
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate func setupLayouts() {
        addSubview(tutorialImageView)

        tutorialImageView.snp.makeConstraints { (make) in
            make.top.bottom.left.right.equalToSuperview()
        }
    }
}
