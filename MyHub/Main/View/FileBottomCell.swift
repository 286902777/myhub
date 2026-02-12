//
//  FileBottomCell.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

enum HUB_FileBottomType: String {
    case download = "down"
    case share = "share"
    case delete = "delete"
    case rename = "rename"
    case disName = "un_rename"
}

class FileBottomData: SuperData {
    var imageType: HUB_FileBottomType = .download
    var isAble: Bool = false
    var title: String = ""
}


class FileBottomCell: UICollectionViewCell {
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
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.backgroundColor = .clear
        self.addSubview(iconV)
        self.addSubview(nameL)
        self.iconV.snp.makeConstraints { make in
            make.top.equalTo(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSizeMake(20, 20))
        }
        self.nameL.snp.makeConstraints { make in
            make.top.equalTo(self.iconV.snp.bottom).offset(12)
            make.left.right.equalToSuperview()
        }
    }
    
    func initData(_ data: FileBottomData) {
        self.iconV.image = UIImage(named: data.imageType.rawValue)
        self.nameL.textColor = data.isAble ? UIColor.rgbHex("#14171C") : UIColor.rgbHex("#14171C", 0.25)
        self.nameL.text = data.title
    }
}


