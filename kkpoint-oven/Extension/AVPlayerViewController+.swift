//
//  AVPlayerViewController.swift
//  youtube
//
//  Created by 박영호 on 2021/01/08.
//

import AVKit

/// 유튜브 전체화면은 AVPlayerViewController임.
/// AVPlayerViewController에서 화면 방향을 고정시키기 위한 익스텐션
extension AVPlayerViewController {
    open override func viewWillAppear(_ animated: Bool) {
        UINavigationBar.appearance().barTintColor = .black
    }
    open override func viewWillDisappear(_ animated: Bool) {
        UINavigationBar.appearance().barTintColor = UIColor(named: "elavated")
    }

    open override var shouldAutorotate: Bool {
        return false
    }
    
    open override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }
}
