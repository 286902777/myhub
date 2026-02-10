//
//  SaveCell.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class SaveCell: UICollectionViewCell {
    private lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "folder_bg")
        return view
    }()
    
    private lazy var subNameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#8C8C8C")
        label.font = UIFont.GoogleSans(weight: .regular, size: 12)
        label.textAlignment = .center
        label.text = "Shared by"
        return label
    }()
    
    private lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 14
        self.layer.borderWidth = 1
        self.layer.borderColor = UIColor.rgbHex("#DDF75B", 0.12).cgColor
        self.layer.masksToBounds = true
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(iconV)
        self.addSubview(subNameL)
        self.addSubview(nameL)
        self.iconV.snp.makeConstraints { make in
            make.top.equalTo(28)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSizeMake(44, 44))
        }
        self.subNameL.snp.makeConstraints { make in
            make.top.equalTo(self.iconV.snp.bottom).offset(24)
            make.left.right.equalToSuperview()
        }
        self.nameL.snp.makeConstraints { make in
            make.top.equalTo(self.nameL.snp.bottom).offset(6)
            make.left.right.equalToSuperview()
        }
    }
    
    func initData(_ model: VideoData) {
        self.nameL.text = model.name
    }
}

