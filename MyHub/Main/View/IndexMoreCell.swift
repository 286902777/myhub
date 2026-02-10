//
//  IndexMoreCell.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class IndexMoreCell: UICollectionViewCell {
    private lazy var iconBgV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 34
        view.layer.borderWidth = 1
        return view
    }()
    private lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .regular, size: 12)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.borderColor = UIColor.rgbHex("#DDF75B", 0.5).cgColor
        self.layer.masksToBounds = true
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(iconBgV)
        self.iconBgV.addSubview(iconV)
        self.addSubview(nameL)
        self.iconBgV.snp.makeConstraints { make in
            make.top.equalTo(0)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSizeMake(68, 68))
        }
        self.iconV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSizeMake(20, 20))
        }
        self.nameL.snp.makeConstraints { make in
            make.top.equalTo(self.iconBgV.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
    }
    
    func initData(_ data: HomeMoreData) {
        self.iconV.image = UIImage(named: (data.imageType.rawValue))
        self.nameL.text = data.title
    }
}

