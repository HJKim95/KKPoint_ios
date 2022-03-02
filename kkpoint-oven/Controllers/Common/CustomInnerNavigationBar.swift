//
//  CustomInnerNavigationBar.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/22.
//

import UIKit
import SnapKit

class CustomInnerNavigationBar: UIView {
    
    let statusBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "elavated")
        return view
    }()
    
    let navBackView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(named: "elavated")
        return view
    }()

    lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "iconBackB24")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(goPop), for: .touchUpInside)
        return button
    }()
    
    lazy var xButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(UIImage(named: "iconCloseB24"), for: .normal)
        button.addTarget(self, action: #selector(tabXbutton), for: .touchUpInside)
        button.alpha = 0
        return button
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(named: "primary01")
        return label
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("보내기", for: .normal)
        button.isEnabled = false
        button.alpha = 0
        // Zeplin에는 12라고 쓰여있지만 너무 작아서 14로 변경
        button.titleLabel?.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.5)
        button.titleLabel?.textAlignment = .right
        button.tintColor = Resource.Color.orange06
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupLayouts() {
        self.backgroundColor = UIColor(named: "elavated")

        addSubview(statusBackView)
        addSubview(navBackView)
        navBackView.addSubview(backButton)
        navBackView.addSubview(xButton)
        navBackView.addSubview(titleLabel)
        navBackView.addSubview(sendButton)
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        statusBackView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
        
        navBackView.snp.makeConstraints { (make) in
            make.top.equalTo(statusBackView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
            make.size.equalTo(24)
        }
        
        xButton.snp.makeConstraints { (make) in
            make.top.left.right.bottom.equalTo(backButton)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(60)
            make.right.equalToSuperview().offset(-60)
        }

        sendButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-16)
            make.centerY.equalToSuperview()
            make.left.equalTo(titleLabel.snp.right)
            make.height.equalTo(16)
        }

    }

    @objc private func goPop() {
        Utilities.topViewController()?.navigationController?.popViewController(animated: true)
    }

    @objc private func tabXbutton() {
        Utilities.topViewController()?.dismiss(animated: true, completion: nil)
    }
}
