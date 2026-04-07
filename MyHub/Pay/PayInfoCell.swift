//
//  PayInfoCell.swift
//  MyHub
//
//  Created by myhub-ios on 3/27/26.
//

import UIKit
import SnapKit

class PayInfoCell: UICollectionViewCell {
    lazy var mainV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()

    lazy var hotL: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.GoogleSans(size: 12)
        label.textColor = UIColor.rgbHex("#181818")
        label.backgroundColor = UIColor.rgbHex("#CEF700")
        label.text = "Best Choice"
        return label
    }()
    
    lazy var priceL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .bold, size: 20)
        label.textColor = UIColor.rgbHex("#14171C")
        label.textAlignment = .center
        return label
    }()
    
    lazy var typeL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#14171C")
        label.textAlignment = .center
        return label
    }()
    
    lazy var selectV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_sel")
        return view
    }()

    let cellW: CGFloat = floor((ScreenWidth - 44) / 3)

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(self.mainV)
        self.addSubview(self.hotL)
        self.mainV.addSubview(self.typeL)
        self.mainV.addSubview(self.priceL)
        self.addSubview(self.selectV)

        self.mainV.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(6)
            make.right.bottom.equalTo(-2)
        }
        
        self.hotL.snp.makeConstraints { make in
            make.top.left.equalToSuperview()
            make.size.equalTo(CGSize(width: 90, height: 20))
        }
        
        self.typeL.snp.makeConstraints { make in
            make.top.equalTo(34)
            make.left.equalTo(10)
        }
        
        self.priceL.snp.makeConstraints { make in
            make.top.equalTo(self.typeL.snp.bottom).offset(18)
            make.left.equalTo(10)
        }

        self.selectV.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.size.equalTo(CGSize(width: 28, height: 28))
        }

        self.hotL.layoutIfNeeded()
        self.hotL.addRedius([.topLeft, .topRight, .bottomRight], 12, self.hotL.bounds)
    }
    
    func initData(_ data: PayData) {
        if data.isSelect {
            self.selectV.isHidden = false
            self.mainV.layer.borderColor = UIColor.rgbHex("#DDF75B").cgColor
            self.mainV.layer.borderWidth = 2
            self.typeL.textColor = UIColor.rgbHex("#14171C")
        } else {
            self.selectV.isHidden = true
            self.mainV.layer.borderColor = UIColor.rgbHex("#EAEAEA").cgColor
            self.mainV.layer.borderWidth = 2
            self.typeL.textColor = UIColor.rgbHex("#14171C", 0.5)
        }

        self.hotL.isHidden = !data.hot
        self.priceL.text = "\(data.showPrice)"
        self.typeL.text = data.name
    }
}
