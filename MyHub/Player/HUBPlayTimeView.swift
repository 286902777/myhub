//
//  HUBPlayTimeView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class HUBPlayTimeView: UIView {
    lazy var timeL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 24)
        label.textColor = .white
        return label
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(size: 16)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func initUI() {
        self.isHidden = true
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.rgbHex("#000000", 0.5)
        self.addSubview(self.timeL)
        self.addSubview(self.infoL)
        self.timeL.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.centerY.equalToSuperview()
        }
        self.infoL.snp.makeConstraints { make in
            make.left.equalTo(self.timeL.snp.right).offset(8)
            make.right.equalTo(-20)
            make.centerY.equalToSuperview()
        }
    }
    
    func setValue(_ time: String, _ progressTime: String) {
        self.isHidden = false
        self.timeL.text = time
        self.infoL.text = progressTime
        DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }
            self.isHidden = true
        }
    }
}


