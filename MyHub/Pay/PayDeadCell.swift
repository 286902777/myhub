//
//  PayDeadCell.swift
//  MyHub
//
//  Created by myhub-ios on 3/29/26.
//

import UIKit
import SnapKit

class PayDeadCell: UITableViewCell {
    lazy var mainV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_deadline")
        return view
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C", 0.75)
        label.font = UIFont.GoogleSans(size: 14)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.setUpUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpUI() {
        self.addSubview(self.mainV)
        self.mainV.addSubview(self.iconV)
        self.mainV.addSubview(self.infoL)
        self.mainV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.top.bottom.equalToSuperview()
            make.height.equalTo(60)
        }
        self.iconV.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        self.infoL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(12)
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
    }
    
    func initData(_ model: PayTableData) {
        self.infoL.text = model.info
    }
}

