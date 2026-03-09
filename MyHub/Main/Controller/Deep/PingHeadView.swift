//
//  PingHeadView.swift
//  MyHub
//
//  Created by hub on 2026/3/2.
//

import UIKit
import SnapKit

class PingHeadView: UIView {
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
    
    let hotView: DeepHeadView = DeepHeadView.view()
    
    class func view() -> PingHeadView {
        let view = PingHeadView()
        view.setup()
        return view
    }
    
    func setup() {
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 256)
        self.addSubview(iconV)
        self.addSubview(nameL)
        self.iconV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.size.equalTo(CGSize(width: 60, height: 60))
            make.top.equalTo(16)
        }
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(20)
            make.right.equalTo(-14)
            make.centerY.equalTo(self.iconV)
        }
        self.addSubview(hotView)
        hotView.snp.makeConstraints { make in
            make.top.equalTo(self.iconV.snp.bottom).offset(16)
            make.height.equalTo(160)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    func setHeadData(_ data: ChannelListData) {
        self.hotView.hotVC.setDatas(self.changeDataToVideoData(data.hots))
        self.hotView.recentlyVC.setDatas(self.changeDataToVideoData(data.recents))
    }
    
    func changeDataToVideoData(_ list: [ChannelData]) -> [VideoData] {
        
    }
}
