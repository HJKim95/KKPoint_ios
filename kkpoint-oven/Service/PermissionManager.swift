//
//  PermissionManager.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/19.
//

import UIKit

class PermissionManager {
    // MARK: - UserDefaults (알람 권한 날짜)
    /// 알람 권한 토글 날짜 가져오기
    class func getUserDefaultsDate() -> String {
        return UserDefaults.standard.string(forKey: UserDefault.pushAlertDate) ?? ""
    }
    /// String으로 알람 권한 토글 날짜 저장하기
    class func setUserDefaultsDateUseStr(str: String) {
        UserDefaults.standard.setValue(str, forKey: UserDefault.pushAlertDate)
    }
    /// Date로 알람 권한 토글 날짜 저장하기
    class func setUserDefaultsDateUseDate(date: Date) {
        let dateFormatter = Formatter.Date.dateFormatterGetWholeDate
        UserDefaults.standard.setValue(dateFormatter.string(from: Date()), forKey: UserDefault.pushAlertDate)
    }
    
    // MARK: - UserDefaults (알람 권한)
    /// UserDefaults 기존의 알람 권한 가져오기
    class func getUserDefaults() -> Bool {
        return UserDefaults.standard.bool(forKey: UserDefault.pushAlert)
    }
    /// UserDefaults 기존의 알람 권한 세팅하기
    class func setUserDefaults(bool: Bool) {
        UserDefaults.standard.setValue(bool, forKey: UserDefault.pushAlert)
    }
    
    /// 알람 설정이 처음인지 여부 가져오기
    class func isFirstAlertSet() -> Bool {
        return !UserDefaults.standard.bool(forKey: UserDefault.firstPushAlertSet)
    }
    /// 알람 설정 이미 한번 했다고 표시해두기
    class func didFirstAlertSet() {
        UserDefaults.standard.setValue(true, forKey: UserDefault.firstPushAlertSet)
    }
    
    /// 알람 수신 여부 토스트 띄웠는지 확인하고, 띄우기
    class func alertToast() {
        if !UserDefaults.standard.bool(forKey: "Toasted") {
            
            let dateFormatter = Formatter.Date.pushAlertFormatter
            let dateStr: String = dateFormatter.string(from: Date())
            
            getDevicePermission {
                ToastManager.showToast(message: dateStr + " 앱 푸시수신에 동의하셨습니다.")
            } isOffHandler: {
                ToastManager.showToast(message: dateStr + " 앱 푸시수신에 비동의하셨습니다.")
            }
        }
        UserDefaults.standard.setValue(true, forKey: "Toasted")
    }
    
    // MARK: - Device 설정 (알람 권한)
    /// 디바이스에서 알람 권한 여부 가져오기
    class func getDevicePermission(isOnHandler: @escaping () -> Void, isOffHandler: @escaping () -> Void ) {
        UNUserNotificationCenter.current().getNotificationSettings { setting in
            switch setting.authorizationStatus {
            case .authorized: // 디바이스 권한 알람 권한 있음
                isOnHandler()
            default: // 디바이스 권한 알람 권한 없음
                isOffHandler()
            }
        }
    }
    
    /// 앱 첫 실행시, 권한창에서 푸시 알람 띄우기 or 권한창에서는 선택 안하고 설정창에서 처음 on할시
    class func alertPermissionPopup(uiTaskHandler: @escaping () -> Void) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: options) { isEnable, _ in
            // 현재 날짜 문자열 생성
            let dateFormatter = Formatter.Date.dateFormatterGetWholeDate
            let dateStr: String = dateFormatter.string(from: Date())
            
            if isEnable {
                print("Permission granted: \(isEnable)")
                self.getNotificationSettings()
            }
            
            // 앱 알람 여부 유저디폴트 저장
            PermissionManager.setUserDefaults(bool: isEnable)
            
            // 앱 알람 토글 날짜 저장 (켜지든 꺼지든 날짜 있어야 하니까)
            PermissionManager.setUserDefaultsDateUseStr(str: dateStr)
            // 앱 알람을 켰다면 토스트 띄우기
//            if isEnable {
//                ToastManager.showToast(message: "\(dateStr) 앱 푸시수신에 동의하셨습니다") // ,
////                                       isTopWindow: false)
//            } else {
//                ToastManager.showToast(message: "\(dateStr) 앱 푸시수신에 비동의하셨습니다")
//            }
            // 이미 알람 세팅 했다고 표시
            didFirstAlertSet()
            // 설정창에서 띄울 경우, UI 작업을 위한 핸들러 실행
            uiTaskHandler()
        }
    }
    
    // for AWS APNS (App Delegate)
    class func getNotificationSettings() {
      UNUserNotificationCenter.current().getNotificationSettings { settings in
        print("Notification settings: \(settings)")
        guard settings.authorizationStatus == .authorized else { return } // 앱 설정창에 알람설정 OK 했을경우.
        DispatchQueue.main.async {
          UIApplication.shared.registerForRemoteNotifications()
        }
      }
    }
}
