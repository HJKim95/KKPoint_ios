//
//  MyEventController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

protocol MyEventCollectionViewCellToMyEventController: class {
    func gotoLink()
}

class MyEventViewController: UIViewController, MoreButtonFooterToInfoSubViewControllers,
                             MyEventCollectionViewCellToMyEventController {

    private let myEventCellID = String(describing: MyEventCollectionViewCell.self)
    private let myEventContentCellID = String(describing: MyEventContentCell.self)
    private let footerID = String(describing: MoreButtonFooterCell.self)

    private var footerSizeHeight: CGFloat = 0
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.text = "공지/이벤트"
        navBar.titleLabel.customFont(fontName: .NanumSquareRoundB, size: 16, letterSpacing: -0.3)
        navBar.titleLabel.textAlignment = .center
        return navBar
    }()

    private lazy var myEventCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "elavated")
        collectionview.showsVerticalScrollIndicator = false
        return collectionview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupLayouts()
        showMoreDatas()

        let cells = [MyEventCollectionViewCell.self, MyEventContentCell.self]
        cells.forEach { (cell) in
            myEventCollectionView.register(cell.self, forCellWithReuseIdentifier: String(describing: cell.self))
        }
        myEventCollectionView.register(MoreButtonFooterCell.self,
                                       forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter,
                                       withReuseIdentifier: footerID)
    }

    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "elavated")
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil

        view.addSubview(customNavigationBar)
        view.addSubview(myEventCollectionView)
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }

        myEventCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.equalToSuperview()
            make.right.bottom.equalToSuperview()
        }
    }
    
    var checkExpanded = [Bool]()

    var noticeEventDatas = [NoticeEventModel]()
    var pageNum: Int = -1

    func showMoreDatas() {
        NetworkManager.getNoticeEventData(page: pageNum+1) { [weak self] (result) in // 현재 paging은 20개씩
            switch result {
            case .success(let data):
                guard var addedData = data.data,
                      let totalPages = data.pagination?.totalPages,
                      let currentPage = data.pagination?.currentPage
                else {return}
                // displayFlag = 1 만 추가
                addedData = addedData.filter {$0.displayFlag == true}
                // TODO: endDate도 나중에 고려해보쟈..
                
                let defaultTestArray = Array(repeating: false, count: addedData.count)
                self?.checkExpanded.append(contentsOf: defaultTestArray)
                self?.noticeEventDatas.append(contentsOf: addedData)

                DispatchQueue.main.async {
                    self?.pageNum += 1
                    if totalPages == currentPage+1 || totalPages == 0 { // 페이지의 끝일 때
                        self?.footerSizeHeight = 0
                    } else {
                        self?.footerSizeHeight = 50
                    }
                    self?.myEventCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "공지사항 정보를 가져오는데 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
    }
    
    private func calculateTextSize(text: String) -> CGFloat {
        let desiredWith = view.frame.width - 40
        
        // EventDetailLabel 특성 반영
        let dummyLabel = UILabel()
        let attributedString = NSMutableAttributedString(string: text)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 10
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle,
                                      value: paragraphStyle,
                                      range: NSRange(location: 0, length: attributedString.length))
        dummyLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        dummyLabel.attributedText = attributedString
        dummyLabel.numberOfLines = 0

        let size: CGSize = dummyLabel.sizeThatFits(CGSize(width: desiredWith, height: .greatestFiniteMagnitude))
        let topBottomPadding: CGFloat = 16 + 46
        return size.height + topBottomPadding
    }
    
    func gotoLink() {
        // 임시
        AlertManager.showAlert(title: "준비중입니다.", message: nil, oKTItle: "확인", cancelTitle: nil) {
            print("PRESSED OK")
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    var pastIndex: Int = -1
}

extension MyEventViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return noticeEventDatas.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if !checkExpanded[indexPath.item] { // 기본 cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myEventCellID,
                                                             for: indexPath) as? MyEventCollectionViewCell {
                let date = noticeEventDatas[indexPath.item].startDate
                let title = noticeEventDatas[indexPath.item].title
    //            let contentUrl = noticeEventDatas[indexPath.item].contentUrl

                cell.eventDateLabel.text = date
                cell.eventDateLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
                cell.eventNameLabel.text = title
                cell.eventNameLabel.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3)
    //            cell.textLabel.text = contentUrl // TODO: linkLabel의 기능과 연결시켜야함.
                
                if checkExpanded.count >= indexPath.item+2 && checkExpanded[indexPath.item+1] {
                    cell.arrowImageView.image = UIImage(named: "btnArrowUp24White")
                } else {
                    cell.arrowImageView.image = UIImage(named: "btnArrowDown24White")
                }
                return cell
            }
            return UICollectionViewCell()
        } else { // Content cell
            if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: myEventContentCellID,
                                                             for: indexPath) as? MyEventContentCell {
                cell.delegate = self
                cell.eventDetailLabel.text = noticeEventDatas[indexPath.item].content ?? ""
                cell.eventDetailLabel.customFont(fontName: .NanumSquareRoundR,
                                                 size: 13, letterSpacing: -0.3, lineSpacing: 10)
                return cell
            }
            return UICollectionViewCell()
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let footer = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                        withReuseIdentifier: footerID,
                                                                        for: indexPath) as? MoreButtonFooterCell {
            footer.delegate = self
            
            return footer
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if checkExpanded[indexPath.item] { // content cell
            let content = noticeEventDatas[indexPath.item].content ?? ""
            return CGSize(width: collectionView.frame.width, height: calculateTextSize(text: content))
        } else { // 기본 cell
            return CGSize(width: collectionView.frame.width, height: 56)
        }
        
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: footerSizeHeight)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let newIndex = indexPath.item+1
        let newIndexPath = IndexPath(item: newIndex, section: 0)
        
        if checkExpanded.count >= newIndex+1 && checkExpanded[newIndex] { // 넓힌걸 줄이기
            self.checkExpanded.remove(at: newIndex)
            self.noticeEventDatas.remove(at: newIndex)
            self.myEventCollectionView.deleteItems(at: [newIndexPath])
        } else { // 줄여진걸 넗히기
            if !checkExpanded[indexPath.item] {
                let testData = noticeEventDatas[indexPath.item] // 자기와 같은 놈을 복제해서 content만 가져오기
                self.checkExpanded.insert(true, at: newIndex)
                self.noticeEventDatas.insert(testData, at: newIndex)
                self.myEventCollectionView.insertItems(at: [newIndexPath])
            }
        }
        if let cell = self.myEventCollectionView.cellForItem(at: indexPath) as? MyEventCollectionViewCell {
            cell.arrowImageView.image = nil
        }
        self.myEventCollectionView.reloadItems(at: [indexPath])
    }
}
