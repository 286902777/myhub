//
//  HUBPlayerView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import AVFoundation
import SnapKit
import UIKit

extension HUBPlayerView {
    enum HUBWaitReadyToPlayState {
        case nomal
        case pause
        case play
    }
}

class HUBPlayerView: UIView {
    init(config: HUBPlayerConfigure) {
        super.init(frame: .zero)
        self.config = config
        initSubViews()
        makeConstraints()
        (layer as? AVPlayerLayer)?.videoGravity = self.config.videoGravity
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @discardableResult private func mainSync<T>(execute block: () -> T) -> T {
        guard !Thread.isMainThread else { return block() }
        return DispatchQueue.main.sync { block() }
    }

    lazy var contentView: HUBPlayerContentView = {
        let view = HUBPlayerContentView(config: config)
        view.delegate = self
        return view
    }()

    private var showPopLoad: Bool = false
    
    private var keyWindow: UIWindow? {
        mainSync {
            if #available(iOS 13.0, *) {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap(\.windows)
                    .first { $0.isKeyWindow }
            } else {
                UIApplication.shared.keyWindow
            }
        }
    }

    private var seekTime: HUBPlayer.HUBPlayerSeek?

    private var waitReadyToPlayState: HUBWaitReadyToPlayState = .nomal

    private var sliderTimer: PlayTimer?

    private var bufferTimer: PlayTimer?

    private var config = HUBPlayerConfigure()

    private var animationTransitioning: HUBAnimationTransition?

    private var fullScreenController: FullScreenController?

    private var statusObserve: NSKeyValueObservation?

    private var loadedTimeRangesObserve: NSKeyValueObservation?

    private var playbackBufferEmptyObserve: NSKeyValueObservation?

    private var isUserPause: Bool = false

    private var isEnterBackground: Bool = false

    private var player: AVPlayer?

    private var playerItem: AVPlayerItem? {
        didSet {
            guard playerItem != oldValue else { return }
            if let oldPlayerItem = oldValue {
                NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: oldPlayerItem)
            }
            guard let playerItem = playerItem else { return }
            NotificationCenter.default.addObserver(self, selector: #selector(didPlaybackEnds), name: .AVPlayerItemDidPlayToEndTime, object: playerItem)

            statusObserve = playerItem.observe(\.status, options: [.new]) { [weak self] _, _ in
                self?.observeStatusAction()
            }
        }
    }

    private(set) var totalDuration: TimeInterval = .zero {
        didSet {
            guard totalDuration != oldValue else { return }
            contentView.setTotalDuration(totalDuration)
        }
    }

    private(set) var currentDuration: TimeInterval = .zero {
        didSet {
            guard currentDuration != oldValue else { return }
            contentView.setCurrentDuration(min(currentDuration, totalDuration))
            let time = ceil(currentDuration)
            guard time > 0 else { return }

//            let count = UserDefaults.standard.integer(forKey: ES_PlayingCount)
//            if Int(time) >= AdmobTool.instance.playingTime, count >= AdmobTool.instance.playingIndex, ESBaseTool.instance.isCountMiddlePlay == false {
//                ESBaseTool.instance.isCountMiddlePlay = true
//                ESBaseTool.instance.adsPlayState = .play
//                AdmobTool.instance.show(.mode_playing) { [weak self] success in
//                    guard let self = self else { return }
//                    if success {
//                        self.pause()
//                        UserDefaults.standard.set(0, forKey: ES_PlayingCount)
//                        UserDefaults.standard.synchronize()
//                    }
//                }
//            }
//            if Int(time) % AdmobTool.instance.playMiddleTime == 0 {
//                ESBaseTool.instance.adsPlayState = .playTen
//                AdmobTool.instance.show(.mode_play) { [weak self] success in
//                    guard let self = self else { return }
//                    if success {
//                        self.pause()
//                        let count = UserDefaults.standard.integer(forKey: ES_OpenVipPop)
//                        UserDefaults.standard.set(count + 1, forKey: ES_OpenVipPop)
//                        UserDefaults.standard.synchronize()
//                    }
//                }
//            }
//            let total = ceil(totalDuration)
//            if Int(time) == Int(total * 0.3), total >= 15, self.showPopLoad == false {
//                self.loadPopupHander?()
//                self.showPopLoad = true
//            }
        }
    }

    private var oldDuration: TimeInterval = .zero
    
    private(set) var playbackProgress: CGFloat = .zero {
        didSet {
            guard playbackProgress != oldValue else { return }
            contentView.setSliderProgress(Float(playbackProgress), animated: false)
            let oldIntValue = Int(oldValue * 100)
            let intValue = Int(playbackProgress * 100)
            if intValue != oldIntValue {
                DispatchQueue.main.async {
                    self.playProgressChanged?(CGFloat(intValue) / 100)
                }
            }
        }
    }

    private(set) var rate: Float = 1.0 {
        didSet {
            player?.rate = rate
            pause()
            isUserPause = false
            play()
        }
    }
    
    weak var placeholder: UIView? {
        didSet {
            contentView.placeholderView = placeholder
        }
    }

    var isFullScreen: Bool {
        return contentView.screenState == .fullScreen
    }

    var isPlaying: Bool {
        return contentView.playState == .playing
    }

    var isBuffering: Bool {
        return contentView.playState == .buffering
    }

    var isFailed: Bool {
        return contentView.playState == .failed
    }

    var isPaused: Bool {
        return contentView.playState == .pause
    }

    var isEnded: Bool {
        return contentView.playState == .ended
    }

    var title: NSMutableAttributedString? {
        didSet {
            guard let title = title else { return }
            contentView.title = title
        }
    }

    var url: URL? {
        didSet {
            guard let url = url else { return }
            stop()
            self.showPopLoad = false
            let session = AVAudioSession.sharedInstance()
            do {
                try session.setCategory(.playback)
                try session.setActive(true)
            } catch {
                print("set session error:\(error)")
            }
            playerItem = AVPlayerItem(asset: AVURLAsset(url: url))
            player = AVPlayer(playerItem: playerItem)
            (layer as? AVPlayerLayer)?.player = player
            contentView.soundPlayer = player
            contentView.showToolView()
        }
    }

    var playFailed: ((Error?) -> Void)?

    var backButtonTappedHandler: (() -> Void)?

    var playToEndHandler: (() -> Void)?

    var playChangeRate: ((Float) -> Void)?

    var playProgressChanged: ((CGFloat) -> Void)?

    var nextButtonTappedHandler: (() -> Void)?

    var downButtonTappedHandler: (() -> Void)?
    
    var vipButtonTappedHandler: ((Bool) -> Void)?

    var moreButtonTappedHandler: ((Bool) -> Void)?

    var playSuccessTappedHandler: (() -> Void)?
    
    var loadPopupHander: (() -> Void)?
}

// MARK: - JmoVxia---override

extension HUBPlayerView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.classForCoder()
    }
}

// MARK: - JmoVxia---布局

private extension HUBPlayerView {
    func initSubViews() {
        backgroundColor = .black
        addSubview(contentView)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: UIApplication.willResignActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayground), name: UIApplication.didBecomeActiveNotification, object: nil)
        if !UIDevice.current.isGeneratingDeviceOrientationNotifications {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        }
        NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange), name: UIDevice.orientationDidChangeNotification, object: nil)
    }

    func makeConstraints() {
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}

// MARK: - JmoVxia---objc

@objc private extension HUBPlayerView {
    func didPlaybackEnds() {
        currentDuration = totalDuration
        playbackProgress = 1.0
        contentView.playState = .ended
        sliderTimer?.pause()
        DispatchQueue.main.async {
            self.playToEndHandler?()
        }
    }

    func deviceOrientationDidChange() {
        guard config.rotateStyle != .none else { return }
        if config.rotateStyle == .small, isFullScreen { return }
        if config.rotateStyle == .fullScreen, !isFullScreen { return }
        DispatchQueue.main.async {
            switch UIDevice.current.orientation {
            case .portrait:
                self.dismiss(complete: {})
            case .landscapeLeft:
                self.presentWithOrientation(.left)
            case .landscapeRight:
                self.presentWithOrientation(.right)
            default:
                break
            }
        }
    }

    func appDidEnterBackground() {
        isEnterBackground = true
        pause()
    }

    func appDidEnterPlayground() {
        isEnterBackground = false
//        if let vc = HubTool.share.keyVC(), vc.isKind(of: VideoPlayController.self) || vc.isKind(of: FullScreenController.self) || vc.isKind(of: PlayListController.self) || vc.isKind(of: PlayListFullController.self) {
//            play()
//        }
        play()
    }
}

// MARK: - JmoVxia---observe

private extension HUBPlayerView {
    func observeStatusAction() {
        guard let playerItem = playerItem else { return }
        if playerItem.status == .readyToPlay {
            contentView.playState = .readyToPlay
//            EventTool.instance.addEvent(type: .custom, event: .playStartAll, paramter: nil)
//            EventTool.instance.addEvent(type: .custom, event: .playSuc, paramter: nil)
//
//            if PlayManager.instance.auto == false {
//                EventTool.instance.addEvent(type: .custom, event: .playSource, paramter: [EventParaName.value.rawValue: ESBaseTool.instance.playSource.rawValue])
//            }
            totalDuration = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)

            self.playSuccessTappedHandler?()
            sliderTimer = PlayTimer(interval: 0.1)
            sliderTimer?.run { [weak self] _ in
                self?.sliderTimerAction()
            }

            loadedTimeRangesObserve = playerItem.observe(\.loadedTimeRanges, options: [.new]) { [weak self] _, _ in
                self?.observeLoadedTimeRangesAction()
            }

            playbackBufferEmptyObserve = playerItem.observe(\.isPlaybackBufferEmpty, options: [.new]) { [weak self] _, _ in
                self?.observePlaybackBufferEmptyAction()
            }
            if let seekTime {
                player?.seek(to: seekTime.time, toleranceBefore: seekTime.toleranceBefore, toleranceAfter: seekTime.toleranceAfter)
                self.seekTime = nil
            }

            switch waitReadyToPlayState {
            case .nomal:
                break
            case .pause:
                pause()
            case .play:
//                if HubTool.instance.showAdomb == false {
//                    play()
//                } else {
//                    pause()
//                }
                play()
            }
        } else if playerItem.status == .failed {
//            EventTool.instance.addEvent(type: .custom, event: .playStartAll, paramter: nil)
//            EventTool.instance.addEvent(type: .custom, event: .playFail, paramter: [EventParaName.value.rawValue: playerItem.error?.localizedDescription ?? "request fail!"])
//            if PlayManager.instance.auto == false {
//                EventTool.instance.addEvent(type: .custom, event: .playSource, paramter: [EventParaName.value.rawValue: ESBaseTool.instance.playSource.rawValue])
//            }
            contentView.playState = .failed
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.playFailed?(playerItem.error)
            }
        }
    }

    func observeLoadedTimeRangesAction() {
        guard let timeInterval = availableDuration() else { return }
        guard let duration = playerItem?.duration else { return }
        let totalDuration = TimeInterval(CMTimeGetSeconds(duration))
        contentView.setProgress(Float(timeInterval / totalDuration), animated: false)
    }

    func observePlaybackBufferEmptyAction() {
        guard playerItem?.isPlaybackBufferEmpty ?? false else { return }
        bufferingSomeSecond()
    }
}

private extension HUBPlayerView {
    func availableDuration() -> TimeInterval? {
        guard let timeRange = playerItem?.loadedTimeRanges.first?.timeRangeValue else { return nil }
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSeconds = CMTimeGetSeconds(timeRange.duration)
        return .init(startSeconds + durationSeconds)
    }

    func bufferingSomeSecond() {
        guard playerItem?.status == .readyToPlay else { return }
        guard contentView.playState != .failed else { return }

        player?.pause()
        sliderTimer?.pause()

        contentView.playState = .buffering
        bufferTimer = PlayTimer(interval: 3.0, initialDelay: 3.0)
        bufferTimer?.run { [weak self] _ in
            guard let playerItem = self?.playerItem else { return }
            self?.bufferTimer = nil
            if playerItem.isPlaybackLikelyToKeepUp {
                self?.play()
            } else {
                self?.bufferingSomeSecond()
            }
        }
    }

    func sliderTimerAction() {
        guard let playerItem = playerItem else { return }
        guard playerItem.duration.timescale != .zero else { return }

        currentDuration = CMTimeGetSeconds(playerItem.currentTime())
        playbackProgress = currentDuration / totalDuration
    }
}

// MARK: - JmoVxia---Screen

extension HUBPlayerView {
    func findTop(from rootViewController: UIViewController?) -> UIViewController? {
        guard let root = rootViewController else { return nil }
        if let nav = root as? UINavigationController { return findTop(from: nav.visibleViewController) }
        if let tab = root as? UITabBarController, let selected = tab.selectedViewController { return findTop(from: selected) }
        if let presented = root.presentedViewController, !(presented is UIAlertController) { return findTop(from: presented) }
        return root
    }

    func dismiss(complete: @escaping() -> Void) {
        guard Thread.isMainThread else { return DispatchQueue.main.async { self.dismiss {
            complete()
        } } }
        guard contentView.screenState == .fullScreen else { return }
        if let vc = HubTool.share.keyVC(), vc.isKind(of: PlayListFullController.self)  {
            vc.dismiss(animated: false) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.quitFullScreenPlay()
                    complete()
                }
            }
        }  else {
            self.quitFullScreenPlay()
            complete()
        }
    }
    
    func quitFullScreenPlay() {
        guard let controller = fullScreenController else { return }
        contentView.screenState = .animating
        controller.dismiss(animated: true, completion: {
            self.contentView.screenState = .small
            self.fullScreenController = nil
        })
    }

    func presentWithOrientation(_ orientation: HUBAnimationTransition.AnimationOrientation) {
        guard Thread.isMainThread else { return DispatchQueue.main.async { self.presentWithOrientation(orientation) } }
        guard superview != nil else { return }
        guard fullScreenController == nil else { return }
//        guard ESBaseTool.instance.showAdomb == false else { return }
        guard contentView.screenState == .small else { return }
        guard let topController = findTop(from: keyWindow?.rootViewController) else { return }
        if topController.isKind(of: PlayListController.self) {
            topController.dismiss(animated: false) {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    self.closeListPage(topController, orientation)
                }
            }
        } else {
            self.closeListPage(topController, orientation)
        }
    }
    
    func closeListPage(_ vc: UIViewController, _ orientation: HUBAnimationTransition.AnimationOrientation) {
        contentView.screenState = .animating
        animationTransitioning = HUBAnimationTransition(playerView: self, animationOrientation: orientation)

        fullScreenController = orientation == .right ? FullScreenLeftController() : FullScreenRightController()
        fullScreenController?.transitioningDelegate = self
        fullScreenController?.modalPresentationStyle = .fullScreen
        vc.present(fullScreenController!, animated: true, completion: {
            self.contentView.screenState = .fullScreen
        })
    }
}

// MARK: - JmoVxia---公共方法

extension HUBPlayerView {
    func play() {
        guard !isEnterBackground else { return }
        guard !isUserPause else { return }
//        guard ESBaseTool.instance.showAdomb == false else { return }
        guard let playerItem = playerItem else { return }
        guard playerItem.status == .readyToPlay else {
            contentView.playState = .waiting
            waitReadyToPlayState = .play
            return
        }
        guard playerItem.isPlaybackLikelyToKeepUp else {
            bufferingSomeSecond()
            return
        }
        if contentView.playState == .ended {
            player?.seek(to: CMTimeMake(value: 0, timescale: 1), toleranceBefore: .zero, toleranceAfter: .zero)
            self.contentView.currentRate = 1.0
            self.rate = 1.0
            contentView.playState = .playing
            sliderTimer?.resume()
            waitReadyToPlayState = .nomal
            bufferTimer = nil
        } else {
            contentView.playState = .playing
            player?.play()
            player?.rate = rate
            sliderTimer?.resume()
            waitReadyToPlayState = .nomal
            bufferTimer = nil
        }
        player?.play()
    }

    func pause() {
        guard playerItem?.status == .readyToPlay else {
            waitReadyToPlayState = .pause
            return
        }
        contentView.playState = .pause
        player?.pause()
        sliderTimer?.pause()
        bufferTimer = nil
        waitReadyToPlayState = .nomal
    }

    func stop() {
        statusObserve?.invalidate()
        loadedTimeRangesObserve?.invalidate()
        playbackBufferEmptyObserve?.invalidate()

        statusObserve = nil
        loadedTimeRangesObserve = nil
        playbackBufferEmptyObserve = nil

        playerItem = nil
        player = nil

        isUserPause = false

        waitReadyToPlayState = .nomal

        contentView.playState = .unknow
        contentView.setProgress(0, animated: false)
        playbackProgress = 0
        totalDuration = 0
        currentDuration = 0
        sliderTimer = nil
        seekTime = nil
    }

    func seek(to time: HUBPlayer.HUBPlayerSeek) {
        if contentView.playState.canFastForward {
            player?.seek(to: time.time, toleranceBefore: time.toleranceBefore, toleranceAfter: time.toleranceAfter)
        } else {
            seekTime = time
        }
    }
    
    func resetRate() {
        self.contentView.currentRate = 1.0
        self.rate = 1.0
    }
}

// MARK: - JmoVxia---UIViewControllerTransitioningDelegate

extension HUBPlayerView: UIViewControllerTransitioningDelegate {
    func animationController(forPresented _: UIViewController, presenting _: UIViewController, source _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationTransitioning?.animationType = .present
        return animationTransitioning
    }

    func animationController(forDismissed _: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationTransitioning?.animationType = .dismiss
        return animationTransitioning
    }
}

// MARK: - JmoVxia---ESPlayerContentViewDelegate

extension HUBPlayerView: HUBPlayerContentViewDelegate {
    func contentView(_ contentView: HUBPlayerContentView, didClickPlayButton isPlay: Bool) {
        isUserPause = isPlay
        isPlay ? pause() : play()
    }

    func contentView(_ contentView: HUBPlayerContentView, didClickFullButton isFull: Bool) {
        isFull ? dismiss(complete: {}) : presentWithOrientation(.fullRight)
    }

    
    func contentView(_ contentView: HUBPlayerContentView, didChangeRate rate: Float) {
        self.rate = rate
    }

    func contentView(_ contentView: HUBPlayerContentView, didChangeVideoGravity videoGravity: AVLayerVideoGravity) {
        (layer as? AVPlayerLayer)?.videoGravity = videoGravity
    }

    func contentView(_ contentView: HUBPlayerContentView, sliderTouchBegan slider: PlayerSlider) {
        self.oldDuration = currentDuration
        pause()
    }

    func contentView(_ contentView: HUBPlayerContentView, sliderValueChanged slider: PlayerSlider) {
        currentDuration = totalDuration * TimeInterval(slider.value)
        let time = CMTimeMake(value: Int64(ceil(currentDuration)), timescale: 1)
        player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
        contentView.setTimeDetailDuration(self.oldDuration, currentDuration)
    }

    func contentView(_ contentView: HUBPlayerContentView, sliderTouchEnded slider: PlayerSlider) {
        guard let playerItem = playerItem else { return }
        if slider.value == 1 {
            didPlaybackEnds()
        } else if playerItem.isPlaybackLikelyToKeepUp {
            play()
        } else {
            bufferingSomeSecond()
        }
    }

    func contentView(_ contentView: HUBPlayerContentView, forWardOrBack forward: Bool) {
        let current = Int(ceil(self.currentDuration))
        let total = Int(ceil(self.totalDuration))
        if forward {
            if total - current > 10 {
                let time = CMTimeMake(value: 10, timescale: 1)
                player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            } else {
                let time = CMTimeMake(value: Int64(ceil(self.totalDuration)), timescale: 1)
                player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        } else {
            if current > 10 {
                let time = CMTimeMake(value: Int64(ceil(currentDuration - 10)), timescale: 1)
                player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            } else {
                let time = CMTimeMake(value: 0, timescale: 1)
                player?.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
            }
        }
        contentView.setDisplayDuration(forward)
    }
    
    func didClickFailButton(in _: HUBPlayerContentView) {
        guard let url = url else { return }
        self.url = url
    }

    func didClickBackButton(in contentView: HUBPlayerContentView) {
        DispatchQueue.main.async {
            if (contentView.screenState == .fullScreen) {
                self.dismiss(complete: {})
            } else {
                self.backButtonTappedHandler?()
            }
        }
    }
    
    func didClickDownButton(in _: HUBPlayerContentView) {
        self.downButtonTappedHandler?()
    }
    
    func didClickNextButton(in _: HUBPlayerContentView) {
        self.nextButtonTappedHandler?()
    }
    
    func contentView(_ contentView: HUBPlayerContentView, didClickVipButton auto: Bool) {
        self.vipButtonTappedHandler?(auto)
    }
    
    func contentView(_ contentView: HUBPlayerContentView, didClickMoreButton isFull: Bool) {
        self.moreButtonTappedHandler?(isFull)
    }
}

