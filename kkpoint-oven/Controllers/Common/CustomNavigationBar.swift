//
//  CustomNavigationBar.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/03/16.
//

import UIKit
import SnapKit

class CustomNavigationBar: UIView {
    
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
    
    lazy var mainTitleButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "imgLogoToolbar")
        button.setImage(image, for: .normal)
        return button
    }()
    
    lazy var searchButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "iconSearch36")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(goSearch), for: .touchUpInside)
        return button
    }()
    
    lazy var myInfoButton: UIButton = {
        let button = UIButton(type: .custom)
        let image = UIImage(named: "iconMyface32")
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(goMyInfo), for: .touchUpInside)
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
        navBackView.addSubview(mainTitleButton)
        navBackView.addSubview(searchButton)
        navBackView.addSubview(myInfoButton)
        
        let statusBarHeight = UIApplication.shared.statusBarFrame.height
        statusBackView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(statusBarHeight)
        }
        
        navBackView.snp.makeConstraints { (make) in
            make.top.equalTo(statusBackView.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        
        mainTitleButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.equalTo(110)
            make.height.equalTo(24)
        }
        
        myInfoButton.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }
        
        searchButton.snp.makeConstraints { (make) in
            make.right.equalTo(myInfoButton.snp.left).offset(-6)
            make.centerY.equalToSuperview()
            make.size.equalTo(36)
        }
    }

    @objc private func goSearch() {
        let viewcontroller = SearchViewController()
        Utilities.topViewController()?.navigationController?.pushViewController(viewcontroller, animated: true)
    }
    
    @objc private func goMyInfo() {
        let viewcontroller = MyInfoViewController()
        Utilities.topViewController()?.navigationController?.pushViewController(viewcontroller, animated: true)
    }
}
