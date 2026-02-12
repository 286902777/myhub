//
//  AlertController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

enum HUB_AlertButtonType: Int {
    case all = 0
    case ok
    case cancel
}
class AlertController: UIViewController {
    lazy var contentView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var titleStackV: UIStackView = {
        let view = UIStackView()
        view.spacing = 10
        view.axis = .vertical
        return view
    }()
    
    lazy var titleL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 16)
        label.textColor = UIColor.rgbHex("#14171C")
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .regular, size: 14)
        label.textColor = UIColor.rgbHex("#14171C", 0.75)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.spacing = 15
        view.distribution = .fillEqually
        view.axis = .horizontal
        return view
    }()
    
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#053C62"), for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = 20
        btn.layer.borderWidth = 1
        btn.layer.borderColor = UIColor.rgbHex("#053C62").cgColor
        btn.layer.masksToBounds = true
        btn.backgroundColor = .white
        return btn
    }()
    
    lazy var sureBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Confirm", for: .normal)
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.rgbHex("#053C62")
        return btn
    }()
    
    var okBlock: (() -> Void)?
    
    var titleStr: String = ""
    var infoStr: String = ""
    var btnTye: HUB_AlertButtonType = .all
    
    init(title: String, info: String, type: HUB_AlertButtonType = .all) {
        self.titleStr = title
        self.infoStr = info
        self.btnTye = type
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        setData()
    }
    
    func setUI() {
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.view.addSubview(self.contentView)
        self.contentView.addSubview(self.titleStackV)
        self.titleStackV.addArrangedSubview(self.titleL)
        self.titleStackV.addArrangedSubview(self.infoL)
        self.contentView.addSubview(self.stackV)
        self.stackV.addArrangedSubview(self.cancelBtn)
        self.stackV.addArrangedSubview(self.sureBtn)

        self.contentView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.equalTo(28)
            make.right.equalTo(-28)
        }
        
        self.titleStackV.snp.makeConstraints { make in
            make.top.equalTo(40)
            make.left.equalTo(40)
            make.right.equalTo(-40)
        }
        self.stackV.snp.makeConstraints { make in
            make.top.equalTo(self.titleStackV.snp.bottom).offset(20)
            make.left.equalTo(20)
            make.right.equalTo(-20)
            make.height.equalTo(44)
            make.bottom.equalTo(-24)
        }
        
        self.cancelBtn.addTarget(self, action: #selector(clickCancelAction), for: .touchUpInside)
        self.sureBtn.addTarget(self, action: #selector(clickSureAction), for: .touchUpInside)
    }
    
    func setData() {
        if self.titleStr.count == 0 {
            self.titleL.isHidden = true
        } else {
            self.titleL.isHidden = false
            self.titleL.text = self.titleStr
        }
        self.infoL.text = self.infoStr
        switch btnTye {
        case .all:
            self.cancelBtn.isHidden = false
            self.sureBtn.isHidden = false
        case .ok:
            self.cancelBtn.isHidden = true
            self.sureBtn.isHidden = false
        case .cancel:
            self.cancelBtn.isHidden = false
            self.sureBtn.isHidden = true
        }
    }
    
    @objc func clickCancelAction() {
        self.dismiss(animated: false)
    }
    
    @objc func clickSureAction() {
        self.okBlock?()
        self.dismiss(animated: false)
    }
}
