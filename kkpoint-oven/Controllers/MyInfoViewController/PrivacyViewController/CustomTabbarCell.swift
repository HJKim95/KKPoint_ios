//
//  CustomTabbarCell.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/08.
//

import UIKit

class CustomTabbarCell: UICollectionViewCell {

    let label: UILabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = UIColor(named: "secondary02")
    }
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                label.textColor = Resource.Color.orange06
                label.customFont(fontName: .NanumSquareRoundB, size: 15, letterSpacing: -0.3)
                label.textAlignment = .center
            } else {
                label.textColor = UIColor(named: "secondary02")
                label.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
                label.textAlignment = .center
            }
        }
    }

    override var isSelected: Bool {
        didSet {
            if isSelected {
                label.textColor = Resource.Color.orange06
                label.customFont(fontName: .NanumSquareRoundB, size: 15, letterSpacing: -0.3)
                label.textAlignment = .center
            } else {
                label.textColor = UIColor(named: "secondary02")
                label.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
                label.textAlignment = .center
            }
        }
    }

    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }

    private func setupLayout() {
        backgroundColor = .clear
        addSubview(label)

        label.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }

    }
}
