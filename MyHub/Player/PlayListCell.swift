//
//  PlayListCell.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class PlayListCell: UITableViewCell {
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = UIColor.white
        return label
    }()
    
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 4
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var playingV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "play_playing")
        return view
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.rgbHex("#FFFFFF", 0.75)
        return label
    }()

    lazy var recommonedV: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    lazy var recommonedL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        label.textAlignment = .center
        label.textColor = UIColor.rgbHex("#FFFFFF")
        label.text = "Recommend"
        return label
    }()
    
    lazy var timeV: UIView = {
       let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#000000", 0.5)
        return view
    }()
    
    lazy var timeL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.rgbHex("#FFFFFF")
        return label
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
        self.addSubview(imageV)
        self.addSubview(nameL)
        self.addSubview(infoL)
        self.imageV.addSubview(self.playingV)
        self.imageV.addSubview(timeV)
        self.timeV.addSubview(timeL)
        self.addSubview(self.recommonedV)
        self.recommonedV.addSubview(self.recommonedL)
        imageV.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.top.equalTo(10)
            make.bottom.equalTo(-10)
            make.width.equalTo(112)
        }
        nameL.snp.makeConstraints { make in
            make.top.equalTo(imageV.snp.top).offset(4)
            make.left.equalTo(imageV.snp.right).offset(12)
            make.right.equalTo(-12)
        }
        
        infoL.snp.makeConstraints { make in
            make.bottom.equalTo(imageV.snp.bottom).offset(-4)
            make.left.equalTo(imageV.snp.right).offset(12)
            make.right.equalTo(-12)
        }
        
        playingV.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
        }
        
        timeV.snp.makeConstraints { make in
            make.right.bottom.equalToSuperview()
            make.height.equalTo(14)
        }
        
        timeL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(4)
            make.right.equalTo(-4)
        }
        self.recommonedV.snp.makeConstraints { make in
            make.right.top.equalTo(imageV)
            make.size.equalTo(CGSize(width: 62, height: 15))
        }
        self.recommonedL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.recommonedV.addGradLayer(UIColor.rgbHex("#8D5CED"), UIColor.rgbHex("#C3A4FF"), CGRectMake(0, 0, 62, 15), true)
        self.recommonedV.addRedius([.topRight, .bottomLeft], 4, CGRectMake(0, 0, 62, 15))
    }
    
    func initData(_ data: VideoData, _ playing: Bool = false) {
        self.imageV.setImage(data.thumbnail, placeholder: "play_video_cell")
        self.nameL.text = data.name
        self.infoL.text = "\(data.size) · \(data.pubData.dateToYMD())"
        self.playingV.isHidden = !playing
        if data.totalTime > 0 {
            self.timeV.isHidden = false
            self.timeL.text = data.totalTime.timeToHHMMSS()
        } else {
            self.timeV.isHidden = true
        }
        self.recommonedV.isHidden = !data.recommend
        self.timeV.layoutIfNeeded()
        self.timeV.addRedius([.topLeft, .bottomRight], 4, self.timeV.bounds)
    }
}
