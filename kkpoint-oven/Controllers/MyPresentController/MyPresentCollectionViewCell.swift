//
//  MyPresentCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/18.
//

import UIKit
import SnapKit

class MyPresentCollectionViewCell: UICollectionViewCell {
    
    var presentMonth: Date?
    var presentBoolData: [Bool]?
    
    var presentDates: [String]? {
        didSet {
            let count = calculateMonthDates(date: self.presentMonth ?? Date())
            var dateArray = Array(repeating: false, count: count)
            let wholeDateFormatter = Formatter.Date.dateFormatterGetWholeDate
            let dateFormatter = Formatter.Date.dateFormatterGetDate
            // 출석한 날짜는 true 나머지는 false 처리
            for date in presentDates! {
                if let convertedDate = wholeDateFormatter.date(from: date) {
                    let dateToIndex = Int(dateFormatter.string(from: convertedDate))!-1
                    dateArray[dateToIndex] = true
                }
            }
            self.presentBoolData = dateArray
        }
    }

    private let presentDateCellID = String(describing: MyPresentDateCell.self)
    
    lazy var presentDateCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 17
        layout.minimumInteritemSpacing = 10
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = .clear
        collectionview.showsVerticalScrollIndicator = false
        collectionview.alwaysBounceVertical = true
        collectionview.contentInset = UIEdgeInsets(top: 28, left: 0, bottom: 0, right: 0)
        return collectionview
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
        
        presentDateCollectionView.register(MyPresentDateCell.self, forCellWithReuseIdentifier: presentDateCellID)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        addSubview(presentDateCollectionView)

        presentDateCollectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview()
        }
    }
    
    private func calculateMonthDates(date: Date) -> Int {
        let calendar = Formatter.Date.calendar
        var comps2 = DateComponents()
        comps2.month = 1
        comps2.day = -1
        guard let endOfMonth = calendar.date(byAdding: comps2, to: date) else { return  0}
        let dateFormatter = Formatter.Date.dateFormatterGetDate
        let lastDate = dateFormatter.string(from: endOfMonth)
        return Int(lastDate)!
    }
    
}

extension MyPresentCollectionViewCell: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = calculateMonthDates(date: self.presentMonth ?? Date())
        return count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: presentDateCellID,
                                                         for: indexPath) as? MyPresentDateCell {
            let formatMonth = Formatter.Date.dateFormatterGetMonth
            let formatYear = Formatter.Date.dateFormatterGetYear
            let dateFormatter = Formatter.Date.dateFormatterGetDate
            
            let month = formatMonth.string(from: presentMonth ?? Date())
            let year = formatYear.string(from: presentMonth ?? Date())

            let todayYearString = formatYear.string(from: Date())
            let todayMonthString = formatMonth.string(from: Date())
            let todayDate = Int(dateFormatter.string(from: Date()))!

            if todayYearString == year && todayMonthString == month && indexPath.item+1 == todayDate {
                // 오늘인 경우
                cell.presentDateLabel.textColor = Resource.Color.orange06
                cell.presentDateLabel.text = "Today"
                cell.presentDateLabel.customFont(fontName: .NanumSquareRoundEB, size: 12, letterSpacing: -0.3)
                if let checkToday = presentBoolData?[indexPath.item] {
                    if checkToday {
                        cell.presentImageView.image = UIImage(named: "imgDailycheckTodayChecked")
                    } else {
                        cell.presentImageView.image = UIImage(named: "imgDailycheckToday")
                    }
                }
            } else { // 오늘이 아닌경우(이번달 저번달 등등..)
                cell.presentDateLabel.text = "\(month).\(indexPath.item+1)"
                cell.presentDateLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.51)
                if let checkDate = presentBoolData?[indexPath.item] {
                    if checkDate { // 출석한 경우
                        cell.presentImageView.image = UIImage(named: "imgDailycheckChecked")
                        cell.presentDateLabel.textColor = UIColor(named: "secondary01")
                    } else { // 이번달을 제외한 달에 출석을 못한 경우
                        if todayMonthString != month || (todayYearString != year && todayMonthString == month) {
                            cell.presentImageView.image = UIImage(named: "imgDailycheckMiss")
                            cell.presentDateLabel.textColor = UIColor(named: "disable")
                        } else { // 이번달 중에 과거에 출석을 못한 경우
                            if indexPath.item+1 < todayDate {
                                cell.presentImageView.image = UIImage(named: "imgDailycheckMiss")
                                cell.presentDateLabel.textColor = UIColor(named: "disable")
                            } else if indexPath.item+1 > todayDate {
                                cell.presentImageView.image = UIImage(named: "imgDailycheckNormal")
                                cell.presentDateLabel.textColor = UIColor(named: "secondary01")
                            }
                        }

                    }
                }
            }
            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let totalLineSpacing: CGFloat = 4 * 17
        let totalCellWidths: CGFloat = collectionView.frame.width - totalLineSpacing
        return CGSize(width: totalCellWidths/5, height: totalCellWidths/5 + 24)
    }
}
