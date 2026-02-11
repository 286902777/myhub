//
//  PlayVideoController.swift
//  MyHub
//
//  Created by hub on 2/10/26.
//

import UIKit
import AVFoundation
import SnapKit

class PlayVideoController: UIViewController {
    private lazy var player: HUBPlayer = {
        let view = HUBPlayer()
        return view
    }()
    
    private var model: VideoData = VideoData()
    private var isHistory: Bool = false
    private var isBack: Bool = false
    var add = false
    var premiumBlock: (() -> Void)?
    private var isPop: Bool = false
    
    init(model: VideoData, history: Bool) {
        self.model = model
        self.isHistory = history
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.model.history = true
        if self.player.currentDuration > 0 {
            if self.player.currentDuration == self.player.totalDuration {
                self.model.playTime = 0.0
            } else {
                self.model.playTime = self.player.currentDuration
            }
        }
        if self.player.totalDuration > 0 {
            self.model.totalTime = self.player.totalDuration
            self.model.date = Double(Date().timeIntervalSince1970 * 1000)
            HubDB.instance.updateMovieData(self.model)
        }
    }

    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if let _ = parent {
            return
        } else {
            if self.isPop == false, self.player.isPlaying {
//                HubTool.share.adsPlayState = .playBack
//                AdmobTool.instance.show(.mode_play) { [weak self] success in
//                    guard let self = self else { return}
//                    if success {
//                        self.isBack = true
//                    } else {
//                        self.premiumBlock?()
//                        self.navigationController?.popViewController(animated: true)
//                    }
//                }
//                return
            }
        }
    }
    
    private func setDownBtnState(_ down: Bool = false) {
        if down {
            self.player.playerView.contentView.downState = .downWait
        } else {
            if self.isHistory == false {
                let list = HubDB.instance.readDatas().filter({$0.file_type == .video})
                if let m = list.first(where: {$0.id == self.model.id}) {
                    m.linkId = self.model.linkId
                    m.recommend = self.model.recommend
                    self.model = m
                }
            }
            self.player.playerView.contentView.downState = model.state
        }
    }
    
    deinit {
        print("PlayerController deinit")
        self.player.stop()
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setUI()
        self.loadSource()
        self.setDownBtnState()
        NotificationCenter.default.addObserver(forName: Noti_ShowAds, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.player.playerView.contentView.loadingView.stop()
            self.player.pause()
        }
        
        NotificationCenter.default.addObserver(forName: Noti_DismissAds, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.player.playerView.contentView.loadingView.stop()
//            if AdmobTool.instance.showMode == .mode_open { return }
//            guard let vc = HubTool.share.keyVC(), vc.isKind(of: PlayVideoController.self) else { return }
//            
//            if HubTool.share.adsPlayState == .download {
//                ToastTool.instance.show("Added to download list")
//                if self.model.platform != .box {
//                    HubTool.share.downEvent(self.model)
//                }
//                FileUploadDownTool.instance.downLoad(self.model)
//            }
//            if self.isBack {
//                self.premiumBlock?()
//                self.navigationController?.popViewController(animated: true)
//            } else {
//                self.player.pause()
//                PrePopTool.instance.openPopPage(self)
//            }
        }
        NotificationCenter.default.addObserver(forName: Noti_DownSuccess, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let mod = data.userInfo?["mod"] as? FileTransData {
                if (self.model.id == mod.transId) {
                    self.model.state = mod.state
                    self.model.movieAddress = mod.local
                    if mod.state == .downDone {
                        HubDB.instance.updateMovieData(self.model)
                    }
                    self.setDownBtnState()
                }
            }
        }
    }
    
    func setUI() {
        self.view.addSubview(self.player)
        self.player.snp.makeConstraints { make in
            make.top.equalTo(self.view.safeAreaInsets.top)
            make.bottom.equalTo(self.view.safeAreaInsets.bottom)
            make.left.right.equalToSuperview()
        }
        self.player.delegate = self
        NotificationCenter.default.addObserver(forName: Noti_DownSuccess, object: nil, queue: .main) { [weak self] data in
            guard let self = self else { return }
            if let mod = data.userInfo?["mod"] as? FileTransData {
                if self.model.id == mod.transId {
                    self.model.state = mod.state
                    self.model.movieAddress = mod.local
                    HubDB.instance.updateMovieData(self.model)
                }
            }
        }
//        HubTool.share.adsPlayState = .play
    }
    
    private func loadSource(_ auto: Bool = false) {
        self.add = false
        PlayTool.instance.auto = auto
        HubTool.share.fileId = self.model.id
        HubTool.share.isCountMiddlePlay = false
        self.player.title = NSMutableAttributedString(string: self.model.name, attributes: [.foregroundColor : UIColor.white, .font: UIFont.systemFont(ofSize: 14, weight: .medium)])
        
        let count = UserDefaults.standard.integer(forKey: HUB_PlayingCount)
        UserDefaults.standard.set(count + 1, forKey: HUB_PlayingCount)
        UserDefaults.standard.synchronize()
        
        if self.isHistory == false {
            if let localModel = HubDB.instance.readDatas().first(where: {$0.id == self.model.id}) {
                localModel.linkId = self.model.linkId
                localModel.recommend = self.model.recommend
                self.model = localModel
            }
        }
        HubTool.share.currentPlatform = self.model.platform
        HubTool.share.playLinkId = self.model.linkId
        HubTool.share.playUserId = self.model.userId

//        AdmobTool.instance.show(.mode_play) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.player.playerView.contentView.loadingView.stop()
//                self.player.pause()
//                let count = UserDefaults.standard.integer(forKey: HUB_OpenVipPop)
//                UserDefaults.standard.set(count + 1, forKey: HUB_OpenVipPop)
//                UserDefaults.standard.synchronize()
//            }
//        }

        if self.model.isNet == true, self.model.state != .downDone {
            if self.model.movieAddress.count == 0 {
                self.requestPlayUrl(self.model)
            } else {
                self.player.url = URL(string: self.model.movieAddress)
                self.play()
            }
        } else {
            let local = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let path = (local as NSString).appendingPathComponent(model.movieAddress)
            self.player.url = URL(fileURLWithPath: path)
            self.play()
        }
        
        
        if self.model.playTime > 0 {
            self.player.seek(to: HUBPlayer.HUBPlayerSeek(time: CMTimeMake(value: Int64(self.model.playTime), timescale: 1)))
        }
        
        self.setNextStatus()
    }
    
    private func play() {
        var isPlay = false
        if let vc = HubTool.share.keyVC(), vc.isKind(of: PlayVideoController.self) {
            isPlay = true
        }
        if HubTool.share.showAdomb == false {
            isPlay = true
        }
        if isPlay {
            self.player.play()
        }
    }
    
    private func requestPlayUrl(_ model: VideoData) {
        if model.platform == .box {
            HttpManager.share.driveDownLoadUrlApi(model.id) {[weak self] status, address, errMsg in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if status == .success {
                        model.history = true
                        model.movieAddress = address
                        HubDB.instance.updateMovieData(model)
                        if let vUrl = URL(string: model.movieAddress) {
                            self.player.url = vUrl
                            self.play()
                        }
                    } else {
                        if let e = errMsg {
                            ToastTool.instance.show(e, .fail)
                        }
                    }
                }
            }
        } else {
            HttpManager.share.requestMovieAddress(model) {[weak self] status, address, errMsg, refresh in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    if status == .success {
                        model.history = true
                        model.movieAddress = address
                        HubDB.instance.updateMovieData(model)
                        if let vUrl = URL(string: model.movieAddress) {
                            self.player.url = vUrl
                            self.play()
                        }
                    } else {
                        if let e = errMsg {
                            ToastTool.instance.show(e, .fail)
                        }
                    }
                }
            }
        }
    }
    
    private func sourceReSet(_ mod: VideoData, _ auto: Bool = false) {
        self.model.history = true
        if (self.player.currentDuration == self.player.totalDuration) {
            self.model.playTime = 0
        } else {
            self.model.playTime = self.player.currentDuration
        }
        self.model.totalTime = self.player.totalDuration
        HubDB.instance.updateMovieData(self.model)
        self.model = mod
        self.setDownBtnState()
        self.loadSource(auto)
    }
    
    func setNextStatus() {
        var idx: Int = 0
        for (i, mod) in PlayTool.instance.list.enumerated() {
            if self.model.movieAddress == mod.movieAddress, self.model.id == mod.id {
                idx = i
            }
        }
        let unNext = idx == PlayTool.instance.list.count - 1
        self.player.playerView.contentView.nextButton.isEnabled = !unNext
        NotificationCenter.default.post(name: Noti_NextPlay, object: nil, userInfo: ["mod": self.model])
    }
    
    private func playNext(_ auto: Bool = false) {
        HubTool.share.adsPlayState = auto ? .play : .playNext
        var idx: Int = 0
        for (i, mod) in PlayTool.instance.list.enumerated() {
            if self.model.id == mod.id {
                idx = i
            }
        }
        if idx == PlayTool.instance.list.count - 1 {
            return
        }
        
        if let m = PlayTool.instance.list.safeIndex(idx + 1) {
            self.player.playerView.resetRate()
            self.sourceReSet(m, auto)
        }
    }
    
    private func uploadFirstPlay() {
        if UserDefaults.standard.bool(forKey: HUB_UploadFirstDeepPlay) == false, UserDefaults.standard.bool(forKey: HUB_AppDown) == true, HubTool.share.linkId.count > 0 {
            let m = VideoData()
            m.linkId = HubTool.share.linkId
            m.userId = HubTool.share.uId
            m.platform = HubTool.share.currentPlatform
            HttpManager.share.uploadEventApi(event: .new_user_active_by_play_video, currency: "", val: 0, model: m) { [weak self] success in
                guard let self = self else { return }
                if success == false {
                    self.uploadFirstPlay()
                } else {
                    UserDefaults.standard.set(true, forKey: HUB_UploadFirstDeepPlay)
                    UserDefaults.standard.synchronize()
                }
            }
        }
    }
    
    private func uploadPlaySuccess() {
        HttpManager.share.uploadEventApi(event: .play_video, currency: "", val: 0, model: self.model) { [weak self] success in
            guard let self = self else { return }
            if success == false {
                self.uploadPlaySuccess()
            }
        }
    }
    
    func openPremium(_ auto: Bool) {
        self.player.pause()
        if auto {
            HubTool.share.preSource = .vip_Accelerate
            HubTool.share.preMethod = .vip_click
        } else {
            HubTool.share.preSource = .vip_playPage
            HubTool.share.preMethod = .vip_click
        }
//        let vc = PremiumController()
//        vc.modalPresentationStyle = .fullScreen
//        self.present(vc, animated: true)
    }
}

extension PlayVideoController {
    override var shouldAutorotate: Bool {
        return false
    }
    
    // 支持哪些屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    //默认的屏幕方向（当前ViewController必须是通过模态出来的UIViewController（模态带导航的无效）方式展现出来的，才会调用这个方法）
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

extension PlayVideoController: HUBPlayerDelegate {
    func playerDidClickBackButton(_ player: HUBPlayer) {
        HubTool.share.adsPlayState = .playBack
        self.isPop = true
//        AdmobTool.instance.show(.mode_play) { [weak self] success in
//            guard let self = self else { return}
//            if success {
//                self.isBack = true
//            } else {
//                self.premiumBlock?()
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
    }
    
    func playerSuccessPlaying(_ player: HUBPlayer) {
        self.uploadFirstPlay()
        self.uploadPlaySuccess()
    }

    func playerDidFinishPlaying(_ player: HUBPlayer) {
        self.model.playTime = 0
        HubDB.instance.updateMovieData(self.model)
        self.playNext(true)
    }
    
    func playerDidClickDownButton(_ player: HUBPlayer) {
        if (LoginManager.share.isLogin == false) {
            self.player.playerView.contentView.loadingView.stop()
            self.player.pause()
            LoginManager.share.loginRequest(self) { success in
               
            }
            return
        }
        HubTool.share.eventSource = .download
        HubTool.share.adsPlayState = .download
//        AdmobTool.instance.show(.mode_down) { [weak self] success in
//            guard let self = self else { return }
//            if success {
//                self.player.playerView.contentView.loadingView.stop()
//                self.player.pause()
//            } else {
//                ToastTool.instance.show("Added to download list")
//                FileUploadDownTool.instance.downLoad(self.model)
//                if self.model.platform != .box {
//                    HubTool.share.downEvent(self.model)
//                }
//            }
//        }
        self.setDownBtnState(true)
    }
    
    func playerDidClickNextButton(_ player: HUBPlayer) {
        print("next")
        self.playNext()
    }
    
    func player(_ player: HUBPlayer, didClickVip auto: Bool) {
        if self.player.playerView.isFullScreen {
            self.player.playerView.dismiss { [weak self] in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.openPremium(auto)
                }
            }
        } else {
            self.openPremium(auto)
        }
    }
    
    func player(_ player: HUBPlayer, didClickMore full: Bool) {
        if full {
            let vc = PlayListFullController(model: self.model, history: self.isHistory)
            vc.selectBlock = { [weak self] mod in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    HubTool.share.playSource = mod.recommend ? .playlist_recommend : .playlist_file
                    self.sourceReSet(mod)
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            HubTool.share.keyVC()?.present(vc, animated: false)
        } else {
            let vc = PlayListController(model: self.model, history: self.isHistory)
            vc.selectBlock = { [weak self] mod in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    HubTool.share.playSource = mod.recommend ? .playlist_recommend : .playlist_file
                    self.sourceReSet(mod)
                }
            }
            vc.modalPresentationStyle = .overFullScreen
            self.present(vc, animated: false)
        }
    }
    
    func player(_ player: HUBPlayer, changeRate rate: Float) {
        
    }
    
    func player(_ player: HUBPlayer, didFailWithError error: Error?) {
        ToastTool.instance.show(error?.localizedDescription, .fail)
        self.playNext(true)
    }
    
    func playerLoadPop(_ player: HUBPlayer) {
//        guard PremiumTool.instance.isMember == false else { return }
        if HubTool.share.preMiumCount < 5, HubTool.share.preMiumMagin >= 2 {
            let played = HubTool.share.preMiumLists.contains(where: {$0 == self.model.id})
            if played {
                return
            }
            HubTool.share.preMiumMagin = 0
            HubTool.share.preMiumCount += 1
            HubTool.share.preMiumLists.append(self.model.id)
            self.player.playerView.contentView.showLoading()
        } else {
            HubTool.share.preMiumMagin += 1
        }
    }
}
