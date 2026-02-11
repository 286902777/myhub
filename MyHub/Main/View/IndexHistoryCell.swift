//
//  IndexHistoryCell.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class IndexHistoryCell: UICollectionViewCell {
    private lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    }()
    
    private lazy var bgView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#14171C", 0.25)
        return view
    }()
    
    private lazy var nameL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.setUI()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.addSubview(iconV)
        self.addSubview(bgView)
        self.bgView.addSubview(nameL)
        self.iconV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        self.bgView.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.left.bottom.right.equalToSuperview()
        }
        self.nameL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(10)
            make.right.equalTo(-10)
        }
     }
    
    func initData(_ model: VideoData) {
        self.iconV.setImage(model.thumbnail)
        self.nameL.text = model.name
    }
}
