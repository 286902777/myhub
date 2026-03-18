//
//  FileCell.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class FileCell: UITableViewCell {
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
    
    lazy var selectBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "un_sel"), for: .normal)
        btn.setImage(UIImage(named: "sel"), for: .selected)
        return btn
    }()
    
    var selectBlock:((_ on: Bool) -> Void)?

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
        self.mainV.addSubview(stackV)
        self.mainV.addSubview(stackBgV)
        self.stackBgV.addSubview(self.stackV)
        self.stackV.addArrangedSubview(self.stateV)
        self.stackV.addArrangedSubview(self.stateL)
        self.mainV.addSubview(self.selectBtn)

        mainV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 14, bottom: 10, right: 14))
        }
        
        iconV.snp.makeConstraints { make in
            make.left.equalTo(12)
            make.centerY.equalToSuperview()
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
        
        selectBtn.snp.makeConstraints { make in
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
        self.selectBtn.addTarget(self, action: #selector(clickSelAction), for: .touchUpInside)
    }
    
    func initPlatformData(_ model: ChannelData, _ show: Bool) {
        self.selectBtn.isHidden = !show
        self.selectBtn.isSelected = model.isSelect
        switch model.file_type {
        case .folder:
            self.iconV.image = UIImage(named: "folder_bg")
            self.infoL.text = "\(model.vid_qty) Files"
        case .photo:
            self.iconV.setImage(model.file_meta.thumbnail, placeholder: "photo_bg")
            self.infoL.text = model.update_time.dateToYMD()
        case .video:
            self.iconV.setImage(model.file_meta.thumbnail, placeholder: "video_bg")
            self.infoL.text = "\(model.file_meta.size.computeFileSize()) · \(model.update_time.dateToYMD())"
        }
        self.nameL.text = model.fileName
    }

    func initDeepData(_ model: OpenUrlData) {
        self.selectBtn.isHidden = false
        self.selectBtn.isSelected = model.isSelect
        switch model.file_type {
        case .folder:
            self.iconV.image = UIImage(named: "folder_bg")
            self.infoL.text = "\(model.create_time.dateToYMD())"
        case .photo:
            self.iconV.setImage(model.file_meta.thumbnail, placeholder: "photo_bg")
            self.infoL.text = model.create_time.dateToYMD()
        case .video:
            self.iconV.setImage(model.file_meta.thumbnail, placeholder: "video_bg")
            self.infoL.text = "\(model.file_meta.size.computeFileSize()) · \(model.create_time.dateToYMD())"
        }
        self.nameL.text = model.file_meta.display_name
    }
    
    func initFolderData(_ model: FolderData) {
        self.selectBtn.isSelected = model.isSelect
        switch model.file_type {
        case .folder:
            self.selectBtn.isHidden = true
            self.iconV.image = UIImage(named: "folder_bg")
            self.infoL.text = "\(model.vid_qty) Files"
        case .photo:
            self.selectBtn.isHidden = true
            self.iconV.setImage(model.file_meta.thumbnail, placeholder: "photo_bg")
            self.infoL.text = model.update_time.dateToYMD()
        case .video:
            self.selectBtn.isHidden = false
            self.iconV.setImage(model.file_meta.thumbnail, placeholder: "video_bg")
            self.infoL.text = "\(model.file_meta.size.computeFileSize()) · \(model.update_time.dateToYMD())"
        }
        self.nameL.text = model.fileName
    }
    
    func initVideoData(_ model: VideoData) {
        self.selectBtn.isSelected = model.isSelect
        switch model.file_type {
        case .folder:
            self.iconV.image = UIImage(named: "folder_bg")
            self.infoL.text = "\(model.vid_qty) Files"
        case .photo:
            self.iconV.setImage(model.thumbnail, placeholder: "photo_bg")
            self.infoL.text = model.pubData.dateToYMD()
        case .video:
            self.iconV.setImage(model.thumbnail, placeholder: "video_bg")
            self.infoL.text = "\(model.file_size.computeFileSize()) · \(model.pubData.dateToYMD())"
        }
        self.nameL.text = model.name
    }
    
    func initDirData(_ data: VideoData) {
        self.selectBtn.isSelected = data.isSelect
        let hasSize = data.file_size > 0
        switch data.file_type {
        case .folder:
            self.iconV.image = UIImage(named: "folder_bg")
        case .photo:
            self.iconV.setImage(data.thumbnail, placeholder: "photo_bg")
        case .video:
            self.iconV.setImage(data.thumbnail, placeholder: "video_bg")
        }
        if hasSize {
            self.infoL.text = "\(data.file_size.computeFileSize()) · \(data.pubData.dateToYMD())"
        } else {
            self.infoL.text = "\(data.pubData.dateToYMD())"
        }
        self.selectBtn.isHidden = data.isPass != .passed
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
                make.left.equalTo(iconV.snp.right).offset(12)
                make.top.equalTo(self.mainV.snp.centerY).offset(5)
                make.right.equalTo(self.stackBgV.snp.left).offset(-14)
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
                make.left.equalTo(iconV.snp.right).offset(12)
                make.top.equalTo(self.mainV.snp.centerY).offset(5)
                make.right.equalTo(self.stackBgV.snp.left).offset(-14)
            }
            self.stackBgV.layoutIfNeeded()
            self.stackBgV.addRedius([.bottomLeft], 14, self.stackBgV.bounds)
        default:
            self.nameL.snp.remakeConstraints { make in
                make.left.equalTo(iconV.snp.right).offset(12)
                make.bottom.equalTo(self.mainV.snp.centerY).offset(-5)
                make.right.equalTo(self.selectBtn.snp.left).offset(-14)
            }
            self.infoL.snp.remakeConstraints { make in
                make.left.equalTo(iconV.snp.right).offset(12)
                make.top.equalTo(self.mainV.snp.centerY).offset(5)
                make.right.equalTo(self.selectBtn.snp.left).offset(-14)
            }
        }
        self.nameL.text = data.name
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @objc func clickSelAction() {
        self.selectBtn.isSelected = !self.selectBtn.isSelected
        self.selectBlock?(self.selectBtn.isSelected)
    }
}
