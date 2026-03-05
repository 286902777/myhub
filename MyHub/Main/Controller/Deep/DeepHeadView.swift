//
//  DeepHeadView.swift
//  MyHub
//
//  Created by Ever on 2026/3/5.
//

import UIKit
import SnapKit

class DeepHeadView: UIView {
    lazy var stackV: UIStackView = {
        let view = UIStackView()
        view.spacing = 20
        view.axis = .horizontal
        return view
    }()
    
    lazy var hotBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("HOT", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#141414"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .black, size: 16)
        btn.tag = 0
        return btn
    }()
    
    lazy var recentBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Recently", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#141414", 0.5), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .black, size: 16)
        btn.tag = 1
        return btn
    }()
    
    private var currentIdx: Int = 0 {
        didSet {
            if (currentIdx == 0) {
                self.hotBtn.setTitleColor(UIColor.rgbHex("#141414"), for: .normal)
                self.recentBtn.setTitleColor(UIColor.rgbHex("#141414", 0.5), for: .normal)
            } else {
                self.hotBtn.setTitleColor(UIColor.rgbHex("#141414", 0.5), for: .normal)
                self.recentBtn.setTitleColor(UIColor.rgbHex("#141414"), for: .normal)
            }
            let currentVC = pages[currentIdx]
            self.pageController.setViewControllers(
                [currentVC],
                direction: .forward,
                animated: false,
                completion: nil
            )
        }
    }
    private var pages: [UIViewController] = []

    lazy var pageController: UIPageViewController = {
        let vc = UIPageViewController(
            transitionStyle: .scroll,    // 滚动式切换
            navigationOrientation: .horizontal,  // 水平导航
            options: nil
        )
        return vc
    }()
    
    let hotVC: DeepHotController = DeepHotController()
    let recentlyVC: DeepRecentlyController = DeepRecentlyController()
    class func view() -> DeepHeadView {
        let view = DeepHeadView()
        view.initUI()
        return view
    }
    
    func initUI() {
        self.frame = CGRect(x: 0, y: 0, width: ScreenWidth, height: 160)
        self.addSubview(stackV)
        self.stackV.addArrangedSubview(self.hotBtn)
        self.stackV.addArrangedSubview(self.recentBtn)

        self.hotBtn.addTarget(self, action: #selector(clickSegAction(_:)), for: .touchUpInside)
        self.recentBtn.addTarget(self, action: #selector(clickSegAction(_:)), for: .touchUpInside)

        self.stackV.snp.makeConstraints { make in
            make.left.equalTo(14)
            make.top.equalTo(6)
            make.height.equalTo(28)
        }
        self.hotBtn.snp.makeConstraints { make in
            make.width.equalTo(36)
        }
        self.recentBtn.snp.makeConstraints { make in
            make.width.equalTo(70)
        }
        
        self.pages.append(hotVC)
        self.pages.append(recentlyVC)
        if let firstVC = pages.first {
            pageController.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
        self.addSubview(self.pageController.view)
        self.pageController.view.snp.makeConstraints { make in
            make.top.equalTo(self.stackV.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    @objc func clickSegAction(_ sender: UIButton) {
        self.currentIdx = sender.tag
    }
}
