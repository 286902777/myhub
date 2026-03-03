//
//  BoxPingHeadView.swift
//  MyHub
//
//  Created by Ever on 2026/3/2.
//

import UIKit
import SnapKit

class BoxPingHeadView: UIView {
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 30
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .medium, size: 20)
        return label
    }()
    
    class func view() -> BoxPingHeadView {
        let view = BoxPingHeadView()
        view.setup()
        return view
    }
    
    func setup() {
        self.addSubview(iconV)
        self.addSubview(nameL)
        self.iconV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.centerY.equalToSuperview()
        }
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(20)
            make.right.equalTo(-14)
            make.centerY.equalTo(self.iconV)
        }
    }
}
