//
//  ShareDayCell.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class ShareDayCell: UICollectionViewCell {
    private lazy var levelV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .medium, size: 16)
        return label
    }()
    
    private lazy var selectV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "check")
        return view
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.rgbHex("#FAFAFA")
        self.layer.cornerRadius = 14
        self.layer.masksToBounds = true
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(self.levelV)
        self.addSubview(self.nameL)
        self.addSubview(self.selectV)
        self.levelV.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 10, height: 10))
        }
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.levelV.snp.right).offset(20)
            make.centerY.equalToSuperview()
        }
        self.selectV.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
    
    func initData(_ data: ShareDayData) {
        self.nameL.text = data.name.rawValue
        self.selectV.isHidden = !data.isSelect
        self.levelV.backgroundColor = data.isSelect ? UIColor.rgbHex("#FF7A34") : UIColor.rgbHex("#14171C", 0.12)
    }
}

