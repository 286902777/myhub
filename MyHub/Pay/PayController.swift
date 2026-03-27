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
        btn.layer.cornerRadius = 1
        btn.layer.masksToBounds = true
        return btn
    }()
    
    lazy var bgImgV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "pre_bg")
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
    }
}
