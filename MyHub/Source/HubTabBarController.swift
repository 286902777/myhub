//
//  HubTabBarController.swift
//  MyHub
//
//  Created by hub on 2/6/26.
//

import UIKit
import SnapKit

class HubTabBarController: UIViewController {
    let tabbar = HubTabBar()
    
    var currentIdx: Int = 0
    private var controllers: [UIViewController] = []

    lazy var pageController: UIPageViewController = {
        let vc = UIPageViewController(
            transitionStyle: .scroll,    // 滚动式切换
            navigationOrientation: .horizontal,  // 水平导航
            options: nil
        )
        return vc
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addControllers()
        addTabBar()
        NotificationCenter.default.addObserver(forName: Noti_TabbarShow, object: nil, queue: .main) {[weak self] data in
            guard let self = self else { return }
            if let result = data.userInfo?["show"] as? Bool {
                self.tabbar.isHidden = !result
            }
        }
    }
    
    func addControllers() {
        let homeVC = UINavigationController(rootViewController: IndexController())
        let fileVC = UINavigationController(rootViewController: SecendController())
        let uploadVC = UINavigationController(rootViewController: SetController())
        let setVC = UINavigationController(rootViewController: SecendController())

        self.controllers.append(homeVC)
        self.controllers.append(fileVC)
        self.controllers.append(uploadVC)
        self.controllers.append(setVC)

        if let _ = self.controllers.first {
            pageController.setViewControllers([homeVC], direction: .forward, animated: false, completion: nil)
        }
        self.addChild(self.pageController)
        self.view.addSubview(self.pageController.view)
        self.pageController.didMove(toParent: self)
        self.pageController.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func addTabBar() {
        self.tabbar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(self.tabbar)
        self.tabbar.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.height.equalTo(CusTabBarHight)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
        }
        let homeItem = HubTabItem(selectedImage: UIImage(named: "home_s"), normalImage: UIImage(named: "home"), tag: 0)
        let fileItem = HubTabItem(selectedImage: UIImage(named: "file_s"), normalImage: UIImage(named: "file"), tag: 1)
        let uploadItem = HubTabItem(selectedImage: UIImage(named: "upload_s"), normalImage: UIImage(named: "upload"), tag: 2)
        let meItem = HubTabItem(selectedImage: UIImage(named: "me_s"), normalImage: UIImage(named: "me"), tag: 3)
        self.tabbar.tabbarItems = [homeItem, fileItem, uploadItem, meItem]
        self.tabbar.addItems()
        self.tabbar.clickAddBlock = {[weak self] in
            guard let self = self else { return }
            switch self.currentIdx {
            case 0:
                HubTool.share.loginSource = .upload
            case 1:
                HubTool.share.loginSource = .file
            case 2:
                HubTool.share.loginSource = .transfer
            default:
                HubTool.share.loginSource = .set
            }
            UploadTool.instance.openVC(self, self.currentIdx == 1)
        }
        self.tabbar.clickBlock = { [weak self] idx in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.currentIdx = idx
                let currentVC = self.controllers[idx]
                self.pageController.setViewControllers(
                    [currentVC],
                    direction: .forward,
                    animated: false,
                    completion: nil
                )
            }
        }
    }
}

extension HubTabBarController {
    override var shouldAutorotate: Bool {
        return false
    }
    
    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    ///默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
    /// 状态栏样式
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    
    /// 是否隐藏状态栏
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
}
