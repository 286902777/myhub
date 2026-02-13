//
//  UploadAndDownCell.swift
//  MyHub
//
//  Created by Ever on 2026/2/13.
//

import UIKit
import SnapKit

class UploadAndDownCell: UITableViewCell {
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
    
    lazy var stateL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C", 0.5)
        label.font = UIFont.GoogleSans(weight: .regular, size: 10)
        return label
    }()
    
    lazy var speedL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C", 0.5)
        label.font = UIFont.GoogleSans(weight: .regular, size: 10)
        return label
    }()
    
    lazy var progreeV: UIProgressView = {
        let view = UIProgressView()
        view.trackTintColor = UIColor.rgbHex("#000000", 0.06)
        view.progressTintColor = UIColor.rgbHex("#E1F867")
        view.layer.cornerRadius = 1
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 0
        view.axis = .horizontal
        return view
    }()
    
    lazy var failBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "fail"), for: .normal)
        btn.setImage(UIImage(named: "fail"), for: .highlighted)
        btn.setImage(UIImage(named: "fail"), for: .selected)
        return btn
    }()
    
    lazy var delBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "delete_cell"), for: .normal)
        btn.setImage(UIImage(named: "delete_cell"), for: .highlighted)
        btn.setImage(UIImage(named: "delete_cell"), for: .selected)
        return btn
    }()
    
    var failBlock: (() -> Void)?
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
        self.mainV.addSubview(self.stateL)
        self.mainV.addSubview(self.speedL)
        self.mainV.addSubview(self.progreeV)
        self.mainV.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.failBtn)
        self.stackView.addArrangedSubview(self.delBtn)
        self.failBtn.addTarget(self, action: #selector(clickFailAction), for: .touchUpInside)
        self.delBtn.addTarget(self, action: #selector(clickDeletAction), for: .touchUpInside)

        self.mainV.snp.makeConstraints { make in
            make.edges.equalTo(UIEdgeInsets(top: 0, left: 14, bottom: 12, right: 14))
        }
        self.iconV.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(16)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
    
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(16)
            make.top.equalTo(12)
            make.right.equalTo(self.stackView.snp.left).offset(-16)
        }
        self.stateL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(16)
            make.top.equalTo(self.nameL.snp.bottom).offset(8)
        }
        self.speedL.snp.makeConstraints { make in
            make.centerY.equalTo(self.stateL)
            make.right.equalTo(self.progreeV)
        }
        self.progreeV.snp.makeConstraints { make in
            make.left.equalTo(self.nameL)
            make.bottom.equalTo(-12)
            make.height.equalTo(2)
            make.right.equalTo(self.stackView.snp.left).offset(-16)
        }
        self.stackView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.right.equalTo(-4)
        }
        self.failBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40, height: 40))
        }
        self.delBtn.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 40, height: 40))
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
        switch model.state {
        case .uploadFaid:
            self.failBtn.isHidden = false
            self.stateL.text = "Upload failed"
        case .downFail:
            self.failBtn.isHidden = false
            self.stateL.text = "Download failed"
        case .uploading:
            self.failBtn.isHidden = true
            self.stateL.text = "\(model.done_size.computeFileSize())/\(model.size)"
        case .downing:
            self.failBtn.isHidden = true
            self.stateL.text = "\(model.done_size.computeFileSize())/\(model.size)"
        default:
            self.failBtn.isHidden = true
            self.stateL.text = "Waiting…"
        }
        self.stateL.text = ""
        self.nameL.text = model.name
    }
    
    @objc func clickFailAction() {
        self.failBlock?()
    }
    
    @objc func clickDeletAction() {
        self.deleteBlock?()
    }
}
