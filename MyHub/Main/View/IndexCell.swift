//
//  IndexCell.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class IndexCell: UITableViewCell {
    lazy var mainV: UIView = {
       let view = UIView()
        view.layer.cornerRadius = 14
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        view.layer.masksToBounds = true
        return view
    }()
    lazy var iconV: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 6
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#141414")
        return label
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .regular, size: 12)
        label.textColor = UIColor.rgbHex("#8C8C8C")
        return label
    }()
    
    lazy var stackBgV: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.spacing = 4
        view.axis = .horizontal
        return view
    }()
    
    lazy var stateV: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var stateL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 10)
        return label
    }()
    
    lazy var moreBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "more"), for: .normal)
        return btn
    }()
    
    var clickMoreBlock:(() -> Void)?

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
        self.mainV.addSubview(iconV)
        self.mainV.addSubview(nameL)
        self.mainV.addSubview(infoL)
        self.mainV.addSubview(stackBgV)
        self.mainV.addSubview(self.moreBtn)

        self.stackBgV.addSubview(stackV)
        self.stackV.addArrangedSubview(self.stateV)
        self.stackV.addArrangedSubview(self.stateL)

        mainV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 14, bottom: 10, right: 14))
        }
        
        iconV.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.size.equalTo(CGSize(width: 44, height: 44))
        }
        
        stackBgV.snp.makeConstraints { make in
            make.top.right.equalToSuperview()
            make.height.equalTo(28)
        }
        stackV.snp.makeConstraints { make in
            make.left.equalTo(6)
            make.right.equalTo(-6)
            make.centerY.equalToSuperview()
            make.height.equalTo(18)
        }
        
        stateV.snp.makeConstraints { make in
            make.width.equalTo(18)
        }
        
        moreBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 44, height: 44))
            make.right.centerY.equalToSuperview()
        }
        
        nameL.snp.makeConstraints { make in
            make.left.equalTo(iconV.snp.right).offset(12)
            make.right.equalTo(stackBgV.snp.left)
            make.bottom.equalTo(self.mainV.snp.centerY).offset(-5)
        }
        infoL.snp.makeConstraints { make in
            make.left.equalTo(iconV.snp.right).offset(12)
            make.right.equalTo(stackBgV.snp.left)
            make.top.equalTo(self.mainV.snp.centerY).offset(5)
        }
        self.moreBtn.addTarget(self, action: #selector(clickMoreAction), for: .touchUpInside)
    }
    
    func initData(_ data: VideoData) {
        switch data.file_type {
        case .folder:
            self.iconV.setImage("folder_bg")
            self.infoL.text = "\(data.vid_qty) Files"
        case .photo:
            self.iconV.setImage(data.thumbnail, placeholder: "photo_bg")
            self.infoL.text = data.pubData.dateToYMD()
        case .video:
            self.iconV.setImage(data.thumbnail, placeholder: "video_bg")
            self.infoL.text = "\(data.size) · \(data.pubData.dateToYMD())"
        }
        self.moreBtn.isHidden = data.isPass != .passed
        self.stackBgV.isHidden = data.isPass == .passed
        switch data.isPass {
        case .initl:
            self.stateL.text = "Reviewing"
            self.stateL.textColor = UIColor.rgbHex("#FF7A34")
            self.stateV.image = UIImage(named: "initl")
            self.stackBgV.backgroundColor = UIColor.rgbHex("#FF7A34", 0.1)
            self.nameL.snp.remakeConstraints { make in
                make.left.equalTo(iconV.snp.right).offset(12)
                make.bottom.equalTo(self.mainV.snp.centerY).offset(-5)
                make.right.equalTo(self.stackBgV.snp.left).offset(-14)
            }
            self.infoL.snp.remakeConstraints { make in
                make.right.equalTo(self.stackBgV.snp.left).offset(-14)
                make.left.equalTo(iconV.snp.right).offset(12)
                make.top.equalTo(self.mainV.snp.centerY).offset(5)
            }
            self.stackBgV.layoutIfNeeded()
            self.stackBgV.addRedius([.bottomLeft], 14, self.stackBgV.bounds)
        case .rejected:
            self.stateL.text = "Review filed"
            self.stateL.textColor = UIColor.rgbHex("#FF1A75")
            self.stateV.image = UIImage(named: "rejected")
            self.stackBgV.backgroundColor = UIColor.rgbHex("#FF1A75", 0.1)
            self.nameL.snp.remakeConstraints { make in
                make.left.equalTo(iconV.snp.right).offset(12)
                make.bottom.equalTo(self.mainV.snp.centerY).offset(-5)
                make.right.equalTo(self.stackBgV.snp.left).offset(-14)
            }
            self.infoL.snp.remakeConstraints { make in
                make.right.equalTo(self.stackBgV.snp.left).offset(-14)
                make.left.equalTo(iconV.snp.right).offset(12)
                make.top.equalTo(self.mainV.snp.centerY).offset(5)
            }
            self.stackBgV.layoutIfNeeded()
            self.stackBgV.addRedius([.bottomLeft], 14, self.stackBgV.bounds)
        default:
            self.nameL.snp.remakeConstraints { make in
                make.left.equalTo(iconV.snp.right).offset(12)
                make.bottom.equalTo(self.mainV.snp.centerY).offset(-5)
                make.right.equalTo(self.moreBtn.snp.left).offset(-14)
            }
            self.infoL.snp.remakeConstraints { make in
                make.left.equalTo(iconV.snp.right).offset(12)
                make.top.equalTo(self.mainV.snp.centerY).offset(5)
                make.right.equalTo(self.moreBtn.snp.left).offset(-14)
            }
        }
        self.nameL.text = data.name
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func clickMoreAction() {
        self.clickMoreBlock?()
    }
}
