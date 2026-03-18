//
//  DeepHotCell.swift
//  MyHub
//
//  Created by Ever on 2026/3/5.
//

import UIKit
import SnapKit

class DeepHotCell: UICollectionViewCell {
    private lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.image = UIImage(named: "video_bg")
        return view
    }()
    
    private lazy var hotV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "hot_icon")
        return view
    }()
    
    private lazy var nameV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#14171C", 0.25)
        return view
    }()
    
    private lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#FFFFFF")
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(iconV)
        self.addSubview(hotV)
        self.iconV.addSubview(nameV)
        self.nameV.addSubview(self.nameL)
        self.iconV.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-12)
        }
        self.hotV.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 49, height: 22))
        }
        self.nameV.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(32)
        }
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.centerY.equalToSuperview()
        }
    }
    
    func initData(_ model: ChannelData, _ isHot: Bool = false) {
        self.hotV.isHidden = !isHot
        self.iconV.setImage(model.file_meta.thumbnail, placeholder: "deep_video_bg")
        self.nameL.text = model.fileName
    }
}


