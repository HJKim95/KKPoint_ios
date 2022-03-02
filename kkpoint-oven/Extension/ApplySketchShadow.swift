//
//  ApplySketchShadow.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/05.
//

import UIKit

extension CALayer {
  func applySketchShadow(color: UIColor = .black, alpha: Float = 0.5, widthX: CGFloat = 0,
                         widthY: CGFloat = 2, blur: CGFloat = 4, spread: CGFloat = 0) {
    masksToBounds = false
    shadowColor = color.cgColor
    shadowOpacity = alpha
    shadowOffset = CGSize(width: widthX, height: widthY)
    shadowRadius = blur / 2.0
    if spread == 0 {
      shadowPath = nil
    } else {
      let inset = -spread
      let rect = bounds.insetBy(dx: inset, dy: inset)
      shadowPath = UIBezierPath(rect: rect).cgPath
    }
  }
}
