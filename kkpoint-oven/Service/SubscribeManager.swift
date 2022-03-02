//
//  SubscribeManager.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/02/26.
//

import UIKit

class SubscribeManager {
    
    class func apply(cid: String, successHandler: @escaping () -> Void) {
        // 로그인 체크
        if !AccountManager.shared.isLogged {
            return
        }
        
        // 구독 시도
        NetworkManager.postSubscribe(cid: cid) { (result) in
            switch result {
            case .success(let check):
                // 구독 정보 변경 Noti
                NotificationCenter.default.post(name: Notification.Subscribe.checkSubscribe, object: self)
                // 성공 했을 때 핸들러 실행
                if check.resultCode == "resultDataOK" {
                    successHandler()
                } else {
                    print("구독하기 API ERROR")
                }
            case .failure(let error):
                print("구독하기 API ERROR: \(error)")
            }
        }
    }
    
    class func cancel(cid: String, successHandler: @escaping () -> Void) {
        // 로그인 체크
        if !AccountManager.shared.isLogged {
//            ToastManager.showToast(message: "로그인 후 구독할 수 있어요.", isTopWindow: true)
            return
        }
        // 구독 해제 시도
        NetworkManager.deleteSubscribe(cid: cid) { (result) in
            switch result {
            case .success(let check):
                // 구독 정보 변경 Noti
                NotificationCenter.default.post(name: Notification.Subscribe.checkSubscribe, object: self)
                if check.resultCode == "resultOK" {
                    successHandler()
                } else {
                    print("구독 해제하기 API ERROR")
                }
            case .failure(let error):
                print("구독 해제하기 API ERROR: \(error)")
            }
        }
    }
}
