//
//  GoogleNativeController.swift
//  MyHub
//
//  Created by hub on 3/5/26.
//

import UIKit
import GoogleMobileAds

class GoogleNativeController: UIViewController {
    
    var adContent: NativeAd?
    
    var s_adContent: NativeAd?
    
    var adsTime: Int = 7
    var adsRate: Int = 0
    var isClickAds: Bool = false
    var timer: DispatchSourceTimer?
    let queue = DispatchQueue(label: "admobNative")
    private var isUpAds: Bool = false
    private var isUpClose: Bool = false
    private var showC: Int = 0
    
    @IBOutlet weak var mainView: NativeAdView!
    
    @IBOutlet weak var videoV: MediaView!
    
    @IBOutlet weak var appImgV: UIImageView!
    
    @IBOutlet weak var titleL: UILabel!
    
    @IBOutlet weak var infoL: UILabel!
    
    @IBOutlet weak var installButton: UIButton!
    
    @IBOutlet weak var timeL: UILabel!
    
    @IBOutlet weak var closeBtn: UIButton!
    
    @IBOutlet weak var closeView: UIImageView!
    
    @IBOutlet weak var s_mainView: NativeAdView!
    
    @IBOutlet weak var s_videoV: MediaView!
    
    @IBOutlet weak var s_appImgV: UIImageView!
    
    @IBOutlet weak var s_titleL: UILabel!
    
    @IBOutlet weak var s_infoL: UILabel!
    
    @IBOutlet weak var s_installButton: UIButton!
    
    @IBOutlet weak var s_timeL: UILabel!
    
    @IBOutlet weak var s_closeBtn: UIButton!
    
    @IBOutlet weak var s_closeView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.isUpClose = Bool.random()
        HubTool.share.showAdomb = true
        NotificationCenter.default.post(name: Noti_ShowAds, object: nil, userInfo: nil)
        MobileAds.shared.isApplicationMuted = true
        MobileAds.shared.audioVideoManager.isAudioSessionApplicationManaged = true
        TbaManager.instance.addEvent(type: .custom, event: .adsshowPlacement, paramter: [EventParaName.value.rawValue: HubTool.share.adsPlayState.rawValue, EventParaName.type.rawValue: "1"])
        
        if let ad = self.adContent {
            installButton.layer.cornerRadius = 8
            installButton.layer.masksToBounds = true
            timeL.layer.cornerRadius = 9
            timeL.layer.masksToBounds = true
            mainView.mediaView = videoV
            mainView.callToActionView = installButton
            mainView.storeView = closeView
            mainView.bodyView = infoL
            mainView.headlineView = titleL
            mainView.iconView = appImgV
            
            self.videoV.mediaContent = ad.mediaContent
            mainView.nativeAd = ad
            appImgV.image = ad.icon?.image
            titleL.text = ad.headline
            infoL.text = ad.body
            installButton.setTitle(ad.callToAction, for: .normal)
            self.mainView.isHidden = false
            self.isUpAds = true
            self.showC = 1
        } else {
            self.mainView.isHidden = true
            self.showC = 0
        }
        if let s_ad = self.s_adContent {
            s_installButton.layer.cornerRadius = 8
            s_installButton.layer.masksToBounds = true
            s_timeL.layer.cornerRadius = 9
            s_timeL.layer.masksToBounds = true
            s_mainView.mediaView = s_videoV
            s_mainView.callToActionView = s_installButton
            s_mainView.storeView = s_closeView
            s_mainView.bodyView = s_infoL
            s_mainView.headlineView = s_titleL
            s_mainView.iconView = s_appImgV
            
            self.s_videoV.mediaContent = s_ad.mediaContent
            s_mainView.nativeAd = s_ad
            s_appImgV.image = s_ad.icon?.image
            s_titleL.text = s_ad.headline
            s_infoL.text = s_ad.body
            installButton.setTitle(s_ad.callToAction, for: .normal)
            self.s_mainView.isHidden = false
            if self.showC == 0 {
                self.showC = 2
            } else {
                self.showC = self.isUpClose ? 2 : 1
            }
        } else {
            self.s_mainView.isHidden = true
        }
        
        self.closeView.isUserInteractionEnabled = false
        self.s_closeView.isUserInteractionEnabled = false
        
        if GoogleManager.share.showMode != .playing {
            self.adsTime = GoogleManager.share.nativeTime
            self.adsRate = GoogleManager.share.nativeClickRate
            self.view.backgroundColor = UIColor.rgbHex("#000000")
            self.timeL.isHidden = !self.isUpAds
            self.s_timeL.isHidden = self.isUpAds
            self.strat()
        } else {
            self.showC = 1
            self.adsTime = GoogleManager.share.playNativeTime
            self.adsRate = GoogleManager.share.playNativeClickRate
            self.timeL.isHidden = true
            self.view.backgroundColor = UIColor.rgbHex("#000000", 0.4)
            self.isShowCloseBtn()
        }
        self.view.isUserInteractionEnabled = true
        NotificationCenter.default.addObserver(forName: Noti_ClickNativeAds, object: nil, queue: .main) {  [weak self] _ in
            guard let self = self else { return }
            self.isClickAds = true
            guard self.adsTime > 0 else {
                if self.showC == 1 {
                    self.closeView.isHidden = true
                    self.closeBtn.isHidden = false
                    self.s_closeView.isHidden = true
                    self.s_closeBtn.isHidden = true
                } else {
                    self.closeView.isHidden = true
                    self.closeBtn.isHidden = true
                    self.s_closeView.isHidden = true
                    self.s_closeBtn.isHidden = false
                }
                return
            }
        }
        self.closeBtn.addTarget(self, action: #selector(clickCloseEvent), for: .touchUpInside)
        self.s_closeBtn.addTarget(self, action: #selector(clickCloseEvent), for: .touchUpInside)
    }
    
    func strat() {
        guard self.adsTime > 0 else {
            if self.showC == 1 {
                self.closeView.isHidden = true
                self.closeBtn.isHidden = false
                self.s_closeView.isHidden = true
                self.s_closeBtn.isHidden = true
            } else {
                self.closeView.isHidden = true
                self.closeBtn.isHidden = true
                self.s_closeView.isHidden = true
                self.s_closeBtn.isHidden = false
            }
            self.timeL.isHidden = true
            self.s_timeL.isHidden = true
            return
        }
        self.timer = DispatchSource.makeTimerSource(queue: self.queue)
        self.timer?.schedule(deadline: .now() + 1, repeating: 1)
        self.timer?.setEventHandler { [weak self] in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.sumTime()
            }
        }
        self.timer?.resume()
    }
    
    @objc func sumTime() {
        self.adsTime -= 1
        self.timeL.text = "\(self.adsTime)"
        self.s_timeL.text = "\(self.adsTime)"
        if self.adsTime <= 0 {
            self.isShowCloseBtn()
            self.timeL.isHidden = true
            self.s_timeL.isHidden = true
            self.timer?.cancel()
            self.timer = nil
        }
    }
    
    func isShowCloseBtn() {
        guard self.isClickAds == false else {
            if self.showC == 1 {
                self.closeView.isHidden = true
                self.closeBtn.isHidden = false
                self.s_closeView.isHidden = true
                self.s_closeBtn.isHidden = true
            } else {
                self.closeView.isHidden = true
                self.closeBtn.isHidden = true
                self.s_closeView.isHidden = true
                self.s_closeBtn.isHidden = false
            }
            return
        }
        if self.videoV.isUserInteractionEnabled == true {
            let a = arc4random_uniform(UInt32(100))
            if a <= (self.adsRate) {
                if self.showC == 1 {
                    self.closeView.isHidden = false
                    self.closeBtn.isHidden = true
                    self.s_closeView.isHidden = true
                    self.s_closeBtn.isHidden = true
                } else {
                    self.closeView.isHidden = true
                    self.closeBtn.isHidden = true
                    self.s_closeView.isHidden = false
                    self.s_closeBtn.isHidden = true
                }
            } else {
                if self.showC == 1 {
                    self.closeView.isHidden = true
                    self.closeBtn.isHidden = false
                    self.s_closeView.isHidden = true
                    self.s_closeBtn.isHidden = true
                } else {
                    self.closeView.isHidden = true
                    self.closeBtn.isHidden = true
                    self.s_closeView.isHidden = true
                    self.s_closeBtn.isHidden = false
                }
            }
        } else {
            if self.showC == 1 {
                self.closeView.isHidden = true
                self.closeBtn.isHidden = false
                self.s_closeView.isHidden = true
                self.s_closeBtn.isHidden = true
            } else {
                self.closeView.isHidden = true
                self.closeBtn.isHidden = true
                self.s_closeView.isHidden = true
                self.s_closeBtn.isHidden = false
            }
        }
    }
    
    @objc func clickCloseEvent() {
        self.dismiss(animated: false) {
            GoogleManager.share.closeAdSuccess()
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        if self.showC == 1 {
            if self.closeView.isHidden == false {
                self.closeView.isHidden = true
                self.closeBtn.isHidden = false
            }
        } else {
            if self.s_closeView.isHidden == false {
                self.s_closeView.isHidden = true
                self.s_closeBtn.isHidden = false
            }
        }
    }
}
