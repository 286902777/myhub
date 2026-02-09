//
//  SuperController.swift
//  MyHub
//
//  Created by hub on 2/9/26.
//

import UIKit

class SuperController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
            guard let self = self else { return }
            self.startTrack()
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
