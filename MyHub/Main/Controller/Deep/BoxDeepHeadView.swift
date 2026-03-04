//
//  BoxDeepHeadView.swift
//  MyHub
//
//  Created by Ever on 2026/3/2.
//

import UIKit
import SnapKit

class BoxDeepHeadView: UIView {
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 24
        return view
    }()
    
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        view.spacing = 4
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .medium, size: 16)
        return label
    }()
    
    lazy var allL: UILabel = {
        let label = UILabel()
        label.text = "View all"
        label.textColor = UIColor.rgbHex("#14171C", 0.5)
        label.font = UIFont.GoogleSans(weight: .medium, size: 12)
        return label
    }()
    
    lazy var arrowV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "enter")
        return view
    }()
    
    lazy var lineL: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.rgbHex("#000000", 0.05)
        return label
    }()
    
    var clickBlock: (() -> Void)?
    
    class func view() -> BoxDeepHeadView {
        let view = BoxDeepHeadView()
        view.setup()
        return view
    }
    
    func setup() {
        self.addSubview(iconV)
        self.addSubview(nameL)
        self.addSubview(stackV)
        self.addSubview(lineL)
        self.stackV.addArrangedSubview(self.allL)
        self.stackV.addArrangedSubview(self.arrowV)
        self.stackV.isHidden = true
        iconV.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.left.equalTo(14)
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        
        stackV.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.centerY.equalTo(iconV)
            make.size.equalTo(CGSize(width: 56, height: 20))
        }
        
        nameL.snp.makeConstraints { make in
            make.centerY.equalTo(iconV)
            make.left.equalTo(self.iconV.snp.right).offset(16)
            make.right.equalTo(self.stackV.snp.left).offset(-16)
        }
        
        lineL.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(1)
            make.left.equalTo(14)
        }
        
//        let tap = UITapGestureRecognizer(target: self, action: #selector(clickHeadAction))
//        self.addGestureRecognizer(tap)
    }
    
    func setDeepHeadData(_ data: OpenUserData) {
        self.iconV.setImage(data.avtar_url, placeholder: "")
        self.nameL.text = data.username
    }
    
    @objc func clickHeadAction() {
        self.clickBlock?()
    }
}
