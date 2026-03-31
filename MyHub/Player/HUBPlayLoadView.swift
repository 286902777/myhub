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
    
    lazy var vipV: UIView = {
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

    lazy var iconV: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "pre_small")
        return view
    }()
    
    lazy var infoV: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 15
        view.isUserInteractionEnabled = true
        return view
    }()
    
    lazy var infoL: UILabel = {
        let label = UILabel()
        label.font = UIFont.GoogleSans(weight: .medium, size: 12)
        label.textColor = UIColor.rgbHex("#14171C")
        label.text = "Exclusive acceleration line"
        return label
    }()
    
    lazy var sliderV: PlayerSlider = {
        let view = PlayerSlider()
        view.isUserInteractionEnabled = false
        view.maximumTrackTintColor = UIColor.rgbHex("#FFFFFF", 0.5)
        view.minimumTrackTintColor = UIColor.rgbHex("#DDF75B")
        view.setThumbImage(UIImage(named: "pre_star"), for: .normal)
        view.setThumbImage(UIImage(named: "pre_star"), for: .highlighted)
        view.minimumValue = 0
        view.maximumValue = 1
        view.layer.cornerRadius = 2
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
    
    var clickBlock: ((_ click: Bool) -> Void)?
    
    var stateBlock: (() -> Void)?
        
    private var timer: Timer?
    private var isEnd: Bool = false
    
    class func view() -> HUBPlayLoadView {
        let view = HUBPlayLoadView()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.isHidden = true
        self.backgroundColor = UIColor.clear
        self.addSubview(self.mainV)
        self.mainV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(240)
        }
        self.mainV.addSubview(self.loadV)
        self.mainV.addSubview(self.speedL)
        self.mainV.addSubview(self.infoV)
        self.infoV.addSubview(self.infoL)
        self.mainV.addSubview(self.iconV)
        self.loadV.snp.makeConstraints { make in
            make.size.equalTo(CGSize(width: 24, height: 24))
            make.top.centerX.equalToSuperview()
        }
        self.speedL.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.loadV.snp.bottom).offset(12)
        }
       
        self.infoV.snp.makeConstraints { make in
            make.top.equalTo(self.speedL.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 185, height: 30))
            make.centerX.bottom.equalToSuperview()
        }
        self.infoL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.iconV.snp.makeConstraints { make in
            make.top.equalTo(self.infoV.snp.top).offset(-8)
            make.left.equalTo(self.infoV)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        let tap = UITapGestureRecognizer(target: self, action: #selector(clickToPreAction))
        self.infoV.addGestureRecognizer(tap)
        
        self.addSubview(self.vipV)
        self.vipV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 150, height: 50))
        }
        self.vipV.addSubview(self.sliderV)
        self.vipV.addSubview(self.fastL)

        self.sliderV.snp.makeConstraints { make in
            make.top.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 100, height: 4))
        }

        self.fastL.snp.makeConstraints { make in
            make.bottom.centerX.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_UserVip, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.mainV.isHidden = PayManager.instance.isVip
            self.vipV.isHidden = !PayManager.instance.isVip
        }
        self.sliderV.value = 0
    }
    
    
    func start() {
        if self.isEnd {
            self.sliderV.value = 0
        }
        self.clickBlock?(false)
        self.isHidden = false
        self.mainV.isHidden = PayManager.instance.isVip
        self.vipV.isHidden = !PayManager.instance.isVip
        var showLength = Int.random(in: 5...9)
        self.timer?.invalidate()
        self.timer = nil
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }
            DispatchQueue.main.async {
                showLength -= 1
                if showLength <= 0, self.isEnd == false {
                    self.stop()
                    self.clickBlock?(false)
                }
                if PayManager.instance.isVip == false {
                    let size = Int.random(in: 0...999)
                    self.speedL.text = "Current line congestion... \(size)kb/s"
                } else {
                    if self.sliderV.value >= 1 {
                        self.sliderV.value = 0
                    } else {
                        self.sliderV.value += 0.1
                    }
                }
            }
        })
    }
    
    func stop() {
        self.isEnd = true
        self.stateBlock?()
        self.timer?.invalidate()
        self.timer = nil
        self.isHidden = true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func clickToPreAction() {
        self.isEnd = true
        self.timer?.invalidate()
        self.timer = nil
        self.isHidden = true
        self.stateBlock?()
        self.clickBlock?(true)
    }
}

