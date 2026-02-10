//
//  SecendController.swift
//  MyHub
//
//  Created by hub on 2/6/26.
//

import UIKit
import SnapKit

class SecendController: SuperController {
    lazy var sortBtn: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(named: "menu"), for: .normal)
        btn.setImage(UIImage(named: "menu"), for: .highlighted)
        btn.setImage(UIImage(named: "menu"), for: .selected)
        return btn
    }()

    
    private var sortType: HUB_SortType = .upload
    private var asc: Bool = true

    lazy var stackView: UIStackView = {
        let view = UIStackView()
        view.spacing = 28
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
        label.textColor = UIColor.rgbHex("#112031")
        return label
    }()
    lazy var fileImgV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#053C62", 0.5)
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
        label.text = "Saved"
        label.font = UIFont.GoogleSans(weight: .bold, size: 18)
        label.textColor = UIColor.rgbHex("#112031", 0.5)
        return label
    }()
    
    lazy var saveImgV: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.rgbHex("#053C62", 0.5)
        view.isHidden = true
        return view
    }()
    
    var currentIdx: Int = 0 {
        didSet {
            if (currentIdx == 0) {
                fileL.textColor = UIColor.rgbHex("#112031")
                fileImgV.isHidden = false
                saveL.textColor = UIColor.rgbHex("#112031", 0.5)
                saveImgV.isHidden = true
                sortBtn.isEnabled = true
            } else {
                saveL.textColor = UIColor.rgbHex("#112031")
                saveImgV.isHidden = false
                fileL.textColor = UIColor.rgbHex("#112031", 0.5)
                fileImgV.isHidden = true
                sortBtn.isEnabled = false
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
        self.navbar.bgView.addSubview(self.sortBtn)
        self.sortBtn.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 40, height: 40))
        }

        self.sortBtn.addTarget(self, action: #selector(clickSortAction), for: .touchUpInside)
        self.navbar.bgView.addSubview(self.stackView)
        self.fileV.addSubview(self.fileImgV)
        self.fileV.addSubview(self.fileL)
        self.saveV.addSubview(self.saveImgV)
        self.saveV.addSubview(self.saveL)
        
        self.stackView.addArrangedSubview(self.fileV)
        self.stackView.addArrangedSubview(self.saveV)
        self.stackView.snp.makeConstraints { make in
            make.left.equalTo(16)
            make.height.equalTo(32)
            make.centerY.equalToSuperview()
        }
        self.fileImgV.snp.makeConstraints { make in
            make.height.equalTo(6)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-6)
        }
        self.fileL.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
        }
        self.saveImgV.snp.makeConstraints { make in
            make.height.equalTo(6)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-6)
        }
        self.saveL.snp.makeConstraints { make in
            make.left.right.centerY.equalToSuperview()
        }
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
    }
  
    @objc func clickSortAction() {
        let vc = SortController()
        vc.currentType = self.sortType
        vc.currentAsc = self.asc
        vc.modalPresentationStyle = .overFullScreen
        vc.clickBlock = { [weak self] type, asc in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.sortType = type
                self.asc = asc
                self.fileVC.sortData(type, asc)
            }
        }
        self.present(vc, animated: false)
    }
    
    @objc func clickFilterAction(_ sender: UITapGestureRecognizer) {
        self.currentIdx = sender.view?.tag ?? 0
        print(self.currentIdx)
        self.fileVC.bottomView.isHidden = self.currentIdx == 1
    }
}

