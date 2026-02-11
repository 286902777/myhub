//
//  IndexListCell.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class IndexListCell: UITableViewCell {
    lazy var iconV: UIImageView = {
       let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#434343")
        label.numberOfLines = 2
        return label
    }()
    
    lazy var sizeL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(size: 12)
        label.textColor = UIColor.rgbHex("#8C8C8C")
        return label
    }()
    
    lazy var moreBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "more"), for: .normal)
        return btn
    }()
    
    lazy var timeV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor.rgbHex("#14171C", 0.4)
        return view
    }()
    
    lazy var timeL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 12)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    var clickMoreBlock: (() -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .clear
        self.selectionStyle = .none
        self.contentView.backgroundColor = .clear
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.addSubview(self.iconV)
        self.addSubview(self.nameL)
        self.addSubview(self.sizeL)
        self.addSubview(self.moreBtn)
        self.addSubview(self.timeV)
        self.timeV.addSubview(self.timeL)
        self.iconV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 192, height: 108))
            make.bottom.equalTo(-14)
        }
        self.nameL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(14)
            make.right.equalTo(-14)
            make.top.equalTo(12)
        }
        
        self.moreBtn.snp.makeConstraints { make in
            make.right.equalTo(-6)
            make.size.equalTo(CGSize(width: 36, height: 36))
            make.bottom.equalTo(-17)
        }
        
        self.sizeL.snp.makeConstraints { make in
            make.left.equalTo(self.nameL)
            make.bottom.equalTo(-26)
        }
        
        self.timeV.snp.makeConstraints { make in
            make.left.equalTo(22)
            make.bottom.equalTo(-22)
            make.size.equalTo(CGSize(width: 60, height: 20))
        }
        self.timeL.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.moreBtn.addTarget(self, action: #selector(clickMoreAction), for: .touchUpInside)
    }
    
    func initData(_ data: VideoData) {
        self.iconV.setImage(data.thumbnail, placeholder: "video_bg")
        self.sizeL.text = "\(data.size) · \(data.pubData.dateToYMD())"

//        self.moreBtn.isHidden = data.isPass != .passed
//        switch data.isPass {
//        case .initl:
//            self.stateL.text = "Reviewing"
//        case .passed:
//            self.stateL.text = ""
//        case .rejected:
//            self.stateL.text = "Failed"
//        }
        self.nameL.text = data.name
        if data.totalTime > 0 {
            self.timeV.isHidden = false
            self.timeL.text = data.totalTime.timeToHMS()
        } else {
            self.timeV.isHidden = true
        }
    }
    
    @objc func clickMoreAction() {
        self.clickMoreBlock?()
    }
}
