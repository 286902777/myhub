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
        view.image = UIImage(named: "video_bg")
        return view
    }()
    
    private lazy var hotV: UIImageView = {
        let view = UIImageView()
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
        self.backgroundColor = .white
        self.layer.cornerRadius = 14
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.rgbHex("#DDF75B").cgColor
        self.layer.masksToBounds = true
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(iconV)
        self.addSubview(hotV)
        self.addSubview(nameV)
        self.nameV.addSubview(self.nameL)
        self.iconV.snp.makeConstraints { make in
            make.top.equalTo(6)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-12)
        }
        self.hotV.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        self.nameV.snp.makeConstraints { make in
            make.left.right.bottom.equalTo(self.iconV)
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


