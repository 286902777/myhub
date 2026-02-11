//
//  StartController.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import UIKit

class StartController: UIViewController {
    
    @IBOutlet weak var nameL: UILabel!
    
    @IBOutlet weak var progressV: UIProgressView!
    
    private var progressValue: Float = 0.0
    private var remainingTime: TimeInterval = 3.0
    private var displayLink: CADisplayLink?
    private var isLoadingAds = false
    private var isEnd = false

    // 常量定义
    private enum Constants {
        static let displayLinkInterval: TimeInterval = 1.0 / 60.0 // 60 FPS
        static let minLoadingTime: TimeInterval = 1.0 // 最小加载时间
        static let delayBeforeReset: TimeInterval = 0.5
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        startLoadingProcess()
        setupNotifications()
        setupDisplayLink()
        self.view.addGradLayer(UIColor.rgbHex("#F1F9FF"), UIColor.rgbHex("#E9F6FF"), ScreenBounds, true)
        self.nameL.font = UIFont.GoogleSans(weight: .black, size: 20)
        NotificationCenter.default.addObserver(forName: Noti_DismissAds, object: nil, queue: .main) { [weak self] _ in
            guard let self = self, self.isEnd == false else { return }
            guard let vc = HubTool.share.keyVC(), vc.isKind(of: StartController.self) else { return }
            self.goToRootController()
        }
    }
    
    deinit {
        cleanup()
        print("FirstController deinit")
    }
}

// MARK: - Setup Methods
private extension StartController {
    func setupprogressV() {
        progressV.progress = 0.0
        progressV.layer.cornerRadius = 2.0
        progressV.layer.masksToBounds = true
    }
    
    func setupNotifications() {
        NotificationCenter.default.addObserver(
            forName: Noti_DismissAds,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            guard let self = self else { return }
            self.handleAdsDismissed()
        }
    }

    func startLoadingProcess() {
        let noFirst = UserDefaults.standard.bool(forKey: HUB_FirstAdLoading)
        if noFirst {
            startAdLoadingProcess()
        } else {
            startDirectTransition()
        }
    }
    
    func startAdLoadingProcess() {
        setupDisplayLink()
        setupAdCompletionHandler()
    }
    
    func startDirectTransition() {
        // 标记为已加载过广告
        UserDefaults.standard.set(true, forKey: HUB_FirstAdLoading)
        
        // 短暂延迟后直接跳转
        DispatchQueue.main.asyncAfter(deadline: .now() + Constants.delayBeforeReset) { [weak self] in
            self?.goToRootController()
        }
    }

    func setupDisplayLink() {
        // 计算总时间，确保不小于最小时间
//        let startTime = max(Double(AdmobTool.instance.startTime), Constants.minLoadingTime)
        let startTime = max(7, Constants.minLoadingTime)

        remainingTime = startTime
        
        displayLink = CADisplayLink(target: self, selector: #selector(updateProgress))
        displayLink?.preferredFramesPerSecond = 60
        displayLink?.add(to: .main, forMode: .common)
    }
    
    @objc func updateProgress() {
        guard remainingTime > 0 else {
            completeLoading()
            return
        }
        
        // 计算每帧的进度增量
        let frameDuration = Constants.displayLinkInterval
//        let progressIncrement = Float(frameDuration / Double(AdmobTool.instance.startTime))
        let progressIncrement = Float(frameDuration / 7)

        remainingTime -= frameDuration
        progressValue = min(progressValue + progressIncrement, 1.0)

        // 更新UI（避免不必要的重绘）
        if abs(progressV.progress - progressValue) > 0.01 {
            progressV.setProgress(progressValue, animated: true)
        }
    }
    
    func completeLoading() {
        guard isEnd == false else { return }
        displayLink?.invalidate()
        
        // 确保进度条完成
        progressV.setProgress(1.0, animated: true)
        
        // 如果没有广告加载完成，直接跳转
        if !isLoadingAds {
            goToRootController()
        }
    }

    func setupAdCompletionHandler() {
//        AdmobTool.instance.successComplete = { [weak self] in
//            guard let self = self else { return }
//            self.handleAdLoadingComplete()
//        }
    }
    
    func handleAdLoadingComplete() {
        isLoadingAds = true
        displayLink?.invalidate()
        
        // 平滑完成进度条动画
//        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
//            self.progressV.setProgress(1.0, animated: true)
//        } completion: { [weak self] _ in
//            guard let self = self else { return }
//            guard HubTool.share.showAdomb == false else { return }
//            self.showAd()
//        }
    }
    
    func showAd() {
        guard isEnd == false else { return }
        HubTool.share.adsPlayState = .openCool
//        AdmobTool.instance.show(.mode_open) { [weak self] success in
//            guard let self = self else { return }
//            DispatchQueue.main.async {
//                if success == false {
//                    self.goToRootController()
//                }
//            }
//        }
    }

    func goToRootController() {
//        guard isEnd == false, HubTool.share.showAdomb == false else { return }
        guard let window = HubTool.share.keyWindow else {
            return
        }
        window.rootViewController = HubTabBarController()
        self.cleanup()
//#if DEBUG
//        ConsentInformation.shared.reset()
//#endif
//        if let vc = HubTool.share.keyVC() {
//            AdmobUPMTool.instance.showGoogleView(vc) { consentError in
//                if let consentError {
//                    // Consent gathering failed.
//                    print("Error: \(consentError.localizedDescription)")
//                }
//            }
//        }
    }

    func handleAdsDismissed() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.goToRootController()
        }
    }

    func cleanup() {
        displayLink?.remove(from: .current, forMode: .default)
        displayLink?.invalidate()
        displayLink = nil
        // 清除回调，避免循环引用
        isEnd = true
//        AdmobTool.instance.successComplete = nil
        NotificationCenter.default.removeObserver(self)
    }
}
