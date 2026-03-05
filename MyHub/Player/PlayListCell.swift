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
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.white
        label.numberOfLines = 2
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
    
    lazy var recommonedV: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    lazy var recommonedL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 9, weight: .medium)
        label.text = "Recommend"
        label.textAlignment = .center
        label.textColor = UIColor.rgbHex("#FFFFFF")
        return label
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
        self.addSubview(nameL)
        self.imageV.addSubview(self.playingV)
        self.addSubview(recommonedV)
        self.recommonedV.addSubview(recommonedL)
        imageV.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(100)
        }
        nameL.snp.makeConstraints { make in
            make.top.equalTo(imageV.snp.bottom).offset(4)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-4)
        }
        
        playingV.snp.makeConstraints { make in
            make.center.equalTo(imageV)
        }
        
        self.recommonedV.snp.makeConstraints { make in
            make.right.top.equalTo(imageV)
            make.size.equalTo(CGSize(width: 62, height: 15))
        }
        self.recommonedL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        self.recommonedV.addRedius([.topRight, .bottomLeft], 4, CGRectMake(0, 0, 62, 15))
        self.recommonedV.addGradLayer(UIColor.rgbHex("#8D5CED"), UIColor.rgbHex("#C3A4FF"), CGRectMake(0, 0, 62, 15), true)
    }
    
    func initData(_ data: VideoData, _ playing: Bool = false) {
        self.imageV.setImage(data.thumbnail, placeholder: "deep_video_bg")
        self.nameL.text = data.name
        self.playingV.isHidden = !playing
        self.recommonedV.isHidden = !data.recommend
    }
}

