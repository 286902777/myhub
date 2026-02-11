//
//  ShareController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class ShareController: UIViewController {
    lazy var contentV: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    lazy var leftL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#112031")
        label.text = "「"
        return label
    }()
    lazy var rightL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#112031")
        label.text = "」"
        return label
    }()
    lazy var nameL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#112031")
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return label
    }()
    
    lazy var itemL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#112031")
        label.text = "contains 3 files"
        return label
    }()
    
    lazy var closeBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "close"), for: .normal)
        return btn
    }()
        
    lazy var validityV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#FAFAFA")
        view.layer.cornerRadius = 14
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var validityL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#112031")
        label.text = "Valid time"
        return label
    }()
    
    lazy var dayL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 14)
        label.textColor = UIColor.rgbHex("#14171C")
        return label
    }()
    
    lazy var arrowV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "arrow")
        return view
    }()
    
    lazy var copyBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("OK", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#14171C"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .medium, size: 16)
        btn.layer.cornerRadius = 22
        btn.layer.masksToBounds = true
        btn.backgroundColor = UIColor.rgbHex("#DDF75B")
        return btn
    }()
        
    private var name: HUB_ShareDayName = .permanent
    private var type: HUB_ShareDateType = .none
    private var list: [VideoData] = []

    var resultBlock: ((_ url: String) -> Void)?
    
    init(list: [VideoData]) {
        self.list = list
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        self.view.addSubview(self.contentV)
        self.view.addSubview(self.closeBtn)
        self.contentV.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.leftL)
        self.stackView.addArrangedSubview(self.nameL)
        self.stackView.addArrangedSubview(self.rightL)
        self.stackView.addArrangedSubview(self.itemL)
        self.contentV.addSubview(self.validityV)
        self.validityV.addSubview(self.validityL)
        self.validityV.addSubview(self.dayL)
        self.validityV.addSubview(self.arrowV)
        self.contentV.addSubview(self.copyBtn)
        
        self.contentV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        self.closeBtn.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.bottom.equalTo(self.contentV.snp.top)
            make.size.equalTo(CGSize(width: 52, height: 52))
        }

        self.stackView.snp.makeConstraints { make in
            make.top.equalTo(24)
            make.left.equalTo(34)
            make.right.equalTo(-34)
        }
        
        self.validityV.snp.makeConstraints { make in
            make.top.equalTo(self.nameL.snp.bottom).offset(24)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(52)
        }
        
        self.validityL.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.left.equalTo(14)
        }
        
        self.arrowV.snp.makeConstraints { make in
            make.right.equalTo(-14)
            make.centerY.equalToSuperview()
        }
        self.dayL.snp.makeConstraints { make in
            make.right.equalTo(self.arrowV.snp.left)
            make.centerY.equalToSuperview()
        }
        
        self.copyBtn.snp.makeConstraints { make in
            make.top.equalTo(self.validityV.snp.bottom).offset(20)
            make.left.equalTo(14)
            make.right.equalTo(-14)
            make.height.equalTo(44)
            make.bottom.equalTo(-24)
        }
        self.copyBtn.addTarget(self, action: #selector(clickCopyAction), for: .touchUpInside)
        self.closeBtn.addTarget(self, action: #selector(clickCloseAction), for: .touchUpInside)

        let tap = UITapGestureRecognizer(target: self, action: #selector(clickDayAction))
        self.validityV.addGestureRecognizer(tap)
        self.dayL.text = self.name.rawValue
        var name: String = ""
        self.list.forEach { m in
            name = name + m.name
        }
        self.nameL.text = "jaosifjoasifdjasdfsaflfdjoasidfja.mp3"
//        self.nameL.text = name
    }
    
    @objc func clickDayAction() {
        let vc = ShareDayController(name: self.name, type: self.type)
        vc.modalPresentationStyle = .overFullScreen
        vc.clickBlock = {[weak self] name, type in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.name = name
                self.type = type
                self.dayL.text = self.name.rawValue
            }
        }
        self.present(vc, animated: false)
    }
    
    @objc func clickCopyAction() {
        LoadManager.instance.show(self, true)
        HttpManager.share.shareFileApi(self.list, self.type) { [weak self] status, model, errMsg in
            guard let self = self else { return }
            DispatchQueue.main.async {
                LoadManager.instance.dismiss()
                if status == .success {
                    self.resultBlock?(model.entity.url)
                    self.dismiss(animated: false)
                } else {
                    ToastTool.instance.show(errMsg, .fail)
                }
            }
        }
    }
    
    @objc func clickCloseAction() {
        self.dismiss(animated: false)
    }
}
