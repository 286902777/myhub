//
//  ChannelCell.swift
//  MyHub
//
//  Created by myhub-ios on 3/13/26.
//

import UIKit
import SnapKit

class ChannelCell: UICollectionViewCell {
    private lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    private lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#595959")
        label.font = UIFont.GoogleSans(weight: .regular, size: 14)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(self.iconV)
        self.addSubview(self.nameL)
        self.iconV.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(self.iconV.snp.width)
        }
        self.nameL.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.iconV.snp.bottom).offset(4)
        }
    }
    
    func initData(_ data: ChannelUserData) {
        self.iconV.setImage(data.thumbnail, placeholder: "")
        self.nameL.text = data.name
    }
}
