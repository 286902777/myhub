//
//  IndexHeadView.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class IndexHeadView: UIView {
    let circleV: CircleProgress = CircleProgress()
    
    let contentV: UIView = UIView()
    
    let userV: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 15
        return view
    }()
    
    let userNameL: UILabel = {
        let label = UILabel()
        label.text = "MyHub"
        label.textColor = .white
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        return label
    }()
    
    class func view() -> IndexHeadView {
        let view = IndexHeadView()
        view.setup()
        return view
    }
    
    func setup() {
        self.backgroundColor = .clear
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 140)
        addSubview(self.contentV)
        self.contentV.layer.cornerRadius = 20
        self.contentV.backgroundColor = UIColor.rgbHex("#14171C")
        self.contentV.addSubview(self.userV)
        self.contentV.addSubview(self.userNameL)
        self.contentV.addSubview(self.circleV)
        self.contentV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14).priority(.high)
            make.top.equalToSuperview()
            make.bottom.equalTo(-12)
        }
        self.userV.snp.makeConstraints { make in
            make.left.top.equalTo(16)
            make.size.equalTo(CGSize(width: 30, height: 30))
        }
        
        self.userNameL.snp.makeConstraints { make in
            make.bottom.equalTo(-16)
            make.left.equalTo(16)
        }
        
        self.circleV.snp.makeConstraints { make in
            make.right.equalTo(-26)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 104, height: 104))
        }
    }
    
    func setData() {
        self.circleV.useLabel.text = "100MB"
        self.circleV.totalLabel.text = "/500MB"
        self.circleV.ratio = 100 / 500
    }
}
