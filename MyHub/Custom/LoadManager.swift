//
//  LoadManager.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import SnapKit

class LoadManager: UIView {
    static let instance = LoadManager()
    lazy var bgV: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        view.layer.masksToBounds = true
        view.backgroundColor = UIColor.gray
        return view
    }()
    
    lazy var activeV: UIActivityIndicatorView = {
        let activeV = UIActivityIndicatorView(style: .large)
        activeV.color = .white
        return activeV
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.initUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func initUI() {
        self.isHidden = true
        self.backgroundColor = UIColor.clear
        self.addSubview(self.bgV)
        self.bgV.addSubview(self.activeV)
        self.bgV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
        self.activeV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 60, height: 60))
        }
    }
    
    func show(_ vc: UIViewController, _ add: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isHidden = false
            vc.view.addSubview(self)
            if add {
                self.bgV.backgroundColor = UIColor.rgbHex("#000000", 0.4)
            }
            self.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            self.activeV.startAnimating()
        }
    }
    
    func dismiss() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.isHidden = true
            self.activeV.stopAnimating()
            self.removeFromSuperview()
        }
    }
}
