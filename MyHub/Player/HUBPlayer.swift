//
//  HUBPlayer.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import AVFoundation
import UIKit

// MARK: - HUBPlayer---扩展
public extension HUBPlayer {
    struct HUBPlayerSeek {
        let time: CMTime
        var toleranceBefore: CMTime = .zero
        var toleranceAfter: CMTime = .zero
    }
}

// MARK: - HUBPlayer---布局
private extension HUBPlayer {
    func initSubViews() {
        insetsLayoutMarginsFromSafeArea = false
        distribution = .fill
        alignment = .fill
        addArrangedSubview(playerView)
    }

    func makeConstraints() {}
}

// MARK: - ES_Player---类-属性
public class HUBPlayer: UIStackView {
    public init(frame: CGRect = .zero, config: ((inout HUBPlayerConfigure) -> Void)? = nil) {
        super.init(frame: frame)
        config?(&self.config)
        initSubViews()
        makeConstraints()
    }

    @available(*, unavailable)
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    lazy var playerView: HUBPlayerView = {
        let view = HUBPlayerView(config: config)
        view.backButtonTappedHandler = { [weak self] in
            guard let self else { return }
            self.delegate?.playerDidClickBackButton(self)
        }
        view.playToEndHandler = { [weak self] in
            guard let self else { return }
            self.delegate?.playerDidFinishPlaying(self)
        }
        view.playProgressChanged = { [weak self] value in
            guard let self else { return }
            self.delegate?.player(self, didUpdateProgress: value)
        }
        view.playFailed = { [weak self] error in
            guard let self else { return }
            self.delegate?.player(self, didFailWithError: error)
        }
        view.downButtonTappedHandler = {[weak self] in
            guard let self else { return }
            self.delegate?.playerDidClickDownButton(self)
        }
        view.vipButtonTappedHandler = {[weak self] auto in
            guard let self else { return }
            self.delegate?.player(self, didClickVip: auto)
        }
        view.moreButtonTappedHandler = {[weak self] full in
            guard let self else { return }
            self.delegate?.player(self, didClickMore: full)
        }
        
        view.playSuccessTappedHandler = {[weak self] in
            guard let self else { return }
            self.delegate?.playerSuccessPlaying(self)
        }
        view.nextButtonTappedHandler = {[weak self] in
            guard let self else { return }
            self.delegate?.playerDidClickNextButton(self)
        }
        view.playChangeRate = {[weak self] rate in
            guard let self else { return }
            self.delegate?.player(self, changeRate: rate)
        }
        
        view.loadPopupHander = {[weak self] in
            guard let self else { return }
            self.delegate?.playerLoadPop(self)
        }
        return view
    }()

    private var config = HUBPlayerConfigure()
    
    public var playbackProgress: CGFloat {
        playerView.playbackProgress
    }
    
    public var currentDuration: TimeInterval {
        playerView.currentDuration
    }

    public var totalDuration: TimeInterval {
        playerView.totalDuration
    }

    public var rate: Float {
        playerView.rate
    }

    public var isFullScreen: Bool {
        playerView.contentView.screenState == .fullScreen
    }

    public var isPlaying: Bool {
        playerView.contentView.playState == .playing
    }

    public var isBuffering: Bool {
        playerView.contentView.playState == .buffering
    }

    public var isFailed: Bool {
        playerView.contentView.playState == .failed
    }

    public var isPaused: Bool {
        playerView.contentView.playState == .pause
    }

    public var isEnded: Bool {
        playerView.contentView.playState == .ended
    }

    public var title: NSMutableAttributedString? {
        didSet {
            guard let title = title else { return }
            playerView.contentView.title = title
        }
    }

    public var url: URL? {
        didSet {
            guard let url = url else { return }
            playerView.url = url
        }
    }

    public weak var placeholder: UIView? {
        didSet {
            playerView.contentView.placeholderView = placeholder
        }
    }

    public weak var delegate: HUBPlayerDelegate?
}

// MARK: - ES_Player---公共方法
public extension HUBPlayer {
    func seek(to time: HUBPlayerSeek) {
        playerView.seek(to: time)
    }
    
    func stop() {
        playerView.stop()
    }
    
    func play() {
        playerView.play()
    }

    func pause() {
        playerView.pause()
    }
}

