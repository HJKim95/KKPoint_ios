//
//  CustomTabbar.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/08.
//
import UIKit
import SnapKit

protocol CustomTabbarDelegate: class {
    func scrollToTabIndex(index: Int, animated: Bool)
}

class CustomTabbar: UIView, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    private let pageGroups = ["약관", "개인정보 처리방침"]
    weak var delegate: CustomTabbarDelegate?

    lazy var tabbarCollectionView: UICollectionView = UICollectionView(
        frame: .zero,
        collectionViewLayout: UICollectionViewFlowLayout().then {
            $0.minimumInteritemSpacing = 0
        }
    ).then {
        $0.dataSource = self
        $0.delegate = self
        $0.backgroundColor = UIColor(named: "elavated")
    }

    let horizontalBarView: UIView = UIView().then {
        $0.backgroundColor = Resource.Color.orange06
    }

    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)

        tabbarCollectionView.register(CustomTabbarCell.self,
                                      forCellWithReuseIdentifier: CustomTabbarCell.description())
        
        tabbarCollectionView.selectItem(at: IndexPath(row: 0, section: 0), animated: true, scrollPosition: [])
        setupLayouts()
    }
    
    private func setupLayouts() {
        addSubview(tabbarCollectionView)
        addSubview(horizontalBarView)

        tabbarCollectionView.snp.makeConstraints {
            $0.top.bottom.left.right.equalToSuperview()
        }

        horizontalBarView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
            make.height.equalTo(2)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        delegate?.scrollToTabIndex(index: indexPath.item, animated: true)
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pageGroups.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomTabbarCell.description(),
                                                         for: indexPath) as? CustomTabbarCell {
            cell.label.text = pageGroups[indexPath.item]
            if indexPath.item == 0 {
                cell.label.customFont(fontName: .NanumSquareRoundB, size: 15, letterSpacing: -0.3)
            } else {
                cell.label.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3)
            }
            cell.label.textAlignment = .center
            return cell
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: frame.width / CGFloat(pageGroups.count), height: frame.height)
    }
}
