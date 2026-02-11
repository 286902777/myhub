//
//  SecendController.swift
//  MyHub
//
//  Created by hub on 2/6/26.
//

import UIKit
import SnapKit

class SecendController: SuperController {
    lazy var cancelBtn: UIButton = {
        let btn = UIButton()
        btn.setTitle("Cancel", for: .normal)
        btn.setTitleColor(UIColor.rgbHex("#595959"), for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .regular, size: 14)
        btn.isHidden = true
        return btn
    }()

    lazy var countL: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.rgbHex("#14171C")
        label.font = UIFont.GoogleSans(weight: .bold, size: 18)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private var sortType: HUB_SortType = .upload
    private var asc: Bool = true

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 52
        view.axis = .horizontal
        return view
    }()
    
    lazy var fileV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.tag = 0
        return view
    }()
    
    lazy var fileL: UILabel = {
        let label = UILabel()
        label.text = "File"
        label.font = UIFont.GoogleSans(weight: .bold, size: 18)
        label.textColor = UIColor.rgbHex("#14171C")
        return label
    }()
    lazy var fileImgV: UIView = {
        let view = UIView()
        return view
    }()
    
    lazy var saveV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.tag = 1
        return view
    }()
    
    lazy var saveL: UILabel = {
        let label = UILabel()
        label.text = "Save"
        label.font = UIFont.GoogleSans(weight: .bold, size: 18)
        label.textColor = UIColor.rgbHex("#14171C", 0.5)
        return label
    }()
    
    lazy var saveImgV: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    var currentIdx: Int = 0 {
        didSet {
            if (currentIdx == 0) {
                fileL.textColor = UIColor.rgbHex("#14171C")
                fileImgV.isHidden = false
                saveL.textColor = UIColor.rgbHex("#14171C", 0.5)
                saveImgV.isHidden = true
            } else {
                saveL.textColor = UIColor.rgbHex("#14171C")
                saveImgV.isHidden = false
                fileL.textColor = UIColor.rgbHex("#14171C", 0.5)
                fileImgV.isHidden = true
            }
            self.fileVC.dismissBottomView()
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
    
    let fileVC = FileController()
    let saveVC = SaveController()

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func initNavBar() {
        super.initNavBar()
        self.navbar.backBtn.isHidden = true
        self.navbar.nameL.isHidden = true
        self.navbar.bgView.addSubview(self.countL)
        self.navbar.bgView.addSubview(self.cancelBtn)
        self.cancelBtn.snp.makeConstraints { make in
            make.right.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 72, height: 44))
        }

        self.countL.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        self.cancelBtn.addTarget(self, action: #selector(clickCancelAction), for: .touchUpInside)
        self.navbar.bgView.addSubview(self.stackView)
        self.fileV.addSubview(self.fileImgV)
        self.fileV.addSubview(self.fileL)
        self.saveV.addSubview(self.saveImgV)
        self.saveV.addSubview(self.saveL)
        
        self.stackView.addArrangedSubview(self.fileV)
        self.stackView.addArrangedSubview(self.saveV)
        self.stackView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.center.equalToSuperview()
        }
        self.fileImgV.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-10)
        }
        self.fileL.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
        }
        self.saveImgV.snp.makeConstraints { make in
            make.height.equalTo(8)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-10)
        }
        self.saveL.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
        }
        self.stackView.layoutIfNeeded()
        self.fileImgV.addGradLayer(UIColor.rgbHex("#F2FCA0"), UIColor.rgbHex("#E1F867"), self.fileImgV.bounds)
        self.saveImgV.addGradLayer(UIColor.rgbHex("#F2FCA0"), UIColor.rgbHex("#E1F867"), self.saveImgV.bounds)

        let ftap = UITapGestureRecognizer(target: self, action: #selector(clickFilterAction(_:)))
        let stap = UITapGestureRecognizer(target: self, action: #selector(clickFilterAction(_:)))
        self.fileV.addGestureRecognizer(ftap)
        self.saveV.addGestureRecognizer(stap)
    }
    
    override func initUI() {
        self.pages.append(fileVC)
        self.pages.append(saveVC)
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
        self.fileVC.showCountBlock = { [weak self] count in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.stackView.isHidden = true
                self.cancelBtn.isHidden = false
                self.countL.isHidden = false
            }
        }
        self.fileVC.clickUploadBlock = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                UploadTool.instance.openVC(self, true)
            }
        }
    }
  
    @objc func clickCancelAction() {
        self.cancelBtn.isHidden = true
        self.countL.isHidden = true
        self.stackView.isHidden = false
        self.fileVC.dismissBottomView()
    }

    @objc func clickFilterAction(_ sender: UITapGestureRecognizer) {
        self.currentIdx = sender.view?.tag ?? 0
        print(self.currentIdx)
        self.fileVC.bottomView.isHidden = self.currentIdx == 1
    }
}

