//
//  AdmobCell.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/03.
//

import UIKit
import SnapKit
import GoogleMobileAds

#if DEV
let adUnitID = "ca-app-pub-9819870612497647/1873534814"
#else
let adUnitID = "ca-app-pub-9819870612497647/4579411596"
#endif

class AdmobCell: UICollectionViewCell {
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
    }
    
    private var bgView: UIView = UIView().then {
        $0.backgroundColor = UIColor(named: "base")
    }
    private var bannerView: GADBannerView = GADBannerView(adSize: kGADAdSizeBanner)
    
    private var indicator: UIActivityIndicatorView = UIActivityIndicatorView().then {
        $0.hidesWhenStopped = false
        $0.style = .white
    }
    
    private var isLoaded: Bool = false
    
    func mappingData(rootVC: UIViewController) {
        bannerView.rootViewController = rootVC
        bannerView.adUnitID = adUnitID
        if !self.isLoaded {
            // TODO: 모든 cell에서 동일한 광고가 나올수 있으니 실제로 적용하고 다시 확인해보자
            bannerView.load(GADRequest())
            self.isLoaded = true
        }
        bannerView.delegate = self
    }
    
    private func setupLayout() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        let width = self.frame.width

        contentView.addSubview(bgView)
        bgView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.width.equalTo(width)
            $0.height.equalTo(width * 0.3125)
        }
        
        bgView.addSubview(bannerView)
        bannerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}

extension AdmobCell: GADBannerViewDelegate {
    /// Tells the delegate an ad request loaded an ad.
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
      print("adViewDidReceiveAd")
        bannerView.alpha = 0
        UIView.animate(withDuration: 1) {
            bannerView.alpha = 1
        }
    }

    /// Tells the delegate that a full-screen view will be presented in response
    /// to the user clicking on an ad.
    func bannerViewWillPresentScreen(_ bannerView: GADBannerView) {
      print("adViewWillPresentScreen")
    }

    /// Tells the delegate that the full-screen view will be dismissed.
    func bannerViewWillDismissScreen(_ bannerView: GADBannerView) {
      print("adViewWillDismissScreen")
    }

    /// Tells the delegate that the full-screen view has been dismissed.
    func bannerViewDidDismissScreen(_ bannerView: GADBannerView) {
      print("adViewDidDismissScreen")
    }

    /// Tells the delegate that a user click will open another app (such as
    /// the App Store), backgrounding the current app.
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
      print("adViewWillLeaveApplication")
    }
}
