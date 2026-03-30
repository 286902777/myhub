//
//  PayVipBottomV.swift
//  MyHub
//
//  Created by myhub-ios on 3/29/26.
//

import UIKit
import SnapKit

class PayVipBottomV: UIView {
    lazy var priceL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000")
        label.textAlignment = .center
        label.font = UIFont.GoogleSans(size: 10)
        label.numberOfLines = 0
        return label
    }()
    
    lazy var nextBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Continue ", for: .normal)
        btn.setImage(UIImage(named: "pre_enter"), for: .normal)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 16)
        btn.backgroundColor = UIColor.rgbHex("#DDF75B")
        btn.semanticContentAttribute = .forceRightToLeft
        return btn
    }()
    
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
    
    class func view() -> PayVipBottomV {
        let view = PayVipBottomV()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.backgroundColor = UIColor.rgbHex("#FFFFFF")
        self.addSubview(self.priceL)
        self.addSubview(self.nextBtn)
        self.addSubview(self.stackV)
        self.stackV.addArrangedSubview(self.termsL)
        self.stackV.addArrangedSubview(self.pointL)
        self.stackV.addArrangedSubview(self.policyL)
        self.priceL.snp.makeConstraints { make in
            make.left.equalTo(28)
            make.top.equalTo(8)
            make.right.equalTo(-28)
        }
        
        self.nextBtn.snp.makeConstraints { make in
            make.left.equalTo(28)
            make.right.equalTo(-28)
            make.top.equalTo(self.priceL.snp.bottom).offset(4)
            make.height.equalTo(44)
        }
        
        self.stackV.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(self.nextBtn.snp.bottom).offset(8)
            make.height.equalTo(28)
            make.bottom.equalTo(-BottomSafeH)
        }
        let tTap = UITapGestureRecognizer(target: self, action: #selector(clickTermsAction))
        self.termsL.isUserInteractionEnabled = true
        self.termsL.addGestureRecognizer(tTap)
        let pTap = UITapGestureRecognizer(target: self, action: #selector(clickPolicyAction))
        self.policyL.isUserInteractionEnabled = true
        self.policyL.addGestureRecognizer(pTap)
        
        self.nextBtn.addTarget(self, action: #selector(clickNextAction), for: .touchUpInside)
        
        self.setNeedsLayout()
        self.addCornerShadow(24, CGSize(width: 0, height: 0), UIColor.rgbHex("#000000", 0.5), 3)    }

    func setData(_ data: PayData) {
        switch PayID(rawValue: data.product_id) {
        case .weak:
            self.priceL.text = "Automatic renewal at \(data.fu)\(data.price) weekly. Cancel anytime."
        case .year:
            self.priceL.text = "Automatic renewal at \(data.fu)\(data.price) annually. Cancel anytime."
        default:
            self.priceL.text = "Valid for life after purchase, no renewal required"
        }
    }
    
    @objc func clickTermsAction() {
        self.clickBlock?(0)
    }
    
    @objc func clickPolicyAction() {
        self.clickBlock?(1)
    }
    
    @objc func clickNextAction() {
        self.clickBlock?(2)
    }
}
