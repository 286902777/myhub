//
//  BoxDeepListHeadView.swift
//  MyHub
//
//  Created by hub on 2026/3/2.
//

import UIKit
import SnapKit

class BoxDeepListHeadView: UIView {
    lazy var backBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "back"), for: .normal)
        btn.addTarget(self, action: #selector(clickBackAction), for: .touchUpInside)
        return btn
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .bold, size: 18)
        label.textAlignment = .center
        return label
    }()
    
    lazy var allBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Select all", for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 12)
        btn.setTitleColor(UIColor.rgbHex("#14171C", 0.5), for: .normal)
        btn.addTarget(self, action: #selector(clickAllAction), for: .touchUpInside)
        return btn
    }()
    
    var clickBlock: ((_ idx: Int) -> Void)?
    
    class func view() -> BoxDeepListHeadView {
        let view = BoxDeepListHeadView()
        view.setup()
        return view
    }
    
    func setup() {
        self.addSubview(backBtn)
        self.addSubview(nameL)
        self.addSubview(allBtn)
        self.backBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 52, height: 52))
            make.centerY.left.equalToSuperview()
        }
        self.allBtn.snp.makeConstraints { make in
            make.width.equalTo(78)
            make.top.bottom.equalToSuperview()
            make.right.equalTo(-14)
        }
        self.nameL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(self.backBtn.snp.right)
            make.right.equalTo(self.allBtn.snp.left)
        }
    }
    
    func setDeepHeadData(_ data: OpenUserData) {
        self.nameL.text = data.username
    }
    
    @objc func clickBackAction() {
        self.clickBlock?(0)
    }
    
    @objc func clickAllAction() {
        self.clickBlock?(1)
    }
}

