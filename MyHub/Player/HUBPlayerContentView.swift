//
//  HUBPlayerContentView.swift
//  MyHub
//
//  Created by hub on 2/11/26.
//

import AVFoundation
import MediaPlayer
import SnapKit
import UIKit

// MARK: - PlayContent---枚举

extension HUBPlayerContentView {
    enum HUBPlayerScreenState {
        case small
        case animating
        case fullScreen
    }

    enum HUBPlayerPlayState {
        case unknow
        case waiting
        case readyToPlay
        case playing
        case buffering
        case failed
        case pause
        case ended
        var canFastForward: Bool {
            switch self {
            case .unknow, .waiting, .failed:
                return false
            case .readyToPlay, .playing, .pause, .buffering, .ended:
                return true
            }
        }
    }

    enum ES_PanDirection {
        case unknow
        case horizontal
        case leftVertical
        case rightVertical
    }
}

class HUBPlayerContentView: UIView {
    init(config: HUBPlayerConfigure) {
        self.config = config
        super.init(frame: .zero)
        addSubViews()
        addConstraints()
        addConfig()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private lazy var placeholderStackView: UIStackView = {
        let view = UIStackView()
        view.isHidden = true
        view.axis = .horizontal
        view.distribution = .fill
        view.alignment = .fill
        view.insetsLayoutMarginsFromSafeArea = false
        view.isLayoutMarginsRelativeArrangement = true
        view.layoutMargins = .zero
        view.spacing = 0
        return view
    }()
    
    private let topToolView: UIView = UIView()

    private let bottomToolView: UIView = UIView()

    private let bottomContentView: UIView = UIView()

//    lazy var loadingView: ESRotateAnimationView = {
//        let view = ESRotateAnimationView(frame: .init(x: 0, y: 0, width: 40, height: 40))
//        view.startAnimation()
//        return view
//    }()
    var soundPlayer: AVPlayer?
    private var isShowLoad: Bool = false {
        didSet {
            if isShowLoad {
                self.hiddenToolView()
            }
        }
    }
    
    lazy var loadingView: HUBPlayLoadView = HUBPlayLoadView.view()
    
    private lazy var backButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(backButtonAction), for: .touchUpInside)
        return view
    }()

    private let titleLabel: UILabel = UILabel()
    
    private lazy var vipButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(vipButtonAction), for: .touchUpInside)
        return view
    }()
    
    private lazy var moreButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(moreButtonAction), for: .touchUpInside)
        return view
    }()

    private lazy var playButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(playButtonAction(_:)), for: .touchUpInside)
        return view
    }()

    lazy var nextButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(nextButtonAction), for: .touchUpInside)
        return view
    }()
    
    private lazy var fullButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(fullButtonAction(_:)), for: .touchUpInside)
        return view
    }()

    private lazy var downButton: UIButton = {
        let view = UIButton()
        view.addTarget(self, action: #selector(downButtonAction), for: .touchUpInside)
        return view
    }()
    
    var downState: HUB_FileState = .normal {
        didSet {
            switch downState {
            case .downing, .downWait:
                self.downButton.isEnabled = false
                self.downButton.setImage(config.image.downing, for: .normal)
            case .downDone:
                self.downButton.isEnabled = false
                self.downButton.setImage(config.image.downDone, for: .normal)
            default:
                self.downButton.isEnabled = true
                self.downButton.setImage(config.image.down, for: .normal)
            }
        }
    }
    private lazy var rateButton: UIButton = {
        let btn = UIButton()
        btn.setTitle("1.0x", for: .normal)
        btn.titleLabel?.font = UIFont.GoogleSans(weight: .regular, size: 14)
        btn.setTitleColor(.white, for: .normal)
        btn.layer.cornerRadius = 8
        btn.layer.borderColor = UIColor.white.cgColor
        btn.layer.borderWidth = 2
        btn.layer.masksToBounds = true
        btn.backgroundColor = .clear
        btn.addTarget(self, action: #selector(rateButtonAction), for: .touchUpInside)
        return btn
    }()
    
    private lazy var currentDurationLabel: UILabel = {
        let view = UILabel()
        view.text = "00:00"
        view.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        view.textColor = .white
        view.textAlignment = .center
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()

    private lazy var totalDurationLabel: UILabel = {
        let view = UILabel()
        view.text = "00:00"
        view.font = .monospacedDigitSystemFont(ofSize: 14, weight: .regular)
        view.textColor = .white
        view.textAlignment = .center
        view.setContentCompressionResistancePriority(.required, for: .horizontal)
        view.setContentHuggingPriority(.required, for: .horizontal)
        return view
    }()

    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 1
        view.trackTintColor = .white.withAlphaComponent(0.25)
        view.progressTintColor = .white.withAlphaComponent(0.5)
        return view
    }()

    private lazy var sliderView: PlayerSlider = {
        let view = PlayerSlider()
        view.isUserInteractionEnabled = false
        view.maximumValue = 1
        view.minimumValue = 0
        view.minimumTrackTintColor = .white
        view.addTarget(self, action: #selector(fixSliderrTouchBegan(_:)), for: .touchDown)
        view.addTarget(self, action: #selector(fixSliderrValueChanged(_:)), for: .valueChanged)
        view.addTarget(self, action: #selector(fixSliderrTouchEnded(_:)), for: [.touchUpInside, .touchCancel, .touchUpOutside])
        return view
    }()

    private lazy var leftV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var rightV: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private lazy var tapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(tapAction))
        gesture.delegate = self
        return gesture
    }()

    private lazy var leftTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(leftTapAction))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        return gesture
    }()
    
    private lazy var rightTapGesture: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(rightTapAction))
        gesture.numberOfTapsRequired = 2
        gesture.delegate = self
        return gesture
    }()
    
    private lazy var panGesture: UIPanGestureRecognizer = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(panDirection(_:)))
        gesture.maximumNumberOfTouches = 1
        gesture.delaysTouchesBegan = true
        gesture.delaysTouchesEnded = true
        gesture.cancelsTouchesInView = true
//        gesture.delegate = self
        return gesture
    }()

    private lazy var volumeSlider: UISlider? = {
        let view = MPVolumeView(frame: CGRectMake(-100, -100, 1, 1))
        view.alpha = 0.01
        view.isUserInteractionEnabled = false
        return view.subviews.first(where: { $0 is UISlider }) as? UISlider
    }()

    private let lightV: HUBLightView = HUBLightView()
    private let displayTimeV: HUBForwardView = HUBForwardView()
    private let timeDatailV: HUBPlayTimeView = HUBPlayTimeView()
    private var config: HUBPlayerConfigure!

    private var isShowMorePanel: Bool = false {
        didSet {
            guard isShowMorePanel != oldValue else { return }
            if isShowMorePanel {
                hiddenToolView()
            } else {
                if screenState == .fullScreen {
                    showToolView()
                }
            }
            UIView.animate(withDuration: 0.25) {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }

    private var isHiddenToolView: Bool = true

    private var panDirection: ES_PanDirection = .unknow

    private var autoFadeOutTimer: PlayTimer?

    private var rates: [Float] = [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0]

    private var videoGravity: [(name: String, mode: AVLayerVideoGravity)] = [("适应", .resizeAspect), ("拉伸", .resizeAspectFill), ("填充", .resize)]

    private let morePanelWidth: CGFloat = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height) * 0.382

    private let rateView: HUBRateView = HUBRateView.view()
    private var isShowRateV: Bool = false
    
    private var screenFull = false
    weak var delegate: HUBPlayerContentViewDelegate?

    weak var placeholderView: UIView? {
        didSet {
            guard placeholderView != oldValue else { return }
            placeholderStackView.isHidden = placeholderView == nil
            if let newView = placeholderView {
                placeholderStackView.addArrangedSubview(newView)
            }
            guard let oldView = oldValue else { return }
            placeholderStackView.removeArrangedSubview(oldView)
        }
    }

    var title: NSMutableAttributedString? {
        didSet {
            guard let title = title else { return }
            titleLabel.attributedText = title
        }
    }

    var currentRate: Float = 1.0 {
        didSet {
            guard currentRate != oldValue else { return }
            self.rateButton.setTitle("\(currentRate)x", for: .normal)
            delegate?.contentView(self, didChangeRate: currentRate)
        }
    }

    var currentVideoGravity: AVLayerVideoGravity = .resizeAspectFill {
        didSet {
            guard currentVideoGravity != oldValue else { return }
            delegate?.contentView(self, didChangeVideoGravity: currentVideoGravity)
        }
    }

    var screenState: HUBPlayerScreenState = .small {
        didSet {
            guard screenState != oldValue else { return }
            switch screenState {
            case .small:
//                topToolView.isHidden = config.topBarHiddenStyle != .never
                hiddenMorePanel()
            case .animating:
                break
            case .fullScreen:
                break
//                topToolView.isHidden = config.topBarHiddenStyle == .always
            }
        }
    }

    var playState: HUBPlayerPlayState = .unknow {
        didSet {
            guard playState != oldValue else { return }
            switch playState {
            case .unknow:
                sliderView.isUserInteractionEnabled = false
                playButton.isSelected = false
                placeholderStackView.isHidden = placeholderView == nil
                self.isShowLoad = true
                loadingView.start()
            case .waiting:
                sliderView.isUserInteractionEnabled = false
                placeholderStackView.isHidden = true
                self.isShowLoad = true
                loadingView.start()
            case .readyToPlay:
                sliderView.isUserInteractionEnabled = true
            case .playing:
                sliderView.isUserInteractionEnabled = true
                playButton.isSelected = true
                placeholderStackView.isHidden = true
                self.isShowLoad = false
                loadingView.stop()
            case .buffering:
                sliderView.isUserInteractionEnabled = true
                placeholderStackView.isHidden = true
                self.isShowLoad = true
                loadingView.start()
            case .failed:
                sliderView.isUserInteractionEnabled = false
                self.isShowLoad = false
                loadingView.stop()
            case .pause:
                sliderView.isUserInteractionEnabled = true
                playButton.isSelected = false
            case .ended:
                sliderView.isUserInteractionEnabled = true
                playButton.isSelected = false
                placeholderStackView.isHidden = placeholderView == nil
                self.isShowLoad = false
                loadingView.stop()
            }
        }
    }
    
    func showLoading() {
        self.soundPlayer?.pause()
        self.isShowLoad = true
//        loadingView.pushVip = true
        loadingView.start()
    }
}

// MARK: - PlayContent---布局
private extension HUBPlayerContentView {
    func addSubViews() {
        clipsToBounds = true
        autoresizesSubviews = true
        isUserInteractionEnabled = true

        addSubview(leftV)
        addSubview(rightV)
        addSubview(topToolView)
        addSubview(bottomToolView)
        addSubview(loadingView)
        
        topToolView.addSubview(backButton)
        topToolView.addSubview(titleLabel)
        topToolView.addSubview(vipButton)
        topToolView.addSubview(moreButton)
        bottomToolView.addSubview(bottomContentView)

        bottomContentView.addSubview(playButton)
        bottomContentView.addSubview(nextButton)
        bottomContentView.addSubview(fullButton)
        bottomContentView.addSubview(downButton)
        bottomContentView.addSubview(rateButton)
        bottomContentView.addSubview(currentDurationLabel)
        bottomContentView.addSubview(totalDurationLabel)
        bottomContentView.addSubview(progressView)
        bottomContentView.addSubview(sliderView)

        addSubview(placeholderStackView)
        addSubview(rateView)
        addSubview(lightV)
        addSubview(displayTimeV)
        addSubview(timeDatailV)
        
        rateView.clickBlock = { [weak self] state in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isShowRateV = false
                self.currentRate = state.rawValue
            }
        }
        
        if let window = HubTool.share.keyWindow, let v = self.volumeSlider {
            v.frame = CGRectMake(-100, -100, 1, 1)
            window.addSubview(v)
        }
        
        addGestureRecognizer(tapGesture)
        self.leftV.addGestureRecognizer(leftTapGesture)
        self.rightV.addGestureRecognizer(rightTapGesture)

        tapGesture.require(toFail: leftTapGesture)
        tapGesture.require(toFail: rightTapGesture)

        addGestureRecognizer(panGesture)

        loadingView.clickBlock = { [weak self] click  in
            guard let self = self else { return }
            if click {
                self.delegate?.contentView(self, didClickVipButton: true)
            } else {
                self.soundPlayer?.play()
            }
        }
        loadingView.stateBlock = {[weak self] in
            guard let self = self else { return }
            self.isShowLoad = false
        }
        guard !config.isHiddenToolbarWhenStart else { return }
        autoFadeOutTooView()
    }

    func addConstraints() {
        leftV.snp.makeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.width.equalTo(ScreenWidth * 0.4)
        }
        
        rightV.snp.makeConstraints { make in
            make.right.top.bottom.equalToSuperview()
            make.width.equalTo(ScreenWidth * 0.4)
        }
        
        topToolView.snp.makeConstraints { make in
            make.top.equalTo(TopSafeH)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        bottomToolView.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(-BottomSafeH)
        }
  
        bottomContentView.snp.makeConstraints { make in
            make.left.right.top.equalToSuperview()
            make.height.equalTo(60)
            make.bottom.equalToSuperview()
        }
        
        loadingView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        backButton.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
        }
        titleLabel.snp.makeConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(15)
            make.right.equalTo(vipButton.snp.left).offset(-15)
            make.centerY.height.equalToSuperview()
        }
        vipButton.snp.makeConstraints { make in
            make.right.equalTo(moreButton.snp.left).offset(-15)
            make.size.equalTo(CGSize(width: 56, height: 24))
            make.centerY.equalToSuperview()
        }
        moreButton.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.size.equalTo(40)
            make.centerY.equalToSuperview()
        }
        playButton.snp.makeConstraints { make in
            make.left.equalTo(8)
            make.size.equalTo(40)
            make.bottom.equalToSuperview()
        }
        nextButton.snp.makeConstraints { make in
            make.left.equalTo(self.playButton.snp.right).offset(4)
            make.size.equalTo(40)
            make.centerY.equalTo(playButton)
        }
        fullButton.snp.makeConstraints { make in
            make.right.equalTo(-8)
            make.size.equalTo(40)
            make.centerY.equalTo(playButton)
        }
        
        downButton.snp.makeConstraints { make in
            make.right.equalTo(self.fullButton.snp.left).offset(-4)
            make.size.equalTo(40)
            make.centerY.equalTo(playButton)
        }
        
        rateButton.snp.makeConstraints { make in
            make.right.equalTo(self.downButton.snp.left).offset(-12)
            make.size.equalTo(CGSize(width: 54, height: 24))
            make.centerY.equalTo(playButton)
        }
        
        rateView.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(80, 192))
            make.centerX.equalTo(rateButton)
            make.bottom.equalTo(rateButton.snp.top).offset(-12)
        }
        
        lightV.snp.makeConstraints { make in
            make.size.equalTo(CGSizeMake(156, 32))
            make.centerX.equalToSuperview()
            make.top.equalTo(120)
        }
        
        displayTimeV.snp.makeConstraints { make in
            make.height.equalTo(32)
            make.centerX.equalToSuperview()
            make.top.equalTo(120)
        }
        
        timeDatailV.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.height.equalTo(32)
        }
        
        currentDurationLabel.snp.makeConstraints { make in
            make.left.equalTo(10)
            make.top.equalToSuperview()
        }
        totalDurationLabel.snp.makeConstraints { make in
            make.right.equalTo(-10)
            make.top.equalToSuperview()
        }
        
        progressView.snp.makeConstraints { make in
            make.left.equalTo(currentDurationLabel.snp.right).offset(15 + config.thumbImageOffset)
            make.centerY.equalTo(currentDurationLabel)
            make.height.equalTo(2)
            make.right.equalTo(totalDurationLabel.snp.left).offset(-15 - config.thumbImageOffset)
        }
        sliderView.snp.makeConstraints { make in
            make.left.equalTo(progressView).offset(-1)
            make.right.equalTo(progressView).offset(1)
            make.height.equalTo(20)
            make.centerY.equalTo(progressView)
        }

        placeholderStackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }

    func addConfig() {
        currentVideoGravity = config.videoGravity
//        topToolView.isHidden = screenState == .small ? config.topBarHiddenStyle != .never : config.topBarHiddenStyle == .always

        topToolView.backgroundColor = config.color.topToobar
        bottomToolView.backgroundColor = config.color.bottomToolbar
        progressView.trackTintColor = config.color.progress
        progressView.progressTintColor = config.color.progressBuffer
        sliderView.minimumTrackTintColor = config.color.progressFinished
//        loadingView.updateWithConfigure { $0.backgroundColor = self.config.color.loading }

        backButton.setImage(config.image.back, for: .normal)
        vipButton.setImage(config.image.vip, for: .normal)
        moreButton.setImage(config.image.more, for: .normal)
        playButton.setImage(config.image.play, for: .normal)
        playButton.setImage(config.image.pause, for: .selected)
        nextButton.setImage(config.image.next, for: .normal)
        nextButton.setImage(config.image.unNext, for: .disabled)
        fullButton.setImage(config.image.full, for: .normal)
        fullButton.setImage(config.image.full, for: .selected)
        downButton.setImage(config.image.down, for: .normal)
//        downButton.setImage(config.image.downing, for: .selected)
//        downButton.setImage(config.image.downDone, for: .disabled)

        sliderView.setThumbImage(config.image.thumb, for: .normal)
        sliderView.verticalSliderOffset = config.thumbImageOffset
        sliderView.thumbClickableOffset = config.thumbClickableOffset
    }
}

// MARK: - PlayContent---objc
@objc private extension HUBPlayerContentView {
    func tapAction() {
        if isShowMorePanel {
            isShowMorePanel = false
        } else {
            isHiddenToolView ? showToolView() : hiddenToolView()
        }
    }

    func leftTapAction() {
        self.dismissHUBRateView()
        delegate?.contentView(self, forWardOrBack: false)
    }
    
    func rightTapAction() {
        self.dismissHUBRateView()
        delegate?.contentView(self, forWardOrBack: true)
    }
    
    func panDirection(_ pan: UIPanGestureRecognizer) {
        let locationPoint = pan.location(in: self)
        let veloctyPoint = pan.velocity(in: self)
        switch pan.state {
        case .began:
            self.dismissHUBRateView()
            if abs(veloctyPoint.x) > abs(veloctyPoint.y) {
                panDirection = .horizontal
            } else {
                panDirection = locationPoint.x < bounds.width * 0.5 ? .leftVertical : .rightVertical
            }
        case .changed:
            switch panDirection {
            case .horizontal:
                break
            case .leftVertical:
                UIScreen.main.brightness -= veloctyPoint.y / 10000
                print("light\(veloctyPoint.y / 10000)= \(UIScreen.main.brightness)")
                self.lightV.setValue(true, Float(UIScreen.main.brightness))
            case .rightVertical:
                soundPlayer?.volume -= Float(veloctyPoint.y / 10000)
                print("volumeSlider = \(soundPlayer?.volume ?? 0)")
                self.lightV.setValue(false, soundPlayer?.volume ?? 0.0)
            default:
                break
            }
        case .ended, .cancelled:
            self.lightV.isHidden = true
            panDirection = .unknow
        default:
            break
        }
    }

    func backButtonAction() {
        self.dismissHUBRateView()
        delegate?.didClickBackButton(in: self)
    }

    func vipButtonAction() {
        self.dismissHUBRateView()
        delegate?.contentView(self, didClickVipButton: false)
    }
    
    func moreButtonAction() {
        self.dismissHUBRateView()
        delegate?.contentView(self, didClickMoreButton: self.screenFull)
    }

    func playButtonAction(_ button: UIButton) {
        self.dismissHUBRateView()
        delegate?.contentView(self, didClickPlayButton: button.isSelected)
    }

    func fullButtonAction(_ button: UIButton) {
        self.dismissHUBRateView()
        delegate?.contentView(self, didClickFullButton: button.isSelected)
    }

    func downButtonAction() {
        self.dismissHUBRateView()
        delegate?.didClickDownButton(in: self)
    }
    
    func rateButtonAction() {
        print("rate------\(self.isShowRateV)")
        if self.isShowRateV == false {
            rateView.setData(HUB_RateState(rawValue: currentRate) ?? .one)
            self.isShowRateV = true
        } else {
            self.dismissHUBRateView()
        }
    }
    
    func nextButtonAction() {
        self.dismissHUBRateView()
        delegate?.didClickNextButton(in: self)
    }

    func fixSliderrTouchBegan(_ slider: PlayerSlider) {
        cancelAutoFadeOutTooView()
        delegate?.contentView(self, sliderTouchBegan: slider)
    }

    func fixSliderrValueChanged(_ slider: PlayerSlider) {
        delegate?.contentView(self, sliderValueChanged: slider)
    }

    func fixSliderrTouchEnded(_ slider: PlayerSlider) {
        autoFadeOutTooView()
        delegate?.contentView(self, sliderTouchEnded: slider)
    }
}

// MARK: - PlayContent---公共方法
extension HUBPlayerContentView {
    func animationLayout(safeAreaInsets: UIEdgeInsets, to screenState: HUBPlayerScreenState) {
        leftV.snp.updateConstraints { make in
            make.width.equalTo(screenState == .fullScreen ? ScreenHeight * 0.4 : ScreenWidth * 0.4)
        }

        rightV.snp.updateConstraints { make in
            make.width.equalTo(screenState == .fullScreen ? ScreenHeight * 0.4 : ScreenWidth * 0.4)
        }
        
        topToolView.snp.remakeConstraints { make in
            make.top.equalTo(screenState == .small ? TopSafeH : 0)
            make.left.right.equalToSuperview()
            make.height.equalTo(50)
        }
        bottomToolView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(screenState == .small ? -BottomSafeH : 0)
        }
        
        backButton.snp.updateConstraints { make in
            make.left.equalTo(safeAreaInsets.left + 10)
        }
        
        titleLabel.snp.updateConstraints { make in
            make.left.equalTo(backButton.snp.right).offset(10)
            make.right.equalTo(vipButton.snp.left).offset(-10)
        }
        
        moreButton.snp.updateConstraints { make in
            make.right.equalTo(-safeAreaInsets.left - 10)
        }
        playButton.snp.updateConstraints { make in
            make.left.equalTo(safeAreaInsets.left + 8)
        }
        
        currentDurationLabel.snp.updateConstraints { make in
            make.left.equalTo(safeAreaInsets.left + 10)
        }
        
        totalDurationLabel.snp.updateConstraints { make in
            make.right.equalTo(-safeAreaInsets.right - 10)
        }

        fullButton.snp.updateConstraints { make in
            make.right.equalTo(-safeAreaInsets.right - 8)
        }

        lightV.snp.updateConstraints { make in
            make.top.equalTo(screenState == .fullScreen ? 80 : 120)
        }
        
        displayTimeV.snp.updateConstraints { make in
            make.top.equalTo(screenState == .fullScreen ? 80 : 120)
        }
        
        fullButton.isSelected = screenState == .fullScreen
        screenFull = screenState == .fullScreen
    }

    func setProgress(_ progress: Float, animated: Bool) {
        progressView.setProgress(min(max(0, progress), 1), animated: animated)
    }

    func setSliderProgress(_ progress: Float, animated: Bool) {
        sliderView.setValue(min(max(0, progress), 1), animated: animated)
    }

    func setTotalDuration(_ totalDuration: TimeInterval) {
        totalDurationLabel.text = formatDuration(totalDuration)
    }

    func setCurrentDuration(_ currentDuration: TimeInterval) {
        currentDurationLabel.text = formatDuration(currentDuration)
    }
    
    func setDisplayDuration(_ forward: Bool) {
        self.displayTimeV.setValue(forward)
    }
    
    func setTimeDetailDuration(_ old: TimeInterval, _ new: TimeInterval) {
        let oldTime = formatDuration(old)
        var newTime: String = "00:00"
        if (old < new) {
            newTime = "[+\(formatDuration(new-old))]"
        } else {
            newTime = "[-\(formatDuration(old-new))]"
        }
        self.timeDatailV.setValue(oldTime, newTime)
    }
    
    private func dismissHUBRateView() {
        self.isShowRateV = false
        self.rateView.dismiss()
    }
}

// MARK: - PlayContent---私有方法
extension HUBPlayerContentView: UIGestureRecognizerDelegate {
    func showMorePanel() {
        isShowMorePanel = true
    }

    func hiddenMorePanel() {
        isShowMorePanel = false
    }

    func showToolView() {
        guard self.isShowLoad == false else { return }
        self.backgroundColor = UIColor.rgbHex("#000000", 0.4)
        isHiddenToolView = false
        topToolView.snp.updateConstraints { make in
            make.top.equalTo(screenFull ? 0 : TopSafeH)
        }
        bottomToolView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.bottom.equalTo(screenFull ? 0 :  -BottomSafeH)
        }
        self.backgroundColor = UIColor.rgbHex("#000000", 0.15)
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            self.autoFadeOutTooView()
        }
    }

    func hiddenToolView() {
        if self.isShowRateV {
            self.dismissHUBRateView()
            DispatchQueue.main.asyncAfter(wallDeadline: .now() + 0.5) { [weak self] in
                guard let self = self else { return }
                self.dismissToolView()
            }
        } else {
            self.dismissToolView()
        }
    }
    
    func dismissToolView() {
        isHiddenToolView = true
        topToolView.snp.updateConstraints { make in
            make.top.equalTo(-50)
        }
        bottomToolView.snp.remakeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(self.snp.bottom).offset(20)
        }
        self.backgroundColor = .clear
        UIView.animate(withDuration: 0.25, delay: 0) {
            self.setNeedsLayout()
            self.layoutIfNeeded()
        } completion: { _ in
            self.cancelAutoFadeOutTooView()
        }
    }

    func autoFadeOutTooView() {
        guard config.autoFadeOut > .zero, config.autoFadeOut != .greatestFiniteMagnitude else { return }
        autoFadeOutTimer = PlayTimer(interval: 0.25 + config.autoFadeOut, initialDelay: 0.25 + config.autoFadeOut)
        autoFadeOutTimer?.run { [weak self] _ in
            self?.hiddenToolView()
        }
    }

    func cancelAutoFadeOutTooView() {
        autoFadeOutTimer = nil
        self.dismissHUBRateView()
    }

    func formatDuration(_ duration: TimeInterval) -> String {
        let time = Int(ceil(duration))
        let hours = time / 3600
        let minutes = (time % 3600) / 60
        let seconds = time % 60
        return hours == 0 ? String(format: "%02ld:%02ld", minutes, seconds) : String(format: "%02ld:%02ld:%02ld", hours, minutes, seconds)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if rateView.bounds.contains(touch.location(in: rateView)) {
            return false
        } else if topToolView.bounds.contains(touch.location(in: topToolView)) {
            return false
        } else if bottomToolView.bounds.contains(touch.location(in: bottomToolView)) {
            return false
        } else if gestureRecognizer == panGesture {
            guard screenState != .animating else { return false }
            if config.gestureInteraction == .none { return false }
            if config.gestureInteraction == .small, screenState == .fullScreen { return false }
            if config.gestureInteraction == .fullScreen, screenState == .small { return false }
        }
        return true
    }
}



