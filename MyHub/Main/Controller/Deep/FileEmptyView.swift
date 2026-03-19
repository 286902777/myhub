//
//  FileEmptyView.swift
//  MyHub
//
//  Created by myhub-ios on 3/18/26.
//

import Foundation
import SnapKit

class FileEmptyView: UIView {
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "nocontent")
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = UIFont.GoogleSans(weight: .regular, size: 14)
        label.textColor = UIColor.rgbHex("#434343")
        label.text = "Link has no content"
        label.textAlignment = .center
        return label
    }()
        
    class func view() -> FileEmptyView {
        let view = FileEmptyView()
        view.setUI()
        return view
    }
    
    func setUI() {
        self.backgroundColor = .white
        self.isHidden = true
        self.addSubview(self.infoL)
        self.addSubview(self.imageV)
        
        self.infoL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.imageV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.infoL.snp.top)
        }
    }
}
