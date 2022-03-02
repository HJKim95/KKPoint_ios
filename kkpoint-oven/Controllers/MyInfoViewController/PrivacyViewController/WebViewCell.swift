//
//  WebViewCell.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/08.
//

import UIKit
import WebKit

class WebViewCell: UICollectionViewCell {
    private let webView: WKWebView = WKWebView(frame: .zero, configuration: WKWebViewConfiguration()).then {
        $0.scrollView.showsVerticalScrollIndicator = false
        $0.isOpaque = false
        $0.backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        webView.load(URLRequest(url: URL(string: "https://kkpoint-static-dev.idol-master.kr/index.html")!))
        webView.navigationDelegate = self
    }
    
    private func setupLayout() {
        addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalToSuperview()
        }
    }
}

extension WebViewCell: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if traitCollection.userInterfaceStyle == .dark { // 다크모드
            webView.evaluateJavaScript("setDarkMode();") { (result, error) in
                print("Result: ", result ?? "")
                print("Error: ", error ?? "")
            }
        } else { // Light 모드
            webView.evaluateJavaScript("setLightMode();") { (result, error) in
                print("Result: ", result ?? "")
                print("Error: ", error ?? "")
            }
        }
    }
}
