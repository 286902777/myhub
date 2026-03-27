//
//  PayController.swift
//  MyHub
//
//  Created by myhub-ios on 3/27/26.
//

import UIKit
import SnapKit

class PayController: SuperController {
    lazy var stroeBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Restore", for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 12)
        btn.setTitleColor(UIColor.rgbHex("#181818"), for: .normal)
        btn.layer.cornerRadius = 14
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.rgbHex("#181818", 0.5).cgColor
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var bgImgV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "pre_bg")
        return view
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFit
        view.image = UIImage(named: "pre")
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initUI() {
        self.view.addSubview(self.bgImgV)
        self.bgImgV.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        self.navbar.bgView.addSubview(self.stroeBtn)
        self.stroeBtn.snp.makeConstraints { make in
            make.right.equalTo(-16)
            make.size.equalTo(CGSize(width: 68, height: 28))
            make.centerY.equalToSuperview()
        }
        self.stroeBtn.addTarget(self, action: #selector(clickStoreAction), for: .touchUpInside)
        
        self.view.addSubview(self.iconV)
        self.iconV.snp.makeConstraints { make in
            make.right.equalTo(-24)
            make.size.equalTo(CGSize(width: 84, height: 84))
        }
    }
    
    @objc func clickStoreAction() {
        
    }
}
