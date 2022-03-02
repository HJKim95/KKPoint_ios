//
//  AdiscopeManager.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/10.
//

import UIKit
import Adiscope

class AdiscopeManager {
    static let shared = AdiscopeManager()
    
    #if DEV
    let mediaID = "202"
    let mediaSecretKey = "f63652e547d643d1aba3376921df3135"
    #else
    let mediaID = "203"
    let mediaSecretKey = "9084523077df46a3a70c65d0adf4dbcf"
    #endif
    
    private let rvUnitID = "I_RV_1"
    private let offerwallUnitID = "I_OFFERWALL"
    private let interstitialUnitID = "I_INTERSTITIAL_1"
    private var adiscope = AdiscopeInterface.sharedInstance()
    
    private var isRewarded = false
    private var amount = 0
    
    var didInit: Bool = false
    
    func adiscopeInit() {
        adiscope?.setMainDelegate(self)
        adiscope?.initialize(mediaID, mediaSecret: mediaSecretKey, callBackTag: "")
        var userID = "AnonymousUser"
        if let intUserId =  AccountManager.shared.user.uid {
            userID = String(intUserId)
        }
        adiscope?.setUserId(userID)
    }
    
    func showInterStitial() {
        guard let adiscope = self.adiscope else { return }
        if adiscope.isLoadedInterstitialUnitID(interstitialUnitID) {
            adiscope.showInterstitial()
        } else {
            adiscope.loadInterstitial(interstitialUnitID)
        }
    }
    
    func showRV() {
        let ageCheck = UserDefaults.standard.bool(forKey: UserDefault.didAgeCheck)
        if !ageCheck {
            let mainStr = "만 14세 미만이신가요?"
            let subStr = "클린한 광고제공을 위해\n연령정보가 필요합니다."
            PopupManager.shared.showPopup(
                mainStr: mainStr, subStr: subStr,
                positiveButtonOption: ButtonOption(title: "네 만14세 이상입니다") {
                    PopupManager.shared.showCheckParents(isAdvertise: true) { [weak self] in
                        UserDefaults.standard.setValue(true, forKey: UserDefault.didAgeCheck)
                        guard let adiscope = self?.adiscope else { return }
                        if adiscope.isLoaded(self?.rvUnitID ?? "") {
                            adiscope.show()
                        } else {
                            LottieManager.shared.startReload()
                            adiscope.load(self?.rvUnitID ?? "")
                        }
                    }
                },
                negativeButtonOption: ButtonOption(title: "아니요.") {
                    
                }, backgroundColor: BackgroundColorOption(popupViewColor: UIColor(named: "elavated")!,
                                                           unableViewColor: UIColor.black.withAlphaComponent(0.7))
            )
        } else {
            guard let adiscope = adiscope else { return }
            LottieManager.shared.startReload()
            if adiscope.isLoaded(rvUnitID) {
                adiscope.show()
            } else {
                adiscope.load(rvUnitID)
            }
        }
    }
    
    func goChargeStation() {
        let ageCheck = UserDefaults.standard.bool(forKey: UserDefault.didAgeCheck)
        if !ageCheck {
            let mainStr = "만 14세 미만이신가요?"
            let subStr = "클린한 광고제공을 위해\n연령정보가 필요합니다."
            PopupManager.shared.showPopup(
                mainStr: mainStr, subStr: subStr,
                positiveButtonOption: ButtonOption(title: "네 만14세 이상입니다") {
                    PopupManager.shared.showCheckParents(isAdvertise: true) {
                        UserDefaults.standard.setValue(true, forKey: UserDefault.didAgeCheck)
                        self.adiscope?.showOfferwall(self.offerwallUnitID)
                    }
                },
                negativeButtonOption: ButtonOption(title: "아니요.") {
                
                }, backgroundColor: BackgroundColorOption(popupViewColor: UIColor(named: "elavated")!,
                                                           unableViewColor: UIColor.black.withAlphaComponent(0.7)),
                enableBackgroundTouchOut: true)
        } else {
            
            self.adiscope?.showOfferwall(self.offerwallUnitID)
            
        }
    }
    
    private var checkInterStitialTimeOut = false
}
extension AdiscopeManager: AdiscopeDelegate {
    
    func onInterstitialAdLoaded(_ unitID: String!) {
        print("ㅡㅡㅡㅡㅡInterStitial 로드 완료ㅡㅡㅡㅡㅡ")
        guard let adiscope = self.adiscope else { return }
        adiscope.showInterstitial()
    }
    
    func onInterstitialAdOpened(_ unitID: String!) {
        print("ㅡㅡㅡㅡㅡInterStitial Openedㅡㅡㅡㅡㅡ")
    }
    
    func onInterstitialAdClosed(_ unitID: String!) {
        print("ㅡㅡㅡㅡㅡInterStitial Closedㅡㅡㅡㅡㅡ")
    }
    
    func onInterstitialAdFailed(toLoad unitID: String!, error: AdiscopeError!) {
        print("ㅡㅡㅡㅡㅡInterStitial Load Failedㅡㅡㅡㅡㅡ")
        print(error)
    }
    
    func onInterstitialAdFailed(toShow unitID: String!, error: AdiscopeError!) {
        print("ㅡㅡㅡㅡㅡInterStitial Show Failedㅡㅡㅡㅡㅡ")
        print(error)
    }
    
    func onRewardedVideoAdOpened(_ unitId: String!) {
        LottieManager.shared.stopReload()
    }
    func onRewardedVideoAdFailed(toShow unitId: String!, error: AdiscopeError!) {
        LottieManager.shared.stopReload()
        PopupManager.shared.showPopup(
            mainStr: "보상형 광고 로드 실패",
            subStr: "불편을 드려 죄송합니다.",
            positiveButtonOption: ButtonOption(title: "확인") {}
        )
    }
    
    func onRewardedVideoAdClosed(_ unitId: String!) {
        if isRewarded {
            let formattedAmount = Formatter.Number.getFormattedNum(num: amount)
            ToastManager.showToast(message: "\(formattedAmount)포인트가 적립되었습니다.")
            AccountManager.shared.getPoint()
            isRewarded = false
        }
    }

    func onRewarded(_ unitID: String!, item: AdiscopeRewardItem!) {
        amount = Int(item.amount)
        isRewarded = true
    }
    
    func onRewardedVideoAdLoaded(_ unitID: String!) {
        print("ㅡㅡㅡㅡㅡ애디스콥 광고 로드 완료ㅡㅡㅡㅡㅡ")
        LottieManager.shared.stopReload()
        guard let adiscope = adiscope else { return }
        adiscope.show()
    }
    
    func onRewardedVideoAdFailed(toLoad unitID: String!, error: AdiscopeError!) {
        LottieManager.shared.stopReload()
        PopupManager.shared.showPopup(
            mainStr: "보상형 광고 로드 실패",
            subStr: "불편을 드려 죄송합니다.",
            positiveButtonOption: ButtonOption(title: "확인") {}
        )
    }
}
