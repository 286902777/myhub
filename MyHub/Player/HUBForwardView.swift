//
//  HUBForwardView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class HUBForwardView: UIView {
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        return view
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUI() {
        self.isHidden = true
        self.layer.cornerRadius = 16
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.rgbHex("#000000", 0.5)
        self.addSubview(self.iconV)
        self.addSubview(self.infoL)
        self.iconV.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        self.infoL.snp.makeConstraints { make in
            make.left.equalTo(self.iconV.snp.right).offset(8)
            make.right.equalTo(-16)
            make.centerY.equalToSuperview()
        }
    }
    
    func setValue(_ forward: Bool) {
        self.isHidden = false
        self.iconV.setImage(forward ? "play_forward" : "play_rewind")
        self.infoL.text = forward ? "Forward 10s" : "Rewind 10s"
        if self.isHidden == false {
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 1.0) { [weak self] in
                guard let self = self else { return }
                self.isHidden = true
            }
        }
    }
}


