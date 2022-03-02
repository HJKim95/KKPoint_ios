//
//  UILabel+FontWithKern.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/02/17.
//

import UIKit

extension UILabel {
    
    func customFont(fontName: Resource.Font, size: CGFloat, letterSpacing: CGFloat? = nil, lineSpacing: CGFloat? = nil) {

        let attributeString = NSMutableAttributedString(string: self.text ?? "")
        let range = NSRange(location: 0, length: attributeString.length)
        let letterSpaceValue = letterSpacing ?? 0
        let lineSpaceValue = lineSpacing ?? 0
        guard let font = UIFont(name: fontName.rawValue, size: size) else { return }
        self.font = font
        attributeString.addAttributes([NSAttributedString.Key.kern: letterSpaceValue,
                                       NSAttributedString.Key.font: font], range: range)
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpaceValue
        if lineSpaceValue > 0 { self.numberOfLines = 0 }
        attributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        
        self.attributedText = attributeString
    }
}

extension UITextView {
    func customFont(fontName: Resource.Font, size: CGFloat, letterSpacing: CGFloat? = nil, lineSpacing: CGFloat? = nil) {
        
        let attributeString = NSMutableAttributedString(string: self.text ?? "")
        let range = NSRange(location: 0, length: attributeString.length)
        let letterSpaceValue = letterSpacing ?? 0
        let lineSpaceValue = lineSpacing ?? 0
        guard let font = UIFont(name: fontName.rawValue, size: size) else { return }
        self.font = font
        attributeString.addAttributes([NSAttributedString.Key.kern: letterSpaceValue,
                                       NSAttributedString.Key.font: font], range: range)
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = lineSpaceValue
        attributeString.addAttribute(NSAttributedString.Key.paragraphStyle, value: style, range: range)
        
        self.attributedText = attributeString
    }
}

extension UITextField {
    func customFont(fontName: Resource.Font, size: CGFloat, letterSpacing: CGFloat? = nil) {
        
        let attributeString = NSMutableAttributedString(string: self.text ?? "")
        let range = NSRange(location: 0, length: attributeString.length)
        let letterSpaceValue = letterSpacing ?? 0
        guard let font = UIFont(name: fontName.rawValue, size: size) else { return }
        self.font = font
        attributeString.addAttributes([NSAttributedString.Key.kern: letterSpaceValue,
                                       NSAttributedString.Key.font: font], range: range)

        self.attributedText = attributeString
    }
}
