//
//  IntroViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/09/01.
//

import UIKit

class IntroViewController: UIViewController {
    
    let titleArray = ["장난감 리뷰만 보세요", "바로 구매할 수 있어요", "포인트로 할인받으세요"]
    let descArray = ["불필요한 영상광고 없이\n유튜버들의 장난감 리뷰를 보여주세요",
                     "리뷰에서 설명하는 장난감을\n바로 구매할 수 있어요", "출석과 충전소에서 쌓은 포인트로\n장난감을 할인해서 구매하세요"]
    let imageArray = ["iosAppScreenshot01", "iosAppScreenshot02", "iosAppScreenshot03"]
    
    lazy var introCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = Resource.Color.bgYellow02
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsHorizontalScrollIndicator = false
        return collectionView
    }()
    
    var pageControl: UIPageControl = {
        let pagecontrol = UIPageControl()
        pagecontrol.pageIndicatorTintColor = Resource.Color.grey03
        pagecontrol.currentPageIndicatorTintColor = Resource.Color.orange06
        pagecontrol.isUserInteractionEnabled = false
        return pagecontrol
    }()
    
    lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "iconBackRightB24")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(clickNext), for: .touchUpInside)
        button.isUserInteractionEnabled = true
        return button
    }()
    
    lazy var startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("시작하기", for: .normal)
        button.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 16, letterSpacing: -1)
        button.setTitleColor(Resource.Color.white00, for: .normal)
        button.backgroundColor = Resource.Color.orange06
        button.layer.cornerRadius = 25
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(start), for: .touchUpInside)
        button.alpha = 0
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Resource.Color.bgYellow02
        
        view.addSubview(introCollectionView)
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(startButton)
        
        if view.frame.height < 800 { // iphone X 보다 크기가 작은 경우 (7+ 모델들도 포함)
            // 41+44+6 = 91
            let height = 91 + (view.frame.width * 4/3)

            introCollectionView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(height)
            }
            
            pageControl.snp.makeConstraints { make in
                make.bottom.equalTo(introCollectionView.snp.top).offset(-20)
                make.left.right.equalToSuperview()
                make.height.equalTo(24)
            }
            
            nextButton.snp.makeConstraints { make in
                make.bottom.equalTo(introCollectionView.snp.top).offset(-20)
                make.right.equalToSuperview().offset(-16)
                make.size.equalTo(24)
            }
            
            startButton.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-20)
                make.height.equalTo(50)
            }
        } else {
            // 41+10+58+50 = 159
            let height = 159 + (view.frame.width * 4/3)

            introCollectionView.snp.makeConstraints { make in
                make.left.right.bottom.equalToSuperview()
                make.height.equalTo(height)
            }
            
            pageControl.snp.makeConstraints { make in
                make.bottom.equalTo(introCollectionView.snp.top).offset(-69)
                make.left.right.equalToSuperview()
                make.height.equalTo(24)
            }
            
            nextButton.snp.makeConstraints { make in
                make.bottom.equalTo(introCollectionView.snp.top).offset(-69)
                make.right.equalToSuperview().offset(-16)
                make.size.equalTo(24)
            }
            
            startButton.snp.makeConstraints { make in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.bottom.equalToSuperview().offset(-20)
                make.height.equalTo(50)
            }
        }

        introCollectionView.register(IntroCollectionViewCell.self,
                                     forCellWithReuseIdentifier: IntroCollectionViewCell.description())
    }
    
    var currentPage: Int = 0
    
    @objc private func clickNext() {
        if currentPage < titleArray.count-1 {
            startButton.alpha = 0
            currentPage += 1
            checkCurrentPage()
            let indexPath = IndexPath(item: currentPage, section: 0)
            introCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
        }
    }
    
    @objc func start() {
        let checkIntro = UserDefault.checkIntro
        UserDefaults.standard.setValue(true, forKey: checkIntro)
        
        UIApplication.shared.keyWindow?.rootViewController
            = UINavigationController(rootViewController: MainTabBarController())
    }
    
    private func checkCurrentPage() {
        pageControl.currentPage = currentPage
        if currentPage == titleArray.count-1 {
            nextButton.alpha = 0
            startButton.alpha = 1
        } else {
            nextButton.alpha = 1
            startButton.alpha = 0
        }
    }

}

extension IntroViewController: UICollectionViewDelegate,
                               UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = titleArray.count
        return titleArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: IntroCollectionViewCell.description(),
                                                            for: indexPath) as? IntroCollectionViewCell
        else { return UICollectionViewCell() }

        cell.introImageView.image = UIImage(named: imageArray[indexPath.item])
        cell.introTitleLabel.text = titleArray[indexPath.item]
        cell.introDescLabel.text = descArray[indexPath.item]

        if cell.frame.height < 650 { // iphone X 보다 크기가 작은 경우 (7+ 모델들도 포함)
            cell.introDescLabel.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: 0, lineSpacing: 5)
        } else {
            cell.introDescLabel.customFont(fontName: .NanumSquareRoundR, size: 17, letterSpacing: 0, lineSpacing: 10)
        }
        
        cell.introDescLabel.textAlignment = .center
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height)
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let pageNumber = Int(targetContentOffset.pointee.x / view.frame.width)
        currentPage = pageNumber
        checkCurrentPage()
    }
}
