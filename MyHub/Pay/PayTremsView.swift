//
//  PayTremsView.swift
//  MyHub
//
//  Created by myhub-ios on 3/30/26.
//

import UIKit
import SnapKit

class PayTremsView: UIView {
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.spacing = 8
        view.axis = .horizontal
        return view
    }()
    
    lazy var termsL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000", 0.25)
        label.textAlignment = .center
        label.text = "Terms of Service"
        label.font = UIFont.GoogleSans(size: 12)
        return label
    }()
    
    lazy var pointL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000", 0.25)
        label.textAlignment = .center
        label.text = "·"
        label.font = UIFont.GoogleSans(size: 12)
        return label
    }()
    
    lazy var policyL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000", 0.25)
        label.textAlignment = .center
        label.font = UIFont.GoogleSans(size: 12)
        label.text = "Privacy Policy"
        return label
    }()
    
    var clickBlock: ((_ idx: Int) -> Void)?
    
    class func view() -> PayTremsView {
        let view = PayTremsView()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.backgroundColor = UIColor.rgbHex("#FFFFFF")
        self.addSubview(self.stackV)
        self.stackV.addArrangedSubview(self.termsL)
        self.stackV.addArrangedSubview(self.pointL)
        self.stackV.addArrangedSubview(self.policyL)
        
        self.stackV.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
            make.top.equalTo(8)
            make.height.equalTo(28)
        }
        let tTap = UITapGestureRecognizer(target: self, action: #selector(clickTermsAction))
        self.termsL.isUserInteractionEnabled = true
        self.termsL.addGestureRecognizer(tTap)
        let pTap = UITapGestureRecognizer(target: self, action: #selector(clickPolicyAction))
        self.policyL.isUserInteractionEnabled = true
        self.policyL.addGestureRecognizer(pTap)
    }

    @objc func clickTermsAction() {
        self.clickBlock?(0)
    }
    
    @objc func clickPolicyAction() {
        self.clickBlock?(1)
    }
}
