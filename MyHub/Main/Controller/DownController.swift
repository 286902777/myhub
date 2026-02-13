//
//  DownController.swift
//  MyHub
//
//  Created by Ever on 2026/2/12.
//

import UIKit
import SnapKit

class DownController: SuperController {
    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 52
        view.axis = .horizontal
        return view
    }()
    
    lazy var uploadV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.tag = 0
        return view
    }()
    
    lazy var uploadL: UILabel = {
        let label = UILabel()
        label.text = "Upload"
        label.font = UIFont.GoogleSans(weight: .bold, size: 18)
        label.textColor = UIColor.rgbHex("#14171C")
        return label
    }()
    lazy var uploadImgV: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var downV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.tag = 1
        return view
    }()
    
    lazy var downL: UILabel = {
        let label = UILabel()
        label.text = "DownLoad"
        label.font = UIFont.GoogleSans(weight: .bold, size: 18)
        label.textColor = UIColor.rgbHex("#14171C", 0.5)
        return label
    }()
    
    lazy var downImgV: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var currentIdx: Int = 0 {
        didSet {
            if (currentIdx == 0) {
                uploadL.textColor = UIColor.rgbHex("#14171C")
                uploadImgV.isHidden = false
                downL.textColor = UIColor.rgbHex("#14171C", 0.5)
                downImgV.isHidden = true
            } else {
                downL.textColor = UIColor.rgbHex("#14171C")
                downImgV.isHidden = false
                uploadL.textColor = UIColor.rgbHex("#14171C", 0.5)
                uploadImgV.isHidden = true
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
    
    let uploadVC = UploadFileController()
    let downVC = DownFileController()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navbar.backBtn.isHidden = true
        self.navbar.nameL.isHidden = true
        self.navbar.bgView.addSubview(self.stackView)
        self.uploadV.addSubview(self.uploadImgV)
        self.uploadV.addSubview(self.uploadL)
        self.downV.addSubview(self.downImgV)
        self.downV.addSubview(self.downL)
        
        self.stackView.addArrangedSubview(self.uploadV)
        self.stackView.addArrangedSubview(self.downV)
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
        self.uploadImgV.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-10)
        }
        self.uploadL.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
        }
        self.downImgV.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-10)
        }
        self.downL.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
        }
        self.stackView.layoutIfNeeded()
        self.uploadImgV.addGradLayer(UIColor.rgbHex("#F2FCA0"), UIColor.rgbHex("#E1F867"), self.uploadImgV.bounds)
        self.downImgV.addGradLayer(UIColor.rgbHex("#F2FCA0"), UIColor.rgbHex("#E1F867"), self.downImgV.bounds)
        
        let ftap = UITapGestureRecognizer(target: self, action: #selector(clickFilterAction(_:)))
        let stap = UITapGestureRecognizer(target: self, action: #selector(clickFilterAction(_:)))
        self.downV.addGestureRecognizer(ftap)
        self.downV.addGestureRecognizer(stap)
    }
    
    func addController() {
        self.pages.append(self.uploadVC)
        self.pages.append(self.downVC)
        self.downVC.refreshBlock = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {

            }
        }
 
        if let firstVC = pages.first {
            pageController.setViewControllers([firstVC], direction: .forward, animated: false, completion: nil)
        }
        self.addChild(self.pageController)
        self.view.addSubview(self.pageController.view)
        self.pageController.didMove(toParent: self)
        self.pageController.view.snp.makeConstraints { make in
            make.top.equalTo(self.navbar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
        self.currentIdx = 0
    }
    
    @objc func clickFilterAction(_ sender: UITapGestureRecognizer) {
        self.currentIdx = sender.view?.tag ?? 0
    }
}

enum HUB_UploadDownState: String {
    case inProgree = "In progress"
    case completed = "Completed"
}
class UploadDownData: SuperData {
    var state: HUB_UploadDownState = .inProgree
    var lists: [VideoData] = []
}
