//
//  PayBenefitsCell.swift
//  MyHub
//
//  Created by myhub-ios on 3/27/26.
//

import UIKit
import SnapKit

class PayBenefitsCell: UITableViewCell {
    lazy var mainV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        view.layer.cornerRadius = 12
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C", 0.75)
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
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
        self.mainV.addSubview(self.nameL)
  
        self.mainV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(-8)
            make.top.equalToSuperview()
            make.height.equalTo(60)
        }
        self.iconV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(16)
            make.centerY.equalToSuperview()
            make.right.equalTo(-12)
        }
    }
    
    func initData(_ model: PayBenefitsData) {
        self.iconV.image = UIImage(named: model.imageType.rawValue)
        switch model.imageType {
        case .ad:
            self.nameL.text = "Enjoy an ad-free experience"
        case .down:
            self.nameL.text = "Accelerated Download"
        case .video:
            self.nameL.text = "Video Accelerator"
        }
    }
}

enum PayBenefitsImageType: String {
    case ad = "pre_ad"
    case down = "pre_download"
    case video = "pre_play"
}

class PayBenefitsData: SuperData {
    var imageType: PayBenefitsImageType = .ad
    
    init(imageType: PayBenefitsImageType) {
        self.imageType = imageType
    }
    
    required init() {
        fatalError("init() has not been implemented")
    }
}
