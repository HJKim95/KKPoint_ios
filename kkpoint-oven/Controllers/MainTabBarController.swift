//
//  MainTabBarController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit
import Then

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {
    
    // tabbar corner rounding 20
    private let tabBarCornerRadius: CGFloat = 20

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        
        self.delegate = self
        tabBar.shadowImage = UIImage() // this removes the top line of the tabBar
        tabBar.backgroundImage = UIImage() // this changes the UI backdrop view of tabBar to transparent
        
        setupNavBarItems()
        setupTabItems()
        checkMyVersion()
        
        // 로그인 관련 UI작업 노티피케이션 설정
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(getDataAfterLogin),
                                               name: Notification.Login.checkLogin,
                                               object: nil)
        if AccountManager.shared.isLogged {
            getDataAfterLogin()
        }
        
    }
    
    var checkOneTime = false
    
    private func makeTabbarRoundedShadow() {
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = UIBezierPath(
            roundedRect: tabBar.bounds,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: tabBarCornerRadius, height: 0.0)).cgPath
        shapeLayer.fillColor = UIColor(named: "elavated")?.cgColor
        shapeLayer.shadowPath =  UIBezierPath(roundedRect: tabBar.bounds, cornerRadius: tabBarCornerRadius).cgPath
        shapeLayer.shadowColor = UIColor.black.cgColor
        shapeLayer.shadowOpacity = 0.2
        shapeLayer.shadowRadius = 5
        shapeLayer.shadowOffset = CGSize(width: 0, height: -1)

        // To improve rounded corner and shadow performance tremendously
        shapeLayer.shouldRasterize = true
        shapeLayer.rasterizationScale = UIScreen.main.scale

        if !checkOneTime {
            // shadow 한번만 적용하게
            tabBar.layer.insertSublayer(shapeLayer, at: 0)
            checkOneTime = true
        }
        
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        makeTabbarRoundedShadow()
    }

    private func setupNavBarItems() {
        // custom navBar backButton
        let backImage = UIImage(named: "iconBackB24")
        UINavigationBar.appearance().backIndicatorImage = backImage
        UINavigationBar.appearance().backIndicatorTransitionMaskImage = backImage
        UINavigationBar.appearance().tintColor = UIColor(named: "primary01")
        // 네비게이션 밑줄 없애기
        UINavigationBar.appearance().shadowImage = UIImage()
        // 'back' text 제거
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }

    private func setupTabItems() {
        let home = HomeViewController()
        let homeImage = UIImage(named: "btnMenuHomeN")?.withRenderingMode(.alwaysOriginal)
        let homeImageSelect = UIImage(named: "btnMenuHomeNSelected")?.withRenderingMode(.alwaysOriginal)
        home.tabBarItem = UITabBarItem(title: "홈", image: homeImage, selectedImage: homeImageSelect)

        let famous = FamousViewController()
        let famousImage = UIImage(named: "btnMenuPopularN")?.withRenderingMode(.alwaysOriginal)
        let famousImageSelect = UIImage(named: "btnMenuPopularNSelected")?.withRenderingMode(.alwaysOriginal)
        famous.tabBarItem = UITabBarItem(title: "인기", image: famousImage, selectedImage: famousImageSelect)

        let subscribe = SubscribeViewController()
        let subscribeImage = UIImage(named: "btnMenuSubscribeN")?.withRenderingMode(.alwaysOriginal)
        let subscribeImageSelect = UIImage(named: "btnMenuSubscribeNSelected")?.withRenderingMode(.alwaysOriginal)
        subscribe.tabBarItem = UITabBarItem(title: "구독", image: subscribeImage, selectedImage: subscribeImageSelect)

        let shop = CouponViewController()
        let shopImage = UIImage(named: "btnMenuCouponN")?.withRenderingMode(.alwaysOriginal)
        let shopImageSelect = UIImage(named: "btnMenuCouponS")?.withRenderingMode(.alwaysOriginal)
        shop.tabBarItem = UITabBarItem(title: "쿠폰", image: shopImage, selectedImage: shopImageSelect)
        
        let charge = ChargeViewController()
        let chargeImage = UIImage(named: "btnMenuChargeN")?.withRenderingMode(.alwaysOriginal)
        let chargeImageSelect = UIImage(named: "btnMenuChargeNSelected")?.withRenderingMode(.alwaysOriginal)
        charge.tabBarItem = UITabBarItem(title: "무료충전소", image: chargeImage, selectedImage: chargeImageSelect)
        
        // 20210204 화면 회전 조정을 위함
        addChild(home)
        addChild(famous)
        addChild(subscribe)
        addChild(shop)
        addChild(charge)
        
        let tabBarList = [home, famous, subscribe, shop, charge]
        viewControllers = tabBarList
        tabBar.barTintColor = UIColor(named: "elavated")
        tabBar.unselectedItemTintColor = Resource.Color.grey05
        tabBar.tintColor = Resource.Color.orange06
        
        let font = UIFont(name: "NanumSquareRoundR", size: 10)!
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .normal)
        UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.font: font], for: .selected)
        
    }
    
    var isRecentVersion: Bool?
    var lastVersion = ""
    
    private func checkMyVersion() {
        guard let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else { return }
        NetworkManager.getVersionData { [weak self] (result) in
            switch result {
            case .success(let data):
                let marketVersion = data.data?.marketVersion
                if version == marketVersion {
                    self?.isRecentVersion = true
                } else {
                    self?.isRecentVersion = false
                }

            case .failure(let error):
                print(error)
                PopupManager.shared.showPopup(mainStr: "버전 관련 오류가 발생하였습니다.",
                                              positiveButtonOption: ButtonOption(title: "확인", handler: {
                    
                }), enableBackgroundTouchOut: true)
            }
        }
        
    }
    
    @objc private func getDataAfterLogin() {
        getPointData()
        getAttendanceData()
    }

    private func getPointData() {
        AccountManager.shared.getPoint()
    }
    
    private func getAttendanceData() {
        AccountManager.shared.getAttendance()
    }
    
    var currentIndex = 0 // 현재 보고있는 탭에서 탭버튼을 눌렀을 때만 올라가는 scroll 구현
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        switch tabBarIndex {
        case 0:
            if currentIndex == tabBarIndex {
                let homeViewController = self.viewControllers?[tabBarIndex] as? HomeViewController
                homeViewController?.homeCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            currentIndex = tabBarIndex
        case 1:
            if currentIndex == tabBarIndex {
                let famousViewController = self.viewControllers?[tabBarIndex] as? FamousViewController
                famousViewController?.famousCollectionView.setContentOffset(CGPoint(x: 0, y: -16), animated: true)
            }
            currentIndex = tabBarIndex
        case 2:
            if currentIndex == tabBarIndex {
                let subscribeViewController = self.viewControllers?[tabBarIndex] as? SubscribeViewController
                subscribeViewController?.subscribeCollectionView.setContentOffset(CGPoint(x: 0, y: -16), animated: true)
            }
            currentIndex = tabBarIndex
        case 3:
            if currentIndex == tabBarIndex {
                let couponViewController = self.viewControllers?[tabBarIndex] as? CouponViewController
                couponViewController?.couponCollectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            }
            currentIndex = tabBarIndex

        default:
            print("Tabbed Index: ", tabBarIndex)
        }
    }
}
