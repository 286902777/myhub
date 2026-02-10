//
//  ShareCopyController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class ShareCopyController: UIViewController {
    lazy var contentV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()	
    
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "share_bg")
        return view
    }()
    
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 18)
        label.textColor = UIColor.rgbHex("#14171C")
        label.text = "Copy completed"
        return label
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        label.attributedText = NSAttributedString(string: "Copy completed. Please ensure the shared content is legal, complies with all regulations, and does not include illegal or infringing material. Any violations will result in content removal and possible account suspension.", attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.GoogleSans(weight: .regular, size: 14), .foregroundColor: UIColor.rgbHex("#14171C")])
        return label
    }()
    
    lazy var okBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("OK", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.rgbHex("#DDF75B")
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 16)
        return btn
    }()
         
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
            
    var url: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        let p = UIPasteboard.general
        p.string = self.url
    }

    func setUI() {
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.contentV.addRedius([.topLeft, .topRight], 12)
        self.okBtn.titleLabel?.font = UIFont.GoogleSans(weight: .regular, size: 14)
        self.view.addSubview(self.contentV)
        self.view.addSubview(self.imageV)
        self.view.addSubview(self.closeBtn)
        self.contentV.addSubview(self.titleL)
        self.contentV.addSubview(self.infoL)
        self.contentV.addSubview(self.okBtn)

        self.contentV.snp.makeConstraints { make in
            make.left.right.bottom.equalToSuperview()
        }
        
        self.imageV.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 147, height: 80))
        }
        
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.imageV.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }
 
        self.titleL.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(16)
            make.right.equalTo(-16)
        }
        self.infoL.snp.makeConstraints { make in
            make.top.equalTo(self.titleL.snp.bottom).offset(24)
            make.left.equalTo(14)
            make.right.equalTo(-14)
        }
        self.okBtn.snp.makeConstraints { make in
            make.top.equalTo(self.infoL.snp.bottom).offset(28)
            make.left.equalTo(16)
            make.right.equalTo(-16)
            make.height.equalTo(44)
            make.bottom.equalTo(-(BottomSafeH + 16))
        }
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)
        self.okBtn.addTarget(self, action: #selector(clickOkAction), for: .touchUpInside)
    }
    
    @objc func clickOkAction() {
        ToastTool.instance.show("Employ MyHub to streamline sharing and management of your records.")
        self.dismiss(animated: false)
    }
    
    @objc func clickCloseAction() {
        self.dismiss(animated: false)
    }
}
