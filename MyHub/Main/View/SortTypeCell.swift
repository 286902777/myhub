//
//  SortTypeCell.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

enum HUB_SortType: String {
    case upload = "alert_upload"
    case size = "alert_size"
    case type = "alert_type"
}

class SortTypeCell: UITableViewCell {
    private lazy var mainV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()
    
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
        self.mainV.addSubview(self.levelV)
        self.mainV.addSubview(self.nameL)
        self.mainV.addSubview(self.selectV)
        self.mainV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 14, bottom: 8, right: 14))
        }
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
    
    func initData(_ data: SortData) {
        self.nameL.text = data.name
        self.selectV.isHidden = !data.select
        self.levelV.backgroundColor = data.select ? UIColor.rgbHex("#FF7A34") : UIColor.rgbHex("#14171C", 0.12)
    }
}

class SortData: SuperData {
    var name: String = ""
    var type: HUB_SortType = .upload
    var ascending: Bool = false
    var select: Bool = false
}

class SortListData: SuperData {
    var name: String = ""
    var isType: Bool = false
    var list: [SortData] = []
}

