//
//  LottieManager.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/09.
//

import UIKit
import Lottie

class LottieManager {
    static let shared = LottieManager()
    
    let animationView = AnimationView(name: "lf30_ysiwhpp5")
    
    private init() {}
    
    func startReload() {
        Utilities.topWindow()?.view.isUserInteractionEnabled = false
        animationView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        if let keyWindow = UIApplication.shared.keyWindow {
            animationView.center = keyWindow.center
            keyWindow.addSubview(animationView)
        }
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .loop
        animationView.play()
    }

    func stopReload() {
        animationView.stop()
        animationView.removeFromSuperview()
        Utilities.topWindow()?.view.isUserInteractionEnabled = true
    }
    
    func startReloadOnce() {
        Utilities.topWindow()?.view.isUserInteractionEnabled = false
        animationView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        if let keyWindow = UIApplication.shared.keyWindow {
            animationView.center = keyWindow.center
            keyWindow.addSubview(animationView)
        }
        
        animationView.contentMode = .scaleAspectFit
        animationView.loopMode = .playOnce
        animationView.play()
    }
}
