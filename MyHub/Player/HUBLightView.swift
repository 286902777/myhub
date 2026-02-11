//
//  HUBLightView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class HUBLightView: UIView {
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var proV: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = UIColor.rgbHex("#FFFFFF", 0.4)
        view.progressTintColor = UIColor.rgbHex("#FFFFFF")
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.isHidden = true
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.rgbHex("#000000", 0.5)
        self.addSubview(self.iconV)
        self.addSubview(self.proV)
        self.iconV.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        self.proV.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(8)
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
            make.height.equalTo(4)
        }
    }
    
    func setValue(_ light: Bool = true, _ value: Float) {
        self.isHidden = false
        self.iconV.setImage(light ? "play_light" : "play_sound")
        self.proV.progress = value
    }
}

