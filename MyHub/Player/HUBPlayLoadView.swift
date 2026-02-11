//
//  HUBPlayLoadView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit
import SnapKit

class HUBPlayLoadView: UIView {
    lazy var mainV: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    let loadV: HUBActiveView = HUBActiveView(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
    lazy var speedL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Current line congestion... 0kb/s"
        return label
    }()
    
    lazy var stackBgV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 2
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.axis = .horizontal
        return view
    }()
    
    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_star")
        return view
    }()
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 12)
        label.textColor = UIColor.rgbHex("#321E07")
        label.text = "Exclusive acceleration line"
        return label
    }()
    
    lazy var memberV: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    lazy var fastV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_member_bg")
        return view
    }()
    lazy var fastL: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        label.textColor = .white
        label.textAlignment = .center
        label.text = "Loading extremely fast…"
        return label
    }()
    
    lazy var speedV: UIView = {
        let view = UIView()
        return view
    }()
    lazy var leftV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.addGradLayer(UIColor.rgbHex("#FFF3D6"), UIColor.rgbHex("#D59A38"), CGRectMake(0, 0, 24, 4))
        return view
    }()
    
    lazy var rightV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 1
        view.backgroundColor = UIColor.rgbHex("#999999")
        return view
    }()
    
    lazy var addV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_add")
        return view
    }()
    
    var clickBlock: ((_ click: Bool) -> Void)?
    
    var stateBlock: (() -> Void)?
        
    private var timer: Timer?
    
    class func view() -> HUBPlayLoadView {
        let view = HUBPlayLoadView()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.isHidden = true
        self.backgroundColor = UIColor.rgbHex("#000000", 0.16)
        self.addSubview(self.mainV)
        self.mainV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(240)
        }
        self.mainV.addSubview(self.loadV)
        self.mainV.addSubview(self.speedL)
        self.mainV.addSubview(self.stackBgV)
        self.stackBgV.addSubview(self.stackV)
        self.stackV.addArrangedSubview(self.iconV)
        self.stackV.addArrangedSubview(self.infoL)
        
        self.loadV.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.top.centerX.equalToSuperview()
        }
        self.speedL.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.loadV.snp.bottom).offset(8)
        }
        self.stackBgV.snp.makeConstraints { make in
            make.top.equalTo(self.speedL.snp.bottom).offset(14)
            make.size.equalTo(CGSize(width: 200, height: 30))
            make.centerX.bottom.equalToSuperview()
        }
        self.stackV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 176, height: 16))
        }
        
        self.stackBgV.addGradLayer(UIColor.rgbHex("#FFF3D6"), UIColor.rgbHex("#EDC685"), CGRectMake(0, 0, 200, 30))
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickToPreAction))
        self.stackV.addGestureRecognizer(tap)
        
        self.addSubview(self.memberV)
        self.memberV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(215)
        }
        self.memberV.addSubview(self.speedV)
        self.speedV.addSubview(self.leftV)
        self.speedV.addSubview(self.rightV)
        self.speedV.addSubview(self.addV)
        self.memberV.addSubview(self.fastV)
        self.fastV.addSubview(self.fastL)
        
        self.speedV.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 18))
        }
        self.leftV.snp.makeConstraints { make in
            make.left.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 24, height: 4))
        }
        self.rightV.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.height.equalTo(4)
            make.left.equalTo(self.leftV.snp.right)
        }
        
        self.addV.snp.makeConstraints { make in
            make.left.equalTo(18)
            make.centerY.equalToSuperview()
        }
        
        self.fastV.snp.makeConstraints { make in
            make.top.equalTo(self.speedV.snp.bottom).offset(18)
            make.height.equalTo(20)
            make.bottom.left.right.equalToSuperview()
        }
        self.fastL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
//        NotificationCenter.default.addObserver(forName: Noti_UserVip, object: nil, queue: .main) { [weak self] _ in
//            guard let self = self else { return }
//            self.mainV.isHidden = PremiumTool.instance.isMember
//            self.memberV.isHidden = !PremiumTool.instance.isMember
//        }
    }
    
    
    func start() {
        self.isHidden = false
//        self.mainV.isHidden = PremiumTool.instance.isMember
//        self.memberV.isHidden = !PremiumTool.instance.isMember
        var showLength = Int.random(in: 5...9)
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                showLength -= 1
                if showLength <= 0 {
                    self.stop()
                    print("bbbbbb-dismis")
                    self.clickBlock?(false)
                }
//                if PremiumTool.instance.isMember == false {
//                    let size = Int.random(in: 0...999)
//                    self.speedL.text = "Current line congestion... \(size)kb/s"
//                }
            }
        })
    }
    
    func stop() {
        self.stateBlock?()
        self.timer?.invalidate()
        self.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func clickToPreAction() {
        self.timer?.invalidate()
        self.stateBlock?()
        self.isHidden = true
        self.clickBlock?(true)
    }
}

