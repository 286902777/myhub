//
//  SuperController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit
import SnapKit

class SuperController: UIViewController {
    lazy var navbar: NaviBar = {
        let view = NaviBar.xibView()
        return view
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.startTrack()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initNavBar()
        initUI()
    }
    
    func initNavBar() {
        view.backgroundColor = .white
        self.view.addSubview(self.navbar)
        self.navbar.snp.makeConstraints { make in
            make.left.top.right.equalToSuperview()
            make.height.equalTo(NavBarH)
        }
        self.navbar.clickBlock = { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.backAction()
            }
        }
    }
    
    func initUI() {
        
    }
    
    func backAction() {
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - login
    func isUserLogin() -> Bool {
        if (LoginManager.share.isLogin == false) {
            LoginManager.share.loginRequest(self) { success in
               
            }
            return false
        } else {
            return true
        }
    }
    
    func startTrack() {
        if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
            appDelegate.startTrack()
        }
    }
}

extension SuperController {
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
