//
//  Utilities.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/19.
//

import UIKit

class Utilities {
    class func topWindow() -> UIViewController? {
        return UIApplication.shared.keyWindow?.rootViewController
    }
    
    class func topViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        // return base
        if let nav = base as? UINavigationController {
            return topViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController {
            if let selected = tab.selectedViewController {
                return topViewController(base: selected)
            }
        }
        if let presented = base?.presentedViewController {
            return topViewController(base: presented)
        }
        return base
    }
    
    /// 무료 충전소로
    class func toFreeChargeStation() {
        guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        navi.popToRootViewController(animated: true)
        guard let tabbar = navi.viewControllers[0] as? UITabBarController else { return }
        tabbar.selectedIndex = 4
    }
    
    /// 쿠폰 보관함으로
    class func toCouponChest() {
        guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        navi.popToRootViewController(animated: true)
        navi.pushViewController(MyCouponViewController(), animated: true)
    }
    /// 쿠폰 샵으로
    class func toCouponList() {
        guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        navi.popToRootViewController(animated: true)
        guard let tabbar = navi.viewControllers[0] as? UITabBarController else { return }
        tabbar.selectedIndex = 3
    }
    
    /// 쿠폰 샵으로
    class func toHome() {
        guard let navi = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        navi.popToRootViewController(animated: true)
        guard let tabbar = navi.viewControllers[0] as? UITabBarController else { return }
        tabbar.selectedIndex = 0
    }
    
    class func lineNumber(label: UILabel, labelWidth: CGFloat) -> Int {
        let boundingRect = label.text!.boundingRect(with: .zero, options: [.usesFontLeading],
                                             attributes: [.font: label.font!], context: nil)
        return Int(boundingRect.width / labelWidth + 1)
    }
}
