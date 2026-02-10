//
//  EmptyView.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

enum Hub_EmptyType: Int {
    case noContent = 0
    case noNet
}

class EmptyView: UIView {
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.GoogleSans(weight: .regular, size: 14)
        label.textColor = UIColor.rgbHex("#434343")
        label.textAlignment = .center
        return label
    }()
    
    lazy var upBtn: UIButton = {
        let btn = UIButton()
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 14)
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.backgroundColor = .white
        btn.layer.borderWidth = 0
        btn.layer.borderColor = UIColor.rgbHex("#14171C").cgColor
        btn.layer.cornerRadius = 20
        btn.layer.masksToBounds = true
        return btn
    }()
    
    var type: Hub_EmptyType = .noContent {
        didSet {
            self.imageV.image = UIImage(named: type == .noContent ? "nocontent" : "nonet")
            self.infoL.text = type == .noContent ? "Add photos and videos." : "No network. Please try again later."
            self.upBtn.setTitle(type == .noContent ? "Upload" : "Retry", for: .normal)
            self.upBtn.layer.borderWidth = type == .noContent ? 0 : 1
            self.upBtn.backgroundColor = type == .noContent ? UIColor.rgbHex("#DDF75B") : UIColor.white
        }
    }
    
    var clickBlock: ((_ type: Hub_EmptyType) -> Void)?
    
    class func view() -> EmptyView {
        let view = EmptyView()
        view.setUI()
        return view
    }
    
    func setUI() {
        self.backgroundColor = .white
        self.addSubview(self.upBtn)
        self.addSubview(self.infoL)
        self.addSubview(self.imageV)
        
        self.imageV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.snp.centerY)
        }
        self.infoL.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.imageV.snp.bottom)
        }
        self.upBtn.snp.makeConstraints { make in
            make.top.equalTo(self.infoL.snp.bottom).offset(16)
            make.size.equalTo(CGSize(width: 120, height: 40))
        }
       
        self.type = .noContent
        self.upBtn.addTarget(self, action: #selector(clickAction), for: .touchUpInside)
    }
    
    @objc func clickAction() {
        self.clickBlock?(self.type)
    }
}
