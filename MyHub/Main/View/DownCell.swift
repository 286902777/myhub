//
//  DownCell.swift
//  MyHub
//
//  Created by Ever on 2026/2/13.
//

import UIKit
import SnapKit

class DownCell: UITableViewCell {
    lazy var mainV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        return label
    }()
    
    lazy var sizeL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C", 0.5)
        label.font = UIFont.GoogleSans(weight: .regular, size: 10)
        return label
    }()
    
    lazy var delBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "delete_cell"), for: .normal)
        btn.setImage(UIImage(named: "delete_cell"), for: .highlighted)
        btn.setImage(UIImage(named: "delete_cell"), for: .selected)
        return btn
    }()
    
    var deleteBlock: (() -> Void)?
    
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
        self.mainV.addSubview(self.sizeL)
        self.mainV.addSubview(self.delBtn)
        self.delBtn.addTarget(self, action: #selector(clickDeletAction), for: .touchUpInside)
        self.mainV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 14, bottom: 12, right: 14))
        }
        self.iconV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        self.delBtn.snp.makeConstraints { make in
            make.centerY.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 48, height: 48))
        }
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(16)
            make.top.equalTo(16)
            make.right.equalTo(self.delBtn.snp.left).offset(-4)
        }
        self.sizeL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(16)
            make.bottom.equalTo(-16)
            make.right.equalTo(self.delBtn.snp.left).offset(-4)
        }
    }
    
    func initData(_ model: VideoData) {
        if let img = model.image {
            self.iconV.image = img
        } else {
            if model.file_type == .video {
                self.iconV.setImage(model.thumbnail, placeholder: "video_bg")
            } else {
                self.iconV.setImage(model.thumbnail, placeholder: "photo_bg")
            }
        }
        self.sizeL.text = model.size
        self.nameL.text = model.name
    }
    
    @objc func clickDeletAction() {
        self.deleteBlock?()
    }
}
