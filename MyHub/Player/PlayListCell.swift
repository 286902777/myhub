//
//  PlayListCell.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class PlayListCell: UICollectionViewCell {
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.white
	        return label
    }()
    
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var playingV: UIView = {
        let view = UIView()
        let imageV = UIImageView()
        view.backgroundColor = UIColor.rgbHex("#DDF75B")
        imageV.contentMode = .scaleAspectFill
        imageV.image = UIImage(named: "play_playing")
        view.addSubview(imageV)
        imageV.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        return view
    }()
    
    lazy var nameBgV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#14171C", 0.25)
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(imageV)
        self.addSubview(nameBgV)
        self.nameBgV.addSubview(nameL)
        self.addSubview(self.playingV)
        imageV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        nameBgV.snp.makeConstraints { make in
            make.left.bottom.right.equalToSuperview()
            make.height.equalTo(28)
        }
        nameL.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.right.equalTo(-8)
            make.centerY.equalToSuperview()
        }
        
        playingV.snp.makeConstraints { make in
            make.left.top.equalToSuperview()
            make.size.equalTo(CGSize(width: 36, height: 36))
        }

        playingV.layoutIfNeeded()
        nameBgV.layoutIfNeeded()
        playingV.addRedius([.topLeft, .bottomRight], 16, self.playingV.bounds)
        nameBgV.addRedius([.bottomLeft, .bottomRight], 16, self.nameBgV.bounds)
    }
    
    func initData(_ data: VideoData) {
        self.imageV.setImage(data.thumbnail, placeholder: "deep_video_bg")
        self.nameL.text = data.name
        self.playingV.isHidden = !data.isSelect
    }
}

