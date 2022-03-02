//
//  ToastManager.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/19.
//

import UIKit
import SnapKit

class ToastManager {
    class func showToast (message: String) {
        DispatchQueue.main.async {
            let sideMargin: CGFloat = 16
            
            let container: UIView = UIView().then {
                $0.backgroundColor = UIColor(named: "toastColor")
                $0.layer.cornerRadius = 12
                $0.layer.masksToBounds = true
            }
            
            let toastLabel: UILabel = UILabel().then {
                $0.textColor = UIColor(named: "toastTextColor")
                $0.text = message
                $0.numberOfLines = 0
                $0.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
                $0.textAlignment = .center
            }
            
            guard let top = UIApplication.shared.keyWindow else { return }
            guard let topController = Utilities.topViewController() else {return}
            let title = topController.title
            let tabBarHeight = UITabBarController().tabBar.frame.height
            var offset: CGFloat = 20
            if title == "홈" || title == "인기" || title == "구독" || title == "쿠폰" || title == "무료충전소" {
                offset += tabBarHeight
            }

            top.addSubview(container)
            container.addSubview(toastLabel)

            container.snp.makeConstraints {
                $0.left.right.equalToSuperview().inset(sideMargin)
                $0.bottom.equalTo(top.safeAreaLayoutGuide).offset(150)
                $0.height.equalTo(48)
            }
            toastLabel.snp.makeConstraints {
                $0.top.left.right.bottom.equalToSuperview()
            }
            
            UIView.animate(withDuration: 0.1, delay: 0, animations: {
                // 일단 밑에 레이아웃하기 위한 버퍼 애니메이션
                container.alpha = 1
            },
            completion: { _ in
                UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8,
                               initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                    // 위로 올리기
                    container.snp.updateConstraints {
                        $0.bottom.equalTo(top.safeAreaLayoutGuide).offset(-offset)
                    }
                    container.superview?.layoutIfNeeded()
                }, completion: { _ in
                    UIView.animate(withDuration: 0.5, delay: 1.5, usingSpringWithDamping: 0.8,
                                   initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                        // 밑으로 내리기
                        container.snp.updateConstraints {
                            $0.bottom.equalTo(top.safeAreaLayoutGuide).offset(150)
                        }
                        container.superview?.layoutIfNeeded()
                    }, completion: { _ in
                        container.removeFromSuperview()
                    })
                })

            })
        }
    }
}
