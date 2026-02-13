//
//  AccountController.swift
//  MyHub
//
//  Created by Ever on 2026/2/13.
//

import UIKit
import SnapKit

class AccountController: SuperController {
    lazy var imageV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pic")
        return view
    }()
    lazy var riskL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .medium, size: 20)
        label.textAlignment = .center
        label.text = "Risks are outlined as follows"
        return label
    }()
    
    lazy var infoV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 20
        view.backgroundColor = UIColor.rgbHex("#D9F15F", 0.1)
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var agreeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "un_sel"), for: .normal)
        btn.setImage(UIImage(named: "sel"), for: .selected)
        return btn
    }()
    
    lazy var agreeL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#000000", 0.5)
        label.font = UIFont.GoogleSans(weight: .regular, size: 12)
        label.text = "Risks noted; confirm cancellation."
        return label
    }()
    
    lazy var deleteBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Delete account", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 14)
        btn.backgroundColor = .white
        btn.layer.cornerRadius = 22
        btn.layer.borderColor = UIColor.rgbHex("#14171C").cgColor
        btn.layer.borderWidth = 1
        btn.layer.masksToBounds = true
        return btn
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setup()
    }
    
    func setup() {
        self.navbar.nameL.text = "Delete account"
        self.view.addSubview(self.imageV)
        self.view.addSubview(self.riskL)
        self.imageV.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 164, height: 164))
        }
        self.riskL.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.imageV.snp.bottom).offset(24)
        }
        self.view.addSubview(self.infoV)
        self.infoV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.top.equalTo(self.riskL.snp.bottom).offset(20)
        }
   
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = 1.5
        let oneL: UILabel = UILabel()
        oneL.numberOfLines = 0
        oneL.attributedText = NSAttributedString(string: "Logout is final; no login capability. Once the account is exited, you will be unable to log in and will be removed from the device.", attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.GoogleSans(weight: .regular, size: 14), .foregroundColor: UIColor.rgbHex("#000000", 0.75)])
        infoV.addSubview(oneL)
        oneL.snp.makeConstraints { make in
            make.top.equalTo(8)
            make.left.equalTo(20)
            make.right.equalTo(-20)
        }
        
        let oneV: UIView = UIView()
        oneV.backgroundColor = UIColor.rgbHex("#DDF75B")
        infoV.addSubview(oneV)
        oneV.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(oneL.snp.top).offset(12)
            make.size.equalTo(CGSize(width: 4, height: 14))
        }
        
        let twoL: UILabel = UILabel()
        twoL.numberOfLines = 0
        twoL.attributedText = NSAttributedString(string: "Product data is irretrievable. Your files will be permanently deleted from the cloud storage server.", attributes: [.paragraphStyle: paragraphStyle, .font: UIFont.GoogleSans(weight: .regular, size: 14), .foregroundColor: UIColor.rgbHex("#000000", 0.75)])
        infoV.addSubview(twoL)
        twoL.snp.makeConstraints { make in
            make.left.equalTo(20)
            make.top.equalTo(oneL.snp.bottom).offset(8)
            make.right.equalTo(-20)
            make.bottom.equalTo(-16)
        }
        
        let twoV: UIView = UIView()
        twoV.backgroundColor = UIColor.rgbHex("#DDF75B")
        infoV.addSubview(twoV)
        twoV.snp.makeConstraints { make in
            make.left.equalToSuperview()
            make.top.equalTo(twoL.snp.top).offset(12)
            make.size.equalTo(CGSize(width: 4, height: 14))
        }

        self.view.addSubview(self.agreeBtn)
        self.agreeBtn.snp.makeConstraints { make in
            make.top.equalTo(self.infoV.snp.bottom).offset(6)
            make.left.equalTo(8)
            make.size.equalTo(CGSize(width: 32, height: 32))
        }
        self.view.addSubview(self.agreeL)
        self.agreeL.snp.makeConstraints { make in
            make.left.equalTo(self.agreeBtn.snp.right)
            make.centerY.equalTo(self.agreeBtn)
        }
        
        self.view.addSubview(self.deleteBtn)
        self.deleteBtn.snp.makeConstraints { make in
            make.left.equalTo(64)
            make.right.equalTo(-64)
            make.height.equalTo(44)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom).offset(-34)
        }
        self.agreeBtn.addTarget(self, action: #selector(clickAgreeAction), for: .touchUpInside)
        self.deleteBtn.addTarget(self, action: #selector(deletAction), for: .touchUpInside)
    }
    
    @objc func clickAgreeAction() {
        self.agreeBtn.isSelected = !self.agreeBtn.isSelected
    }
    
    @objc func deletAction() {
        if self.agreeBtn.isSelected == false {
            ToastTool.instance.show("Please check the box and agree.", .warning)
            return
        }
        let vc = AlertController(title: "Delete account", info: "Are you sure to cancel this account？")
        vc.modalPresentationStyle = .overFullScreen
        vc.okBlock = { [weak self] in
            guard let self = self else { return }
            self.deleteRequest()
        }
        self.present(vc, animated: false)
    }
    
    private func deleteRequest() {
        HttpManager.share.deleteUserApi { [weak self] status, model, errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if status == .success {
                    ToastTool.instance.show("The account has been successfully closed, and your personal data has been wiped.")
                    self.navigationController?.popViewController(animated: true)
                } else {
                    if let e = errMsg {
                        ToastTool.instance.show(e, .fail)
                    }
                }
            }
        }
    }
}
