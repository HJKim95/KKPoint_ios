//
//  Resource.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/12.
//

import UIKit

enum Resource {

    enum Color {
        // Orange
        static let orange01 = #colorLiteral(red: 1, green: 0.8784313725, blue: 0.6980392157, alpha: 1)
        static let orange02 = #colorLiteral(red: 1, green: 0.8, blue: 0.4980392157, alpha: 1)
        static let orange03 = #colorLiteral(red: 1, green: 0.7176470588, blue: 0.3019607843, alpha: 1)
        static let orange04 = #colorLiteral(red: 1, green: 0.6549019608, blue: 0.1490196078, alpha: 1)
        static let orange05 = #colorLiteral(red: 1, green: 0.5960784314, blue: 0.007843137255, alpha: 1)
        static let orange06 = #colorLiteral(red: 0.9960784314, green: 0.4941176471, blue: 0.1137254902, alpha: 1)
        static let orange07 = #colorLiteral(red: 0.937254902, green: 0.4235294118, blue: 0.003921568627, alpha: 1)
        static let orange08 = #colorLiteral(red: 0.9019607843, green: 0.3176470588, blue: 0.003921568627, alpha: 1)
        
        // Brown
        static let brown01 = #colorLiteral(red: 0.9568627451, green: 0.8588235294, blue: 0.7764705882, alpha: 1)
        static let brown02 = #colorLiteral(red: 0.8745098039, green: 0.6784313725, blue: 0.5215686275, alpha: 1)
        static let brown03 = #colorLiteral(red: 0.8235294118, green: 0.6078431373, blue: 0.431372549, alpha: 1)
        static let brown04 = #colorLiteral(red: 0.7333333333, green: 0.5098039216, blue: 0.3294117647, alpha: 1)
        static let brown05 = #colorLiteral(red: 0.5725490196, green: 0.3490196078, blue: 0.168627451, alpha: 1)
        static let brown06 = #colorLiteral(red: 0.4117647059, green: 0.2470588235, blue: 0.1137254902, alpha: 1)
        static let brown07 = #colorLiteral(red: 0.3450980392, green: 0.1960784314, blue: 0.07843137255, alpha: 1)
        static let brown08 = #colorLiteral(red: 0.2470588235, green: 0.1411764706, blue: 0.05490196078, alpha: 1)
        
        // Yellow
        static let yellow01 = #colorLiteral(red: 1, green: 0.9254901961, blue: 0.7019607843, alpha: 1)
        static let yellow02 = #colorLiteral(red: 1, green: 0.8784313725, blue: 0.5058823529, alpha: 1)
        static let yellow03 = #colorLiteral(red: 0.9960784314, green: 0.8823529412, blue: 0.3098039216, alpha: 1)
        static let yellow04 = #colorLiteral(red: 1, green: 0.7921568627, blue: 0.1568627451, alpha: 1)
        static let yellow05 = #colorLiteral(red: 1, green: 0.7176470588, blue: 0, alpha: 1)
        static let yellow06 = #colorLiteral(red: 1, green: 0.6274509804, blue: 0.007843137255, alpha: 1)
        static let yellow07 = #colorLiteral(red: 1, green: 0.5607843137, blue: 0.007843137255, alpha: 1)
        static let yellow08 = #colorLiteral(red: 1, green: 0.5176470588, blue: 0.007843137255, alpha: 1)
        
        // Grey
        static let grey01 = #colorLiteral(red: 0.9411764706, green: 0.9411764706, blue: 0.9411764706, alpha: 1)
        static let grey02 = #colorLiteral(red: 0.8901960784, green: 0.8862745098, blue: 0.8901960784, alpha: 1)
        static let grey03 = #colorLiteral(red: 0.8235294118, green: 0.8235294118, blue: 0.8235294118, alpha: 1)
        static let grey04 = #colorLiteral(red: 0.6117647059, green: 0.6117647059, blue: 0.6117647059, alpha: 1)
        static let grey05 = #colorLiteral(red: 0.4274509804, green: 0.4274509804, blue: 0.4274509804, alpha: 1)
        static let grey06 = #colorLiteral(red: 0.2941176471, green: 0.2941176471, blue: 0.2941176471, alpha: 1)
        static let grey07 = #colorLiteral(red: 0.1568627451, green: 0.1568627451, blue: 0.1568627451, alpha: 1)
        static let grey08 = #colorLiteral(red: 0.1058823529, green: 0.1058823529, blue: 0.1058823529, alpha: 1)
        
        // Black
        static let black01 = UIColor.black.withAlphaComponent(0.85)
        static let black02 = UIColor.black.withAlphaComponent(0.70)
        static let black03 = UIColor.black.withAlphaComponent(0.10)
        
        // Sub Color
        static let red01 = #colorLiteral(red: 0.9882352941, green: 0.3803921569, blue: 0.3647058824, alpha: 1)
        static let blue01 = #colorLiteral(red: 0, green: 0.4117647059, blue: 0.9960784314, alpha: 1)
        static let blue02 = #colorLiteral(red: 0.3490196078, green: 0.6117647059, blue: 1, alpha: 1)
        static let blue03 = #colorLiteral(red: 0.2352941176, green: 0.4862745098, blue: 0.8588235294, alpha: 1)
        static let blue04 = #colorLiteral(red: 0.09803921569, green: 0.262745098, blue: 0.4039215686, alpha: 1)
        static let pink01 = #colorLiteral(red: 0.9607843137, green: 0.6274509804, blue: 0.8431372549, alpha: 1)
        static let green01 = #colorLiteral(red: 0.3921568627, green: 0.8666666667, blue: 0.5529411765, alpha: 1)
        static let green02 = #colorLiteral(red: 0.3137254902, green: 0.6352941176, blue: 0.3411764706, alpha: 1)
        
        // White
        static let white00 = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)

        // BG Color
        static let bgYellow01 = #colorLiteral(red: 0.9803921569, green: 0.968627451, blue: 0.9411764706, alpha: 1)
        static let bgYellow02 = #colorLiteral(red: 0.9882352941, green: 0.9529411765, blue: 0.8941176471, alpha: 1)
        
        // 소셜 로그인 Color
        static let social_login_google = #colorLiteral(red: 0.9568627451, green: 0.262745098, blue: 0.2117647059, alpha: 1)
        static let social_login_kakao = #colorLiteral(red: 0.9960784314, green: 0.8980392157, blue: 0, alpha: 1)
        static let social_login_naver = #colorLiteral(red: 0.01176470588, green: 0.8117647059, blue: 0.3647058824, alpha: 1)
    }

    enum Font: String {
        case NanumSquareRoundEB
        case NanumSquareRoundB
        case NanumSquareRoundR
    }

    enum AdMob {
        static let adShowTerm = 3
        static let admobID = String(describing: AdmobCell.self)
    }
}
