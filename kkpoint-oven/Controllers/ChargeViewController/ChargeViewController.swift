//
//  ChargeViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/24.
//

import UIKit

class ChargeViewController: UIViewController {
    private let chargeCellID = String(describing: MainYoutubeVideoCell.self)
    
    let customNavigationBar = CustomNavigationBar()
    
    lazy var chargeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 10
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "base")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 0, right: 0)
        collectionview.alwaysBounceVertical = true
        return collectionview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        setupLayouts()
        self.title = "무료충전소"
        
        chargeCollectionView.register(ChargeCollectionViewCell.self, forCellWithReuseIdentifier: chargeCellID)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        if !AccountManager.shared.isLogged { // 로그인 안했을 시 로그인창으로
            let loginVC = LoginViewController()
            if #available(iOS 13.0, *) {
                loginVC.isModalInPresentation = true // swipe로 dismiss 못하게 방지
            } else {
                loginVC.modalPresentationStyle = .fullScreen
            }
            present(loginVC, animated: true)
        }
    }

    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")
        view.addSubview(customNavigationBar)
        view.addSubview(chargeCollectionView)
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(56+statusBarHeight)
        }
        
        chargeCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(customNavigationBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func showRV() {
        AdiscopeManager.shared.showRV()
    }
    private func goChargeStation() {
        AdiscopeManager.shared.goChargeStation()
    }
}

extension ChargeViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: chargeCellID,
                                                         for: indexPath) as? ChargeCollectionViewCell {
            if indexPath.item == 0 {
                cell.chargeLabel.text = "비디오 시청하면 킥킥포인트를 드려요!"
                cell.backgroundImageView.image = UIImage(named: "imgFreechargeRv")
                cell.presentButtonView.presentLabel.text = "RV시청"
                cell.presentButtonView.presentImageView.image = UIImage(named: "imgDailyRv")
                cell.presentButtonViewWidth = 89
                
            } else {
                cell.chargeLabel.text = "무료충전소에서 포인트를 적립하세요!"
                cell.backgroundImageView.image = UIImage(named: "imgFreechargeCharge")
                cell.presentButtonView.presentLabel.text = "충전소 이동"
                cell.presentButtonView.presentImageView.image = UIImage(named: "imgDailyCharging")
                cell.presentButtonViewWidth = 110
            }

            return cell
        }
        return UICollectionViewCell()
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = collectionView.frame.width - 32
        return CGSize(width: width, height: width/2)
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let index = indexPath.item
        if index == 0 {
            self.showRV()
        } else {
            self.goChargeStation()
        }
    }

    // for smooth scroll with rounded cell & shadow
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        cell.contentView.layer.masksToBounds = true
        let radius = cell.contentView.layer.cornerRadius
        cell.layer.shadowPath = UIBezierPath(roundedRect: cell.bounds, cornerRadius: radius).cgPath
    }
}
