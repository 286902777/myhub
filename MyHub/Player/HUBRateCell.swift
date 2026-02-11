//
//  HUBRateCell.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class HUBRateCell: UITableViewCell {
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#112031")
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.setUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(nameL)
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        nameL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    func initData(_ model: RateData) {
        self.nameL.text = "\(model.name.rawValue)x"
        if model.select {
            self.nameL.textColor = UIColor.rgbHex("#112031")
            self.backgroundColor = UIColor.rgbHex("#FFFFFF")
        } else {
            self.nameL.textColor = UIColor.rgbHex("#FFFFFF", 0.75)
            self.backgroundColor = .clear
        }
    }
}
