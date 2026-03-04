//
//  DeepBottomView.swift
//  MyHub
//
//  Created by Ever on 2026/3/2.
//

import UIKit
import SnapKit

class DeepBottomView: UIView {
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.spacing = 10
        view.axis = .horizontal
        return view
    }()
    
    lazy var playBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Play all", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 16)
        btn.layer.cornerRadius = 22
        btn.backgroundColor = UIColor.rgbHex("#DDF75B")
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var saveBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Save", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 16)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.rgbHex("#14171C").cgColor
        return btn
    }()
    
    lazy var downBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "deep_down"), for: .normal)
        btn.backgroundColor = UIColor.rgbHex("#EAFA81", 0.2)
        btn.layer.cornerRadius = 22
        return btn
    }()
    
    var clickBlock: ((_ idx: Int) -> Void)?
    
    var isChannel: Bool = false {
        didSet {
            if isChannel {
                self.saveBtn.isHidden = true
            }
        }
    }
    
    class func view() -> DeepBottomView {
        let view = DeepBottomView()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.backgroundColor = UIColor.white
        self.addSubview(self.stackV)
        self.stackV.addArrangedSubview(self.downBtn)
        self.stackV.addArrangedSubview(self.saveBtn)
        self.stackV.addArrangedSubview(self.playBtn)
        
        self.stackV.snp.makeConstraints { make in
            make.top.equalTo(10)
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.height.equalTo(44)
        }
        self.downBtn.snp.makeConstraints { make in
            make.width.equalTo(58)
        }
        
        self.saveBtn.snp.makeConstraints { make in
            make.width.equalTo(90)
        }
        self.setNeedsLayout()
        self.addCornerShadow(32, CGSize(width: 0, height: 0), UIColor.rgbHex("#000000", 1), 3)

        self.playBtn.addTarget(self, action: #selector(clickPlayAction), for: .touchUpInside)
        self.saveBtn.addTarget(self, action: #selector(clickSaveAction), for: .touchUpInside)
        self.downBtn.addTarget(self, action: #selector(clickDownAction), for: .touchUpInside)
    }
    
    @objc func clickPlayAction() {
        self.clickBlock?(0)
    }
    
    @objc func clickSaveAction() {
        self.clickBlock?(1)
    }
    
    @objc func clickDownAction() {
        self.clickBlock?(2)
    }
}
