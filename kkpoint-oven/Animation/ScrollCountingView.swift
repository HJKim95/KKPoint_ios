//
//  ScrollCountingView.swift
//  AnimationTest
//
//  Created by 김희중 on 2021/03/30.
//

import UIKit
import SnapKit

class ScrollCountingView: UIView, UICollectionViewDelegate, UICollectionViewDataSource,
                          UICollectionViewDelegateFlowLayout {
    
    var countingNum: Int = 0 {
        didSet {
            DispatchQueue.main.async {
                self.scrollCountCollectionView.reloadData()
            }
        }
    }

    lazy var scrollCountCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.scrollDirection = .horizontal
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = false
        collectionView.alwaysBounceHorizontal = false
        collectionView.backgroundColor = .clear
        return collectionView
    }()
    
    let numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    func getFormattedNum(num: Int) -> String {
        return numberFormatter.string(from: NSNumber(value: num)) ?? ""
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        let cells = [CommaCell.self, ScrollCell.self]
        cells.forEach { (cell) in
            scrollCountCollectionView.register(cell.self, forCellWithReuseIdentifier: cell.description())
        }
        
        addSubview(scrollCountCollectionView)
        
        scrollCountCollectionView.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = String(getFormattedNum(num: countingNum)).count
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let arr = Array(String(getFormattedNum(num: countingNum)))
        if arr[indexPath.item] == "," {
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: CommaCell.description(),
                    for: indexPath) as? CommaCell else { return UICollectionViewCell()}
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ScrollCell.description(),
                    for: indexPath) as? ScrollCell else { return UICollectionViewCell()}
            let number = Int(String(arr[indexPath.item]))!
            cell.tag = indexPath.item
            cell.totalCount = String(getFormattedNum(num: countingNum)).count
            cell.num = number
            cell.countScrollLabel.configure(with: number)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let arr = Array(String(getFormattedNum(num: countingNum)))
        if arr[indexPath.item] == "," {
            return CGSize(width: 4, height: 20)
        } else {
            return CGSize(width: 10, height: 20)
        }
    }
}

class ScrollCell: UICollectionViewCell {
    var totalCount: Int = 0
    
    var num: Int = 0 {
        didSet {
            let time: Double = Double(totalCount - self.tag) * 0.2
            DispatchQueue.main.asyncAfter(deadline: .now() + time) {
                self.countScrollLabel.configure(with: self.num)
                self.countScrollLabel.animate()
            }
            
        }
    }
    
    let countScrollLabel: CountScrollLabel = {
        let scrollLabel = CountScrollLabel()
        scrollLabel.textColor = UIColor(named: "primary02")
        scrollLabel.customFont(fontName: .NanumSquareRoundEB, size: 18)
        return scrollLabel
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayouts() {
        addSubview(countScrollLabel)
        countScrollLabel.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}

class CommaCell: UICollectionViewCell {
    let commaLabel: UILabel = {
        let label = UILabel()
        label.text = ","
        label.textColor = UIColor(named: "primary02")
        label.customFont(fontName: .NanumSquareRoundEB, size: 18)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLayouts() {
        addSubview(commaLabel)
        commaLabel.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalToSuperview()
        }
    }
}
